{ pkgs, config, ... }:

let
  personalPublicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICeyy6f27Lzkile5KU4Mu6ZX2YPp9FHPDxI7WexvJwl+";
  work100xPublicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOUFapELtvauLRoMSO59nuKFrfpIES3I8nh/F0vZepVQ";
in

{
  ".ssh/spicyzboss.pub" = {
    text = personalPublicKey;
  };
  ".ssh/boss-spicyz100x.pub" = {
    text = work100xPublicKey;
  };
  ".hushlogin" = {
    text = "";
  };
  ".config/1Password/ssh/agent.toml" = {
    text = ''
      [[ssh-keys]]
      vault = "Private"
      item = "spicyzboss"

      [[ssh-keys]]
      vault = "100x"
      item = "boss-spicyz100x"
    '';
  };

  ".cursor/commands/commit.md" = {
    text = ''
# commit

Commit current changes. This command will:
1. Check git status and current branch
2. Show staged vs unstaged summary
3. Stage changes (excluding secrets and .env)
4. Infer scope from project type
5. Detect commit type from changed files
6. Create a conventional commit message
7. Commit to the current branch

No new branch or PR is created; work stays on the branch you are on.

## Workflow

When the user runs this command, follow these steps:

### Step 1: Check Status
- Run `git status` to see current branch and changed files
- If working tree is clean, tell the user and stop
- If in detached HEAD state, warn and ask whether to create or checkout a branch before committing

### Step 2: Show Staged vs Unstaged
- Run `git diff --cached --stat` to show staged changes
- Run `git diff --stat` to show unstaged changes
- Present summary to user so they know what will be committed

### Step 3: Stage Changes
- Stage all relevant changes: `git add .` or explicit paths
- Do **not** stage `.env` or any file that may contain secrets or credentials; if any appear in status, skip them and warn the user
- If there are many files or changes look unrelated, optionally ask the user to confirm staging
- If many changes, offer to show diff preview: `git diff --cached`

### Step 4: Infer Scope from Project Type
- **Rust**: Read `Cargo.toml` and use `package.name` as scope
- **Node**: Read `package.json` and use `name` field as scope
- **Python**: Use project directory name or infer from `setup.py`/`pyproject.toml`
- **Fallback**: Use current directory name as scope
- If scope inference fails, use `{scope}` placeholder in proposed message

### Step 5: Detect Commit Type
- **Test files** (`*_test.go`, `*.test.ts`, `test_*.py`, `__tests__/`) → `test:`
- **Documentation** (`*.md`, `docs/`, `README*`) → `docs:`
- **CI/CD** (`.github/`, `.gitlab-ci.yml`, `Dockerfile`, `docker-compose.yml`) → `ci:`
- **Dependencies** (`package-lock.json`, `Cargo.lock`, `go.sum`) → `chore(deps):`
- **Config files** (`*.config.*`, `*.json` not package.json, `*.yaml`, `*.toml`) → `chore(config):`
- **Source code changes** → `feat:` for new features, `fix:` for bug fixes

### Step 6: Commit Message
- Build a single-line conventional commit message: `type(scope): message`
- Types: `feat`, `fix`, `docs`, `style`, `refactor`, `test`, `chore`, `perf`, `ci`, `build`
- Scope: inferred from project type (see Step 4)
- Subject only, short and lowercase; no body
- Infer type, scope, and message from diffs, or ask the user if unclear
- If the working tree clearly has multiple unrelated changes, say so and suggest splitting into separate commits or manual staging

### Step 7: Commit
- Run: `git commit -m "<message>"`
- If commit fails (e.g. pre-commit hook), report the error

## Important Notes

- **Check git status first** – do not assume what needs to be committed
- **Show staged vs unstaged** – let user see what will be committed
- **One logical change per commit** – if changes are unrelated, suggest splitting
- **Never commit secrets** – skip `.env` and any file that may contain credentials
- **Conventional commits** – use `type(scope): message`, subject line only, short and lowercase
- **Scope inference** – automatically detect scope from project configuration
- **Type detection** – infer commit type from changed files

## Example Interaction

User: "commit"

Assistant should:
1. Run `git status` → list branch and changed files
2. Show staged vs unstaged summary with stats
3. Stage files (excluding .env), e.g. `git add .` or explicit paths
4. Infer scope: read `Cargo.toml` → `myproject`
5. Detect type: see test files → `test:`
6. Propose message: `test(myproject): add unit tests for auth module`
7. Run `git commit -m "test(myproject): add unit tests for auth module"`

## Error Handling

- **Nothing to commit (clean working tree)**: Exit with a short message; do not run commit
- **Unstaged or untracked files after staging**: Remind user they can add or ignore them in a follow-up
- **Commit rejected** (e.g. pre-commit hook): Report the error
- **Detached HEAD**: Warn and ask whether to create or checkout a branch before committing
- **Scope inference fails**: Use directory name or `{scope}` placeholder and ask user to verify
    '';
  };

  ".cursor/commands/implement.md" = {
    text = ''
# implement

Plan implementation of a Jira card using fetched details. This command will:
1. Fetch Jira ticket details using Atlassian MCP
2. Parse summary, description, and acceptance criteria
3. Explore codebase patterns and structure
4. Generate a declarative implementation plan
5. Present plan for user confirmation

## Workflow

When the user runs this command, follow these steps:

### Step 1: Get Jira Ticket
- Ask user for Jira ticket key (e.g., ING-342, PROJ-123)
- Use MCP tool: `mcp__atlassian__jira__getIssue` with the ticket key
- Extract ticket details:
  - `key` - Ticket identifier
  - `fields.summary` - Title
  - `fields.description` - Full description
  - `fields.priority` - Priority level
  - `fields.labels` - Tags
  - Acceptance criteria (may be in description or custom fields)

### Step 2: Parse Requirements
- Parse description for:
  - Functional requirements (what the feature should do)
  - Technical specifications (how it should be implemented)
  - Dependencies and related work
- Extract acceptance criteria (DoD - Definition of Done)
- Identify test scenarios from acceptance criteria

### Step 3: Explore Codebase
- Identify project type (Rust, Node, Python, Go)
- Find relevant directories:
  - Where new code should go (src/, lib/, app/, etc.)
  - Existing similar implementations to reference
  - Test directory structure
  - Code style conventions

### Step 4: Generate Declarative Plan
Create a structured plan with these sections:

**Requirements**
- What needs to be built (functional requirements)
- Technical constraints and considerations
- Dependencies on other systems/modules

**Files to Create/Modify**
- Specific file paths with purpose for each
- Group by type (source, tests, config, docs)

**Implementation Steps**
- Clear, actionable steps
- Ordered by dependencies
- Focus on WHAT, not HOW

**Test Plan**
- Unit tests for individual components
- Integration tests for flows
- E2E tests for complete scenarios
- Map tests back to acceptance criteria

**Clean Code Checklist**
- SOLID principles
- DRY (Don't Repeat Yourself)
- Meaningful names for variables, functions, types
- Single responsibility per function/module
- Error handling patterns
- Documentation needs

### Step 5: Present Plan
- Show formatted plan to user
- Ask for confirmation before proceeding
- Offer to adjust approach if needed

## Important Notes

- **Declarative over imperative** - Describe WHAT needs to be done, not HOW to do it
- **Follow existing patterns** - Match codebase conventions for structure and style
- **Clean code principles** - SOLID, DRY, meaningful names, single responsibility
- **Test coverage** - Unit tests for logic, integration for flows, E2E for user journeys
- **Small PRs** - One logical change per PR, keep it focused
- **Documentation** - Update docs alongside code changes
- **Ask before proceeding** - Always get user confirmation on the plan

## Example Interaction

User: "implement ING-342"

Assistant should:
1. Call `mcp__atlassian__jira__getIssue` with key "ING-342"
2. Parse ticket details:
   ````
   Summary: Add user authentication with OAuth2
   Description: Implement OAuth2 login flow with Google provider...
   Acceptance Criteria:
   - Users can login via Google OAuth
   - Tokens are stored securely
   - Session persists across restarts
   ````
3. Explore codebase → find `src/auth/`, tests in `tests/`
4. Generate declarative plan:
   ````
   ## Requirements
   - OAuth2 login flow with Google provider
   - Secure token storage
   - Persistent session management

   ## Files to Create
   - `src/auth/oauth.rs` - OAuth2 flow implementation
   - `src/auth/session.rs` - Session persistence
   - `src/middleware/auth.rs` - Auth middleware
   - `tests/auth/oauth_test.rs` - OAuth flow tests
   - `tests/auth/session_test.rs` - Session tests

   ## Implementation Steps
   1. Create OAuth2 client with Google provider configuration
   2. Implement callback handler for token exchange
   3. Add session storage with secure encryption
   4. Create authentication middleware for protected routes
   5. Add logout functionality

   ## Test Plan
   - Unit: OAuth2 client configuration
   - Unit: Token exchange logic
   - Integration: Full login flow
   - Unit: Session storage operations
   - Integration: Session persistence across restarts
   - E2E: Login → access protected resource → logout

   ## Clean Code Checklist
   - Separate concerns (OAuth, session, middleware)
   - Use Result types for error handling
   - Avoid hardcoded secrets (use env vars)
   - Add doc comments for public APIs
   - Keep functions focused and small
   - Use descriptive type names
   ````
5. Present plan and ask: "Shall I proceed with this implementation plan?"

## Error Handling

- **Invalid ticket key**: Ask user to verify ticket number and format (PROJECT-123)
- **MCP not available**: Fall back to manual ticket input - ask user to paste ticket details
- **No acceptance criteria found**: Warn user and ask for requirements manually
- **No codebase patterns detected**: Ask user for file locations and project structure
- **Ticket not accessible**: Check if user has permissions and ticket exists
    '';
  };

  ".cursor/commands/pr.md" = {
    text = ''
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
  ````
  {type}: {short description}

  - {bullet point describing change 1}
  - {bullet point describing change 2}
  - {bullet point describing change 3}
  ````
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
    '';
  };

  ".cursor/commands/pr-work.md" = {
    text = ''
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
  - Brief feature description in kebab-case (2-5 words)
- Create branch name in format: `{ticket}-{kebab-case-description}`
  - Example: `ing-342-add-agents-to-client-products`
  - Example: `ing-400-fix-login-bug`
  - Example: `ing-500-update-api-documentation`
- Run: `git checkout -b {branch-name}`

### Step 4: Stage Changes
- Review the changed files with the user
- Stage all relevant files: `git add {file1} {file2} ...`
- Or stage all changes: `git add .` (if user confirms)
- **Do not stage** `.env` or any file containing secrets

### Step 5: Commit Changes
- Show summary of staged vs unstaged changes
- Create a commit message following conventional commits format with ticket:
  ````
  {type}: {short description} ({ticket})

  - {bullet point describing change 1}
  - {bullet point describing change 2}
  - {bullet point describing change 3}
  ````
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
- PR title: Format as `[{branch-target}][{branch-prefix-type}]: {description}`
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
3. Ask: "Brief description? (e.g., 'add agents to client products')"
4. Create branch: `ing-342-add-agents-to-client-products`
5. Stage files: `git add file1.go file2.go file3_test.go`
6. Show staged vs unstaged summary
7. Commit: `feat: add agents to client products (ING-342)`
8. Verify remote exists and connectivity
9. Show commit count being pushed
10. Push: `git push -u origin ing-342-add-agents-to-client-products`
11. Ask: "Draft PR or regular PR? Which base branch? (develop/main)"
12. Create PR with comprehensive description including ticket reference
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
- **No ticket number**: Ask user to provide Jira ticket or skip if not applicable
    '';
  };

  ".cursor/commands/push.md" = {
    text = ''
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
    '';
  };

  ".cursor/commands/review.md" = {
    text = ''
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
   ````
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
   ````

## Error Handling

- **No remote named origin**: Check for other remotes (`git remote`) and warn user to add origin or use correct remote name
- **Fetch fails**: Report network error and suggest retry or check VPN
- **No diff (HEAD == main)**: Inform user there are no changes to review
- **No main branch**: Ask user which branch to use as base (e.g., `master`, `develop`)
- **Detached HEAD**: Warn and suggest checking out a branch first
    '';
  };

  ".cursor/commands/shape.md" = {
    text = ''
# shape

Review the current plan and shape it into a perfect one. This command will:
1. Find and read the current plan file
2. Evaluate plan completeness and quality
3. Ask clarifying questions to fill gaps
4. Update the plan until it's ready to build

## Workflow

When the user runs this command, follow these steps:

### Step 1: Locate Plan File
- Find the most recent plan file in `/Users/spicyz/.claude/plans/*.md`
- If no plan file exists, inform the user and exit
- If multiple plan files exist, use the most recently modified one

### Step 2: Read and Analyze the Plan
- Read the entire plan file contents
- Evaluate the plan for:
  - **Clear objective**: Is the goal well-defined?
  - **Implementation approach**: Are the steps clear and actionable?
  - **Critical files**: Are the files to be modified identified?
  - **Verification**: Is there a testing/verification section?
  - **Edge cases**: Are potential issues addressed?
  - **Dependencies**: Are external dependencies or assumptions noted?

### Step 3: Determine Plan Quality
- **Plan is ready** if:
  - Objective is clear and specific
  - Implementation steps are well-defined
  - Critical files are identified
  - Verification/testing approach is described
  - No major ambiguities or missing information

- **Plan needs shaping** if any of the above are missing or unclear

### Step 4: Shape the Plan (if needed)
If the plan needs shaping, ask targeted questions to fill gaps:

**For unclear objectives:**
- "What is the primary goal of this change?"
- "What problem are we trying to solve?"
- "What does success look like?"

**For missing implementation details:**
- "Which files need to be modified?"
- "Should we follow any existing patterns in the codebase?"
- "Are there any constraints or requirements I should know about?"

**For missing verification:**
- "How should we test/verify this works?"
- "Are there existing tests we should run?"
- "What's the expected behavior after this change?"

**For edge cases or concerns:**
- "Are there any edge cases we should handle?"
- "Could this affect other parts of the system?"
- "Should we maintain backward compatibility?"

Ask up to 3-5 targeted questions at a time. Gather answers, then update the plan file with the clarified information.

### Step 5: Confirm Readiness
Once shaping is complete (or if plan was already ready):
- Present a summary of the final plan
- State that the plan is ready to build
- Do NOT proceed to build - let the user decide when to build

## Important Notes

- **Always read the plan file first** - do not assume what needs to be done
- **Ask targeted questions** - focus on specific gaps rather than general "is this okay?"
- **Batch your questions** - ask 3-5 related questions at once, not one at a time
- **Update the plan file** - incorporate answers into the plan document
- **Be thorough but efficient** - ask enough to be confident, but do not over-elaborate
- **Respect the user's time** - if the plan is already clear, do not add unnecessary questions
- **Do not build** - this command only shapes the plan, building is a separate step

## Example Interaction

User: "shape"

Assistant should:
1. Find plan file at `/Users/spicyz/.claude/plans/feature-x.md`
2. Read and analyze the plan
3. **If plan needs shaping**:
   - "I reviewed the plan. I have a few questions to shape it:
     1. Which specific files need to be modified for this feature?
     2. Should we follow the existing pattern in `src/components/`?
     3. How should we verify this works - manual testing or automated tests?"
   - Gather answers
   - Update plan file with clarified details
4. **Final summary**:
   - Present the completed plan summary
   - "The plan is now ready to build when you're ready."

## Error Handling

- **No plan file exists**: Inform the user: "No plan file found in `/Users/spicyz/.claude/plans/`. Please enter plan mode first."
- **Plan file is empty**: Ask the user what they want to plan
- **Plan file is malformed**: Ask the user to clarify what they're trying to accomplish
- **User wants more changes**: Continue asking questions and updating the plan
    '';
  };
}
