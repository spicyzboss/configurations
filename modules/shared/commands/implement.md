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
   ```
   Summary: Add user authentication with OAuth2
   Description: Implement OAuth2 login flow with Google provider...
   Acceptance Criteria:
   - Users can login via Google OAuth
   - Tokens are stored securely
   - Session persists across restarts
   ```
3. Explore codebase → find `src/auth/`, tests in `tests/`
4. Generate declarative plan:
   ```
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
   ```
5. Present plan and ask: "Shall I proceed with this implementation plan?"

## Error Handling

- **Invalid ticket key**: Ask user to verify ticket number and format (PROJECT-123)
- **MCP not available**: Fall back to manual ticket input - ask user to paste ticket details
- **No acceptance criteria found**: Warn user and ask for requirements manually
- **No codebase patterns detected**: Ask user for file locations and project structure
- **Ticket not accessible**: Check if user has permissions and ticket exists
