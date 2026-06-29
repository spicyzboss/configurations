# pr-work

Create a pull request following work-style conventions with optional ticket tracking. This command will guide you through:
1. Checking git status and verifying clean working tree
2. Creating a feature branch (with ticket prefix in the name only when a ticket is provided)
3. Staging and committing changes
4. Pushing to remote
5. Creating a PR with GitHub CLI

## Workflow

When the user requests to create a PR, follow these steps:

### Step 1: Check Current Status
- Run `git status` to see what files have been modified
- Check if we're on the correct base branch (usually `main` or `develop`)
- **Pre-flight check**: If working tree is dirty (uncommitted changes) on base branch, ask if user wants to stash or commit first
- Identify all changed files (modified, added, deleted)

### Step 2: Ticket Number (optional)
- Ask whether this work has a ticket. If yes, ask for the key in typical format (e.g. `ING-342`, `PROJ-123`).
- If the user skips, says there is no ticket, or does not give a key matching `PROJECT-123` style: treat as **no ticket** — do not invent or require one.
- When a ticket is provided: use it in the **branch name only** (lowercase), as below. When not provided: **omit** the ticket segment from the branch name entirely.

### Step 3: Create Feature Branch (if needed)
- Check if already on a feature branch (not main/master/develop)
- If on feature branch, ask if they want to use it or create a new one
- If on base branch, ask for:
  - Type: `feat`, `fix`, `docs`, `refactor`, `test`, `chore`, `perf`, `ci`, `style`, `build`
  - Brief feature description in kebab-case (2-5 words)
- Branch name:
  - **With ticket:** `{type}/{ticket-lowercase}-{kebab-case-description}`
    - Example: `feat/ing-342-add-agents-to-client-products`
    - Example: `fix/ing-400-fix-login-bug`
    - Example: `docs/ing-500-update-api-documentation`
  - **Without ticket:** `{type}/{kebab-case-description}` (no placeholder for a missing ticket)
    - Example: `feat/add-agents-to-client-products`
    - Example: `fix/login-validation-error`
- Run: `git checkout -b {branch-name}`

### Step 4: Stage Changes
- Review the changed files with the user
- Stage all relevant files: `git add {file1} {file2} ...`
- Or stage all changes: `git add .` (if user confirms)
- **Do not stage** `.env` or any file containing secrets

### Step 5: Commit Changes
- Show summary of staged vs unstaged changes
- Create a commit message following conventional commits format (do not include ticket number and long description):
  ```
  {type}: {short description}
  ```
- Types: `feat`, `fix`, `docs`, `refactor`, `test`, `chore`, `perf`, `ci`, `style`, `build`
- If many changes, offer to show diff preview before committing
- Run: `git commit -m "{commit message}"`

### Step 6: Verify Remote Before Push
- Check if remote exists: `git remote get-url origin`
- If remote doesn't exist, ask user to add it first
- Verify connectivity: `git ls-remote origin`

### Step 7: Push to Remote
- Show commit count being pushed (e.g., "Pushing 3 commits: abc123..def456")
- Push the branch: `git push -u origin {branch-name}`
- Verify the push was successful

### Step 8: Create Pull Request
- Ask if user wants a draft PR or regular PR
- Use GitHub CLI: `gh pr create`
- PR title: Format as `[{branch-target}][{branch-prefix-type}]: {description}` (do not include ticket number; ticket goes in body only)
- PR body should include `## Summary`, `## Changes`, `## Testing`, and `## DoD Checklist` as below.

  ```markdown
  ## Summary
  {Brief description of what this PR does}

  ## Changes
  - {Change 1}
  - {Change 2}
  - {Change 3}

  ## Testing
  - {Testing done}
  - {Test results}

  ## DoD Checklist
  - {Requirement 1}
  - {Requirement 2}
  ```

- Base branch: Ask which branch to target (usually `dev` or `main`)
- **Show PR details for confirmation**:
  ```markdown
  Ready to create PR:
  - Title: {title}
  - Base: {base-branch}
  - Type: {draft or regular}
  - Body preview:
    {body}
  ```
- Ask user to confirm: "Create PR with these details? (yes/no/edit)"
- Run: `gh pr create --title "{title}" --body "{body}" --base {base-branch}`
- If draft: add `--draft` flag

### Step 9: Confirm PR Created
- Confirm all steps completed successfully

## Important Notes

- **Ticket**: Ask once; if none or not in `PROJECT-123` form, branch name has no ticket segment and PR body has no Ticket section
- **Pre-flight check**: Verify working directory is clean before branching from base
- **Detect existing feature branch**: Skip branch creation if already on one
- **Verify remote exists**: Check `git remote` before pushing
- **Draft PR option**: Allow users to create draft PRs for work-in-progress
- **Copy PR link**: Store PR URL in clipboard for easy sharing
- **Write descriptive commit messages** - future you will thank you
- **Test before committing** - ensure tests pass and linter is clean
- **Check PR description** - make sure it accurately describes changes

## Example Interaction

User: "create branch and commit and push to remote and create pr"

Assistant should:
1. Check `git status` → verify working tree state
2. Ask whether there is a ticket; if yes, ask for the key (e.g. ing-342). If no or skipped, proceed without a ticket segment in the branch name.
3. Ask: "Type? (feat/fix/docs/refactor/etc.)"
4. Ask: "Brief description? (e.g., 'add agents to client products')"
5. Create branch: with ticket → `feat/ing-342-add-agents-to-client-products`; without ticket → `feat/add-agents-to-client-products`
6. Stage files: `git add file1.go file2.go file3_test.go`
7. Show staged vs unstaged summary
8. Commit: `feat: add agents to client products`
9. Verify remote exists and connectivity
10. Show commit count being pushed
11. Push: `git push -u origin {the-branch-name-from-step-5}`
12. Ask: "Draft PR or regular PR? Which base branch? (develop/main)"
13. Copy PR URL to clipboard and share with user

## Error Handling

- **Dirty working tree on base branch**: Ask if user wants to stash, commit, or discard changes
- **Already on feature branch**: Ask if they want to use it or create new one
- **Branch already exists**: Ask user if they want to switch to it or use a different name
- **Remote doesn't exist**: Ask user to add remote with `git remote add origin <url>`
- **Push fails**: Check if remote branch exists, may need to force push (ask first)
- **gh CLI not available**: Provide manual PR creation URL from git push output
- **Uncommitted changes**: Ask user if they want to stash, commit, or discard
- **On wrong base branch**: Ask user which base branch to use (develop/main)
- **No ticket number**: Use `{type}/{kebab-description}` for the branch
