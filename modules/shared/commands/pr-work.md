# pr-work

Create a pull request following work-style conventions with Jira ticket tracking. This command will guide you through:
1. Checking git status and verifying clean working tree
2. Creating a feature branch with ticket number
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

### Step 2: Get Jira Ticket Number
- Ask for Jira ticket number upfront (e.g., ING-342, ING-400, TICKET-123)
- This will be used in both branch name and commit message

### Step 3: Create Feature Branch (if needed)
- Check if already on a feature branch (not main/master/develop)
- If on feature branch, ask if they want to use it or create a new one
- If on base branch, ask for:
  - Type: `feat`, `fix`, `docs`, `refactor`, `test`, `chore`, `perf`, `ci`, `style`, `build`
  - Brief feature description in kebab-case (2-5 words)
- Create branch name in format: `{type}/{ticket}-{kebab-case-description}`
  - Example: `feat/ing-342-add-agents-to-client-products`
  - Example: `fix/ing-400-fix-login-bug`
  - Example: `docs/ing-500-update-api-documentation`
- Run: `git checkout -b {branch-name}`

### Step 4: Stage Changes
- Review the changed files with the user
- Stage all relevant files: `git add {file1} {file2} ...`
- Or stage all changes: `git add .` (if user confirms)
- **Do not stage** `.env` or any file containing secrets

### Step 5: Commit Changes
- Show summary of staged vs unstaged changes
- Create a commit message following conventional commits format with ticket:
  ```
  {type}: {short description} ({ticket})

  - {bullet point describing change 1}
  - {bullet point describing change 2}
  - {bullet point describing change 3}
  ```
- Types: `feat`, `fix`, `docs`, `refactor`, `test`, `chore`, `perf`, `ci`, `style`, `build`
- Include ticket number in parentheses on first line
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
- PR body should include:
  ```markdown
  ## Summary
  {Brief description of what this PR does}

  ## Ticket
  - Jira: {ticket-number}

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
- Base branch: Ask which branch to target (usually `develop` or `main`)
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
- Share the PR URL with the user
- Copy PR URL to clipboard (macOS: `pbcopy`, Linux: `xclip -selection clipboard`)
- Confirm all steps completed successfully

## Important Notes

- **Jira ticket first**: Always ask for ticket number before creating branch
- **Pre-flight check**: Verify working directory is clean before branching from base
- **Detect existing feature branch**: Skip branch creation if already on one
- **Verify remote exists**: Check `git remote` before pushing
- **Draft PR option**: Allow users to create draft PRs for work-in-progress
- **Copy PR link**: Store PR URL in clipboard for easy sharing
- **Ticket in commit**: Always include ticket number in commit message
- **Write descriptive commit messages** - future you will thank you
- **Test before committing** - ensure tests pass and linter is clean
- **Check PR description** - make sure it accurately describes changes

## Example Interaction

User: "create branch and commit and push to remote and create pr"

Assistant should:
1. Check `git status` → verify working tree state
2. Ask: "What Jira ticket is this for? (e.g., ING-342)"
3. Ask: "Type? (feat/fix/docs/refactor/etc.)"
4. Ask: "Brief description? (e.g., 'add agents to client products')"
5. Create branch: `feat/ing-342-add-agents-to-client-products`
6. Stage files: `git add file1.go file2.go file3_test.go`
7. Show staged vs unstaged summary
8. Commit: `feat: add agents to client products (ING-342)`
9. Verify remote exists and connectivity
10. Show commit count being pushed
11. Push: `git push -u origin feat/ing-342-add-agents-to-client-products`
12. Ask: "Draft PR or regular PR? Which base branch? (develop/main)"
13. Create PR with comprehensive description including ticket reference
14. Copy PR URL to clipboard and share with user

## Error Handling

- **Dirty working tree on base branch**: Ask if user wants to stash, commit, or discard changes
- **Already on feature branch**: Ask if they want to use it or create new one
- **Branch already exists**: Ask user if they want to switch to it or use a different name
- **Remote doesn't exist**: Ask user to add remote with `git remote add origin <url>`
- **Push fails**: Check if remote branch exists, may need to force push (ask first)
- **gh CLI not available**: Provide manual PR creation URL from git push output
- **Uncommitted changes**: Ask user if they want to stash, commit, or discard
- **On wrong base branch**: Ask user which base branch to use (develop/main)
- **No ticket number**: Ask user to provide Jira ticket or skip if not applicable
