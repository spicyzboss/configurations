---
name: implement
description: Implement a GitHub issue (card/ticket/story) end to end - fetch it, research the codebase, build it, verify it against the DoD, then automatically run /pr-work and open a draft PR. Use when the user says "implement", "implement this issue/ticket/card/story", pastes one or more GitHub issue URLs as the input, asks to "implement next step", or adds preferences like "as a regular pr" or "to main". Also use when the user asks to check whether a card is already implemented.
---

# implement

Take an issue from card to working code: fetch it, understand it, build it, verify it against its Definition of Done, then automatically invoke /pr-work and open a draft PR. Draft on the repo's default branch is the default; the user's message can override to regular or a different branch.

## Step 1: Parse the request

The request comes in several shapes; handle each:

- **GitHub issue URL(s)** - the input format. Note `owner/repo` and issue number from each URL. Multiple URLs means multiple items; default to one PR per issue unless the user says "stacked pr" or similar.
- **Verbal spec** ("implement text-chat-consumer-worker for facebook messenger") - the message itself is the spec. There is no issue card; skip to research.
- **"implement next step"** - find the plan document in the repo (look for `plan/`, `docs/`, `*.plan.md`, a TODO with checkboxes) and take the next unchecked item. Confirm which item you picked if the plan is long.

Also parse the tail of the message for PR preferences - the PR itself happens automatically, these only shape it:

- "as a regular pr" -> open as regular instead of draft
- "to main branch" / "on develop" / "to dev branch" -> target that branch instead of the repo's default
- "test locally" -> verify by running the app, not just the test suite
- "wait for my decision" (or "no pr") -> opt out of the automatic PR; stop after verification and report

If none of these appear: implement, verify, then /pr-work as a draft on the repo's default branch.

## Step 2: Fetch the issue

```
gh issue view <number> --repo <owner>/<repo> --comments
```

Extract:
- Title (if it contains a `PROJECT-123` style key, keep it for branch naming)
- Description and any embedded spec (some cards reference Google Docs or pasted files; read those resources if paths were given)
- Acceptance criteria / DoD checkboxes - this is your contract for Step 5
- Linked PRs and cross-references

If the card is already closed or has an open/merged PR doing the work, say so before building anything. The user has asked "is this card implemented?" before - answering that cheaply is better than re-implementing.

## Step 3: Understand before building

- Explore the codebase for conventions: where similar features live, existing patterns the card explicitly wants to match, test layout, lint/typecheck commands.
- If the card is ambiguous, expensive to guess wrong on, or contradicts what the code shows, ask - short and specific, then proceed. Do not interrogate over trivia you can read from the code; the user says "if you have questions ask me", not "interview me".
- Scale to the card. A one-file fix should be done directly. If the user said "create a workflow" / "use dynamic workflow", or the card clearly spans many services, repos, or files, decompose and run subagents in parallel rather than grinding serially.
- Scope discipline: implement what the card asks, nothing more. The user has said things like "mostly for record token usage only no need to do more". If you spot adjacent problems, mention them at the end; do not fix them uninvited.
- Use whatever resources the user referenced (figma mcp, downloaded docs, another repo checked out locally).

## Step 4: Implement

- Follow existing codebase conventions for structure, naming, and style - match the neighbors.
- Keep the change small and focused: one logical change per PR (the /pr-work skill assumes this too).
- Declarative thinking before typing: know which files you will create or modify and why before you start editing.
- If the card defines an enum/config surface (e.g. a new `prompt_engine_version` with default `v1`), check how similar surfaces are wired - migrations, admin routes, docs - and wire the new one the same way.

## Step 5: Verify

- Run the project's tests, lint, and typecheck. Find them from package files or CI config, never assume.
- If the user said "test locally", actually run the affected flow locally and confirm the behavior, not just the suite.
- Walk the DoD item by item and report each as done / not done / needs decision. This is the summary the user reads first.

## Step 6: Handoff (automatic)

- Always finish by invoking the **pr-work** skill - it runs automatically, no confirmation needed. Hand it everything so it does not have to re-ask - the ticket key (if the issue title carries a `PROJECT-123` style key use it; otherwise `issue-<number>`), the branch type (`feat`/`fix`/...), the target branch (from the user's message, else the repo's default), draft vs regular (draft unless the user said "regular"), and the issue URL for the PR body (include `closes #<number>` when the repo expects PRs to close their issues).
- Multiple issues with "for each issue" - one PR per issue, in the order given. "stacked pr" - one branch, stacked changes.
- Only skip the PR if the user said "wait for my decision" or similar - then stop after verification, summarize what changed and the DoD status, and wait.

## Examples

**Example 1**
Input: `implement this https://github.com/100x-fi/zai-backend/issues/2514 as a regular pr to main`
Flow: fetch 2514 -> research -> implement -> verify -> /pr-work with ticket key from title (or `issue-2514` if untitled), target `main`, regular PR instead of the default draft.

**Example 2**
Input: `implement https://github.com/100x-fi/zai-backend/issues/1730 and https://github.com/100x-fi/zai-backend/issues/1632`
Flow: two cards, two branches, two draft PRs, both targeting the repo's default branch.

**Example 3**
Input: `create a workflow for implement https://github.com/100x-fi/zai-backend/issues/1698`
Flow: large card -> decompose, run subagents in parallel, then implement, verify, and open a draft PR automatically.

## Error handling

- **`gh` cannot see the issue** (private repo, wrong remote): ask the user to paste the card contents or confirm the repo.
- **No DoD / acceptance criteria on the card**: state your interpretation of done before building; let the user correct it.
- **Card depends on another card not yet merged**: stop and ask - do not build on unmerged work silently.
