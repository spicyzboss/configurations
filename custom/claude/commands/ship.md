# ship

Ship the current worktree: merge its changes into `main`, then run the project's own deploy command. This command will:
1. Check git status and identify the current worktree/branch
2. Ensure the worktree is clean and committed
3. Merge the current branch into `main`
4. Detect the project's deploy command
5. Run the deploy command from the project root
6. Confirm success

This is the last-mile command: it assumes work is already committed on a feature branch in a worktree and you are ready to land it on `main` and deploy.

## Workflow

When the user runs this command, follow these steps:

### Step 1: Identify Worktree and Branch
- Run `git rev-parse --show-toplevel` to find the worktree root
- Run `git status` and `git branch --show-current` to get the current branch
- Run `git worktree list` to confirm this is a linked worktree and locate the main worktree
- If the current branch **is** `main`, tell the user there is nothing to merge and ask whether they just want to deploy; stop unless they confirm
- If in detached HEAD state, warn and stop

### Step 2: Ensure Clean and Committed
- Run `git status --porcelain` to check for uncommitted changes
- If there are uncommitted changes, stop and tell the user to commit (or `/commit`) first — do **not** auto-commit
- Confirm the branch has commits ahead of `main`: `git log main..HEAD --oneline`
- If there are no commits ahead of `main`, tell the user there is nothing to ship and stop

### Step 3: Merge into main
- Record the current branch name (e.g. `$BRANCH`)
- Switch the main worktree to `main` (or `cd` to it if `main` is checked out in a separate worktree — you cannot check out `main` in two worktrees at once)
- Update `main` first: `git pull --ff-only` (skip if there is no remote/upstream)
- Merge the feature branch: `git merge --no-ff $BRANCH`
- If the merge has conflicts, stop and report them — do **not** attempt automatic resolution; let the user resolve and re-run
- Report the merge result and the new `main` HEAD

### Step 4: Detect the Deploy Command
Inspect the project root for a deploy command, in this priority order:
- **package.json**: a `deploy` script → `bun run deploy`
- **Makefile / justfile**: a `deploy` target → `make deploy` / `just deploy`
- **Wrangler (Cloudflare)**: `wrangler.toml` / `wrangler.jsonc` present → `bun wrangler deploy` (if `deploy` script not present)
- **Custom**: a `deploy.sh` or `scripts/deploy*` in the repo → run it
- If multiple candidates exist, prefer the one matching the project's primary tooling and tell the user which you chose
- If **no** deploy command is found, stop and ask the user what the deploy command is

### Step 5: Run Deploy
- Run the detected deploy command from the project root (the `main` worktree, where the merge just landed)
- Stream/report the output so the user can see progress
- Do **not** retry on failure without telling the user

### Step 6: Confirm Success
- Confirm the merge landed on `main` and the deploy command exited successfully
- Report the deploy command used and any URL/output it produced
- Optionally remind the user to `git push` `main` if it has a remote and they want to publish the merge

## Important Notes

- **Commit first** – never auto-commit; the worktree must be clean before merging
- **Never force anything** – no force-push, no forced merge, no auto-conflict-resolution
- **Two worktrees, one `main`** – `main` can only be checked out in one worktree; operate in whichever one has it, or temporarily switch
- **Detect, don't guess** – derive the deploy command from project files; if ambiguous or missing, ask
- **Stop on conflict or failure** – report and hand back to the user rather than improvising
- **Deploy from `main`** – run the deploy after the merge so you ship the merged code, not the feature branch

## Example Interaction

User: "ship"

Assistant should:
1. `git branch --show-current` → `feat/new-widget`; `git worktree list` → confirm worktree
2. `git status --porcelain` → clean; `git log main..HEAD --oneline` → 3 commits ahead
3. Switch to `main`, `git pull --ff-only`, then `git merge --no-ff feat/new-widget`
4. Detect deploy: `wrangler.jsonc` present → `bun wrangler deploy`
5. Run `bun wrangler deploy` from the project root and stream output
6. Confirm: "Merged feat/new-widget into main (3 commits) and deployed via `bun wrangler deploy` → https://my-worker.workers.dev"

## Error Handling

- **On `main` already**: Nothing to merge; ask whether to just deploy, otherwise stop
- **Uncommitted changes**: Stop and ask the user to commit (or run `/commit`) first
- **Nothing ahead of `main`**: Tell the user there is nothing to ship and stop
- **Merge conflict**: Stop, report conflicting files, let the user resolve and re-run
- **No deploy command found**: Ask the user what the deploy command is
- **Deploy fails**: Report the exit code and output; do not retry silently. The merge stays on `main` — tell the user so they can decide whether to revert or fix-forward
- **Detached HEAD**: Warn and stop
