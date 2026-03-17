# review

Review changes against main branch. This command will:
1. Update the main branch to the latest
2. Show diff against main
3. Perform a deep review of the changes

## Workflow

When the user runs this command, follow these steps:

### Step 1: Update Main Branch
- Fetch latest main: `git fetch origin main:main`
- If fetch fails, try: `git checkout main && git pull && git checkout -`
- If no remote named `origin`, check for other remotes and warn user

### Step 2: Show Diff Summary
- Run `git diff main...HEAD --stat` to show files changed and summary stats
- Run `git log main..HEAD --oneline` to show commits being reviewed
- Report: number of files changed, insertions, deletions, and commit count

### Step 3: Generate and Review Full Diff
- Run `git diff main...HEAD` to generate the full diff
- Analyze the changes deeply:
  - **File types**: What kinds of files were changed (source code, config, docs, tests)?
  - **Change types**: Are these new features, bug fixes, refactors, or other changes?
  - **Scope impact**: Which components or modules are affected?
  - **Potential issues**:
    - Missing tests for new features
    - Inconsistent patterns with existing codebase
    - Potential security concerns (XSS, SQL injection, etc.)
    - Breaking changes or API modifications
    - Performance considerations
    - Error handling gaps
    - Documentation that needs updating
  - **Positive highlights**: Good patterns, tests, documentation

### Step 4: Present Review Findings
- Organize review into sections:
  - **Summary**: High-level overview of changes
  - **Files Changed**: List with brief descriptions
  - **Key Observations**: Important findings
  - **Potential Issues**: Concerns to address
  - **Suggestions**: Recommendations for improvement
- Use code blocks for specific examples when relevant

## Important Notes

- **Always update main first** – ensures review is against latest base
- **Use three-dot diff** (`main...HEAD`) – shows changes from merge base to HEAD, not all differences
- **Deep review not just diff** – provide analysis and insights, not just raw output
- **Be constructive** – highlight good work alongside issues
- **Consider context** – understand the purpose of the changes
- **Check for tests** – new features should have test coverage
- **Look for consistency** – changes should follow existing patterns
- **Security mindset** – watch for common vulnerabilities

## Example Interaction

User: "review"

Assistant should:
1. Update main: `git fetch origin main:main`
2. Show summary: "5 files changed, 234 insertions(+), 45 deletions(-), 3 commits"
3. Show commits: "abc1234 feat: add user authentication"
4. Generate diff: `git diff main...HEAD`
5. Present review:
   ```
   ## Summary
   This PR adds user authentication with OAuth2 integration.

   ## Files Changed
   - `src/auth/oauth.ts` (new) - OAuth2 flow implementation
   - `src/middleware/auth.go` - Authentication middleware
   - `tests/auth_test.go` - Tests for auth module
   - `README.md` - Documentation updates

   ## Key Observations
   - Clean separation of concerns with dedicated auth module
   - Good test coverage for OAuth flow

   ## Potential Issues
   - `oauth.ts:45` - Token storage uses localStorage, consider secure storage
   - Missing rate limiting on OAuth callback endpoint
   - No unit tests for error paths in middleware

   ## Suggestions
   - Consider adding refresh token rotation
   - Document OAuth environment variables in README
   ```

## Error Handling

- **No remote named origin**: Check for other remotes (`git remote`) and warn user to add origin or use correct remote name
- **Fetch fails**: Report network error and suggest retry or check VPN
- **No diff (HEAD == main)**: Inform user there are no changes to review
- **No main branch**: Ask user which branch to use as base (e.g., `master`, `develop`)
- **Detached HEAD**: Warn and suggest checking out a branch first
