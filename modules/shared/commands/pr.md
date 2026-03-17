# pr

Create a pull request following best practices for open-source projects. This command will guide you through:
1. Checking git status and verifying clean working tree
2. Creating a feature branch (if not already on one)
3. Staging and committing changes
4. Pushing to remote
5. Creating a PR with GitHub CLI

## Workflow

When the user requests to create a PR, follow these steps:

### Step 1: Check Current Status
- Run `git status` to see what files have been modified
- Check if we're on the correct base branch (usually `main`)
- **Pre-flight check**: If working tree is dirty (uncommitted changes) on base branch, ask if user wants to stash or commit first
- Identify all changed files (modified, added, deleted)

### Step 2: Create Feature Branch (if needed)
- Check if already on a feature branch (not main/master/develop)
- If on feature branch, ask if they want to use it or create a new one
- If on base branch, ask for:
  - Type prefix: `feat`, `fix`, `docs`, `refactor`, `test`, `chore`, `perf`, `ci`
  - Brief feature description in kebab-case (2-5 words)
- Create branch name in format: `{type}/{kebab-case-description}`
  - Example: `feat/add-user-authentication`
  - Example: `fix/login-bug`
  - Example: `docs/update-readme`
- Run: `git checkout -b {branch-name}`

### Step 3: Stage Changes
- Review the changed files with the user
- Stage all relevant files: `git add {file1} {file2} ...`
- Or stage all changes: `git add .` (if user confirms)
- **Do not stage** `.env` or any file containing secrets

### Step 4: Commit Changes
- Show summary of staged vs unstaged changes
- Create a commit message following conventional commits format:
  ```
  {type}: {short description}

  - {bullet point describing change 1}
  - {bullet point describing change 2}
  - {bullet point describing change 3}
  ```
- Types: `feat`, `fix`, `docs`, `refactor`, `test`, `chore`, `perf`, `ci`, `style`, `build`
- If many changes, offer to show diff preview before committing
- Run: `git commit -m "{commit message}"`

### Step 5: Verify Remote Before Push
- Check if remote exists: `git remote get-url origin`
- If remote doesn't exist, ask user to add it first
- Verify connectivity: `git ls-remote origin`

### Step 6: Push to Remote
- Show commit count being pushed (e.g., "Pushing 3 commits: abc123..def456")
- Push the branch: `git push -u origin {branch-name}`
- Verify the push was successful

### Step 7: Create Pull Request
- Ask if user wants a draft PR or regular PR
- Use GitHub CLI: `gh pr create`
- PR title: Same as commit message first line
- PR body should include:
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
  ```
- Base branch: Usually `main` (ask if not detected)
- Run: `gh pr create --title "{title}" --body "{body}" --base main`
- If draft: add `--draft` flag

### Step 8: Confirm PR Created
- Share the PR URL with the user
- Copy PR URL to clipboard (macOS: `pbcopy`, Linux: `xclip -selection clipboard`)
- Confirm all steps completed successfully

## Important Notes

- **Pre-flight check**: Verify working directory is clean before branching from base
- **Detect existing feature branch**: Skip branch creation if already on one
- **Verify remote exists**: Check `git remote` before pushing
- **Draft PR option**: Allow users to create draft PRs for work-in-progress
- **Copy PR link**: Store PR URL in clipboard for easy sharing
- **Ask for confirmation** before creating branch or committing if context is unclear
- **Write descriptive commit messages** - future you will thank you
- **Test before committing** - ensure tests pass and linter is clean
- **Check PR description** - make sure it accurately describes changes

## Example Interaction

User: "create branch and commit and push to remote and create pr"

Assistant should:
1. Check `git status` → verify working tree state
2. Ask: "What type of change is this? (feat/fix/docs/refactor/test/chore)"
3. Ask: "Brief description? (e.g., 'add user authentication')"
4. Create branch: `feat/add-user-authentication`
5. Stage files: `git add file1.ts file2.ts file3.test.ts`
6. Show staged vs unstaged summary
7. Commit with detailed message
8. Verify remote exists and connectivity
9. Show commit count being pushed
10. Push: `git push -u origin feat/add-user-authentication`
11. Ask: "Draft PR or regular PR?"
12. Create PR with comprehensive description
13. Copy PR URL to clipboard and share with user

## Error Handling

- **Dirty working tree on base branch**: Ask if user wants to stash, commit, or discard changes
- **Already on feature branch**: Ask if they want to use it or create new one
- **Branch already exists**: Ask user if they want to switch to it or use a different name
- **Remote doesn't exist**: Ask user to add remote with `git remote add origin <url>`
- **Push fails**: Check if remote branch exists, may need to force push (ask first)
- **gh CLI not available**: Provide manual PR creation URL from git push output
- **Uncommitted changes**: Ask user if they want to stash, commit, or discard
- **On wrong base branch**: Ask user which base branch to use (main/master/develop)
