# push

Push current branch to remote. This command will:
1. Check git status and current branch
2. Show commit count/range being pushed
3. Verify remote connectivity
4. Check if upstream is set
5. Push to remote (with -u if upstream not set)
6. Confirm success

No new branch or PR is created; work stays on the branch you are on.

## Workflow

When the user runs this command, follow these steps:

### Step 1: Check Status
- Run `git status` to see current branch
- If working tree is clean but there's nothing to push, tell the user and stop
- If in detached HEAD state, warn and ask whether to checkout a branch before pushing

### Step 2: Show Commit Count/Range
- Run `git log @{u}.. --oneline` to see commits that will be pushed (if upstream exists)
- Or run `git log --oneline -5` to show recent commits
- Report the number of commits and the commit range (e.g., "Pushing 3 commits: abc123..def456")

### Step 3: Verify Remote Connectivity
- Check if remote exists: `git remote get-url origin`
- If remote doesn't exist, ask user to add it first
- Verify connectivity: `git ls-remote origin`
- If connectivity fails, report network error and suggest retry

### Step 4: Check Upstream
- Run `git branch -vv` to check if upstream is set
- If upstream is not set (no `[origin/branch]` shown), plan to use `git push -u origin <branch>`
- If upstream is set, plan to use `git push`

### Step 5: Push
- Run: `git push` or `git push -u origin <current-branch>` if upstream is not set
- Report the push command being used
- For dry-run, user can use `git push --dry-run` to preview without pushing

### Step 6: Confirm Success
- Confirm push succeeded
- Report the remote branch pushed to

## Important Notes

- **Check git status first** – verify there are commits to push
- **Show commit count** – let user see what's being pushed
- **Verify remote connectivity** – check connection before pushing
- **Handle upstream not set** – use `-u` flag to set upstream on first push
- **Never force-push** – do not force-push without explicit user confirmation
- **Dry-run option** – users can run `git push --dry-run` to preview changes
- **Network errors** – report connection issues and suggest retry

## Example Interaction

User: "push"

Assistant should:
1. Run `git status` → list current branch
2. Show commits to push: "Pushing 3 commits: abc1234..def5678"
3. Check upstream with `git branch -vv`
4. Verify remote connectivity with `git ls-remote origin`
5. Run `git push` (or `git push -u origin feat/new-feature` if needed)
6. Confirm push succeeded and state remote branch

## Error Handling

- **Nothing to push (no commits or up to date)**: Exit with a short message
- **Remote doesn't exist**: Ask user to add remote with `git remote add origin <url>`
- **Connectivity failure**: Report network error and suggest retry or check VPN
- **Push rejected** (e.g. non-fast-forward): Suggest `git pull --rebase` or ask before force-push; do not force-push without explicit user confirmation
- **Network errors**: Report the error and suggest retry
- **Detached HEAD**: Warn and ask whether to checkout a branch before pushing
- **Upstream not set**: Use `git push -u origin <branch>` to set upstream
