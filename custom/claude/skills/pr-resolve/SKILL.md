---
name: pr-resolve
description: >
  Fetch, triage, and resolve review feedback already posted on an existing
  GitHub PR (automated bots like CodeRabbit, or human reviewers). Verifies
  each claim before acting instead of reflexively "fixing" every suggestion,
  replies to every finding with its verdict so threads actually close instead
  of recurring every round, and loops until everything is resolved or only
  user-decision items remain. Use for "check PR review comments", "resolve
  review suggestions", "read pr suggestion", "address the reviewer feedback".
  Not for reviewing a fresh PR (`/review`) or your own uncommitted diff
  (`/code-review`) or opening a new PR (`/pr-work`).
---

# pr-resolve

Works through review feedback already posted on an existing PR, all the way to convergence. The failure mode this guards against is twofold: (1) treating every bot comment as gospel — automated reviewers (CodeRabbit and similar tools) commonly repost the *same* finding verbatim across rounds even after it's fixed, and occasionally invent a "High severity" bug that's factually wrong when checked; (2) going quiet after fixing/dismissing things — bots here don't reliably notice that a finding was already addressed unless *told*, even when the underlying code visibly changed between rounds. Silence is why the same finding comes back a third and fourth time. Every finding gets a reply with its verdict; the loop isn't done until nothing new comes back or only a human-decision item is left.

## 1. Auth / repo context

If `gh` commands fail with "Could not resolve to a Repository" or similar access errors, run `gh auth status` — if multiple accounts are logged in, switch to whichever one actually has access to the org/repo: `gh auth switch --user <account>`. This can reset between sessions, so re-check if a call that worked before suddenly fails.

Prefer letting `gh pr view`/`gh pr list` auto-detect the repo from the current directory; only pass `--repo <owner>/<repo>` when operating outside the repo's checkout.

## 2. Fetch everything

```
gh pr view <n> \
  --json state,reviews,comments \
  --jq '{state, reviews: [.reviews[] | {author: .author.login, authorAssociation, state, submittedAt, body, commit: .commit.oid}], comments: [.comments[] | {author: .author.login, createdAt, body}]}'

gh api repos/<owner>/<repo>/pulls/<n>/comments \
  --jq '.[] | "--- \(.path):\(.line // .original_line) (\(.user.login)) ---\n\(.body)\n"'
```

The first call gets review verdicts and top-level issue comments; the second gets the line-anchored inline suggestions, which is where the actual substance usually is. Note each comment's `id` (for threading a reply later) and `commit_id`/`original_commit_id` (to tell which round it came from).

Check `authorAssociation`: `NONE` is almost always an automated reviewer bot; `MEMBER`/`OWNER`/`COLLABORATOR` is a real teammate. That distinction changes what you can do about a comment — see step 8.

If this is a re-check after a previous pass, compare against what you already triaged. Bots frequently re-emit an *identical* finding (same wording, same line) on a later commit's review even though nothing about that code changed — that's not a new issue, it's noise.

## 3. Triage every finding — do not reflexively fix

Classify before touching anything:

- **Stale / already fixed** — same finding (wording + line) as an earlier round you already addressed, still open because nobody told the thread it was handled. Reply pointing at the commit/change that fixed it (see step 6) — don't just skip it again.
- **Not applicable** — flags a scenario that can't actually happen (e.g. "handle a missing config file" when its absence would already break the entire build). Reply explaining why, no code change.
- **False positive** — makes a specific, checkable claim (a function's return value, a matching rule, a version requirement). **Verify empirically, don't argue from memory or "that looks wrong."** Write a 5-line throwaway script and run it. Example encountered in practice: a bot claimed `strings.HasPrefix("Dockerfile.scheduler.amd64.bak", "Dockerfile.scheduler.amd64/")` returns `true` (called it a "High" bug) — running it showed `false`. The existing test already covered the case and passed; the claim was simply wrong. Reply with the disproof.
- **Low-severity / hardening** — real but not a live bug (a defensive check for something that "probably can't happen"). **Default: note it and let the user decide, don't auto-fix.** Only fix inline without asking if it's a genuinely trivial, unambiguous, zero-behavior-risk one-liner (e.g. deriving a hardcoded constant from its real source instead of duplicating it). Either way — fixed or deferred — reply saying which and why; if deferred, say it's pending the user's call, don't leave the thread silent.
- **Real bug** — confirmed by reading the code or reproducing it. Fix it, then reply naming the commit that fixed it. Don't assume the diff speaks for itself — the bots here re-flag already-fixed findings just as often as they re-flag ones nobody addressed.

Every finding gets *some* reply (step 6) — the only exception is a finding that's purely for the user to decide (step 8), where you report in conversation and hold off replying until they've weighed in. Report back with a short table: finding / class / action. Lead with the verdict, not a transcript of the investigation.

## 4. Fix what's real

Implement, rebuild, run the relevant tests and linters, commit with a plain conventional message, push. Re-run whatever end-to-end check the original PR used to validate behavior (e.g. if it was verified live against real data/history, re-verify the same way after the fix) — don't rely on unit tests alone for something that was originally sanity-checked live.

**Check `git status` before staging broadly (`git add -A`/`git add .`).** Build/verification commands can leave compiled output or other artifacts sitting in the working tree that shouldn't be committed — review what's actually staged, not just what you intended to change.

## 5. Push reliably

If `git push`/`git fetch` times out over SSH, switch that remote to HTTPS with gh's own credentials rather than retrying SSH:

```
git config --local --add credential.helper ""
git config --local --add credential.helper "!gh auth git-credential"
git remote set-url origin "$(gh repo view --json url -q .url).git"
git push
```

The blank `credential.helper ""` entry resets any stale global credential helper (e.g. `osxkeychain`) that otherwise shadows gh's token and causes a confusing "Repository not found" even once the remote URL is HTTPS.

## 6. Reply to every finding — this is the default, not an exception

Post a reply to **every** bot finding you triaged in step 3, threaded under the specific inline comment (not a new top-level comment), stating the verdict plainly: fixed (name the commit), already handled (point at what handles it), not applicable (say why), false positive (show the disproof), or deferred pending the user's call. This is the default behavior of this skill — don't wait to be asked, and don't skip the ones that feel obvious or already-explained-in-conversation. An unreplied finding is indistinguishable, from the bot's side, from one nobody looked at, and it *will* come back next round.

```
gh api repos/<owner>/<repo>/pulls/<n>/comments \
  -f body="..." -f commit_id=<latest-sha> -F in_reply_to=<comment-id>
```

For bodies with code blocks/backticks, don't inline the string — shell-escaping a multi-line markdown body with backticks is exactly how this goes wrong. **`-f key=@<path>` does NOT read the file** — `-f`/`--raw-field` always treats the value as a literal string, so `-f body=@foo.txt` posts the literal text `@foo.txt`. This happened in practice: 12 replies went out as literal file-path strings before it was caught on the next fetch. Use one of:
- `-f body="$(cat <path>)"` — command substitution, verified working.
- `-F body=@<path>` — `-F`/`--field` is the one that supports `@path` file-reading.

Either way, **verify immediately after posting**: `gh api repos/<owner>/<repo>/pulls/comments/<id> --jq '.body'` and confirm it's the real content, not a re-print of what you *meant* to send. If it's wrong, fix it with a `PATCH` to the same endpoint (`-X PATCH -f body="$(cat <path>)"`) before moving on — don't leave broken placeholder text sitting on a real PR while you post the remaining replies.

When several comments need near-identical replies (e.g. the same fix applied across multiple workflow files), that's fine — post one reply per comment ID, each pointing at the same commit, rather than skipping the "duplicates."

Write every reply in first person as the PR author — no mention of AI/Claude/assistant involvement, just the technical content (the actual command output, the test name that already covers it, the commit that fixed it). It should read like a developer's own response.

The one thing that does NOT get a GitHub reply: findings that are purely for the user to decide (step 8) — report those in conversation and hold off replying on GitHub until the user has weighed in, since you'd otherwise be answering on their behalf.

## 7. Loop until it converges

Replying can itself provoke a response — a bot may concede and resolve the thread, push back further, or a human may reply to your reply. After posting replies, re-fetch (step 2) and check for anything new:

- A bot concession/resolution on a thread you replied to → done, no further action.
- A bot pushing back with a new angle → go back to step 3, triage it like any other finding.
- Nothing new at all → you've converged; state that plainly rather than re-checking indefinitely.

Repeat fetch → triage → fix/reply → re-fetch until either nothing new appears, or everything remaining is a user-decision item (step 8). Don't stop after one pass just because you replied to everything that existed *at that moment* — the replies are what trigger the next round, so check for it.

## 8. What isn't yours to resolve

Some comments need the user, not code — e.g. a human reviewer asking for a linked ticket/issue, a product question, a "why did we do it this way" that only the user knows. Surface these plainly in conversation and wait; don't invent an answer, don't reply on GitHub on the user's behalf, and don't let this be the reason the loop in step 7 never terminates — it's a legitimate stopping point, not an unresolved bot finding.
