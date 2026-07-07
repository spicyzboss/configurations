---
name: pr-resolve
description: >
  Fetch, triage, and resolve review feedback already posted on an existing
  GitHub PR (automated bots like CodeRabbit, or human reviewers). Verifies
  each claim before acting instead of reflexively "fixing" every suggestion,
  and only replies on GitHub when explicitly asked. Use for "check PR review
  comments", "resolve review suggestions", "read pr suggestion", "address the
  reviewer feedback". Not for reviewing a fresh PR (`/review`) or your own
  uncommitted diff (`/code-review`) or opening a new PR (`/pr-work`).
---

# pr-resolve

Works through review feedback already posted on an existing PR. The failure mode this guards against is treating every bot comment as gospel — automated reviewers (CodeRabbit and similar tools) commonly repost the *same* finding verbatim across rounds even after it's fixed, and occasionally invent a "High severity" bug that's factually wrong when checked.

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

Check `authorAssociation`: `NONE` is almost always an automated reviewer bot; `MEMBER`/`OWNER`/`COLLABORATOR` is a real teammate. That distinction changes what you can do about a comment — see step 5.

If this is a re-check after a previous pass, compare against what you already triaged. Bots frequently re-emit an *identical* finding (same wording, same line) on a later commit's review even though nothing about that code changed — that's not a new issue, it's noise.

## 3. Triage every finding — do not reflexively fix

Classify before touching anything:

- **Stale / already fixed** — same finding (wording + line) as an earlier round you already addressed. Skip, note it's resolved.
- **Not applicable** — flags a scenario that can't actually happen (e.g. "handle a missing config file" when its absence would already break the entire build). Skip, explain why.
- **False positive** — makes a specific, checkable claim (a function's return value, a matching rule, a version requirement). **Verify empirically, don't argue from memory or "that looks wrong."** Write a 5-line throwaway script and run it. Example encountered in practice: a bot claimed `strings.HasPrefix("Dockerfile.scheduler.amd64.bak", "Dockerfile.scheduler.amd64/")` returns `true` (called it a "High" bug) — running it showed `false`. The existing test already covered the case and passed; the claim was simply wrong.
- **Low-severity / hardening** — real but not a live bug (a defensive check for something that "probably can't happen"). **Default: note it and let the user decide, don't auto-fix.** Only fix inline without asking if it's a genuinely trivial, unambiguous, zero-behavior-risk one-liner (e.g. deriving a hardcoded constant from its real source instead of duplicating it). If there's any actual judgment call, surface it instead of deciding for the user.
- **Real bug** — confirmed by reading the code or reproducing it. Fix it.

Report back with a short table: finding / class / action. Lead with the verdict, not a transcript of the investigation.

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

## 6. Replying on GitHub — silence by default

**Do not post PR comments or replies unless the user explicitly asks.** It's noisy (triggers notifications for the team) and the default is to just fix, push, and report in conversation.

**When the user does ask** (e.g. "comment back on that suggestion", "reply as me"): thread it as a reply to the specific inline comment, not a new top-level comment:

```
gh api repos/<owner>/<repo>/pulls/<n>/comments \
  -f body="..." -f commit_id=<latest-sha> -F in_reply_to=<comment-id>
```

Write the body in first person as the PR author — no mention of AI/Claude/assistant involvement, just the technical rebuttal backed by the same evidence used to triage it (the actual command output, the test name that already covers it).

## 7. What isn't yours to resolve

Some comments need the user, not code — e.g. a human reviewer asking for a linked ticket/issue, a product question, a "why did we do it this way" that only the user knows. Surface these plainly and wait; don't invent an answer or dismiss the ask on the user's behalf.
