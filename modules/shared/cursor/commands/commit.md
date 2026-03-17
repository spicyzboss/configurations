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
