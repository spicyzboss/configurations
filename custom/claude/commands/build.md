# build

Execute the current plan using parallel agents wherever possible. Reads the plan's todo groups and launches multiple agents concurrently for each group, then proceeds to the next group once all agents finish.

## Workflow

### Step 1: Read the Plan

- Read the current plan file
- If no plan file is found, ask the user to reference one or enter plan mode first
- If todos are not grouped (no `g<N>-` prefixes), suggest running `/extract` first to identify parallelism, then ask the user if they want to proceed sequentially anyway

### Step 2: Identify Groups

- Collect all todos, grouped by their `g<N>` prefix
- Sort groups numerically (g1 before g2 before g3…)
- Todos without a group prefix are treated as a single sequential group at the end

### Step 3: Execute Group by Group

For each group in order:

1. **Mark all todos in the group as `in_progress`**
2. **Launch one agent per todo** using the Task tool with `subagent_type: "generalPurpose"`
   - Each agent gets a detailed, self-contained prompt (see Prompt Guidelines below)
   - All agents in the same group are launched in a **single message** (parallel tool calls)
3. **Wait for all agents in the group to finish** before proceeding to the next group
4. **Mark completed todos** after each agent reports back
5. **Handle failures** before moving on (see Error Handling below)

Repeat until all groups are done.

### Step 4: Verify

After all groups complete:
- Run any verification steps mentioned in the plan (typecheck, lint, tests)
- Report the final status to the user

## Prompt Guidelines for Agents

Each agent must be self-contained — it has no access to the conversation history. Include in every agent prompt:

- **Full absolute paths** for every file to read or modify
- **Exact content** to write, or precise diffs to apply
- **The reason** for each change (helps the agent make correct decisions if it hits edge cases)
- **A verification step** at the end (e.g. run `tsc --noEmit`, confirm file exists)
- **What to report back** — the agent's return value is the only output you see

Avoid vague instructions like "update the config" — be explicit about what the final state should look like.

## Important Notes

- **One agent per todo** — do not bundle multiple todos into one agent unless they are trivially small and touch the same file
- **Never run agents from different groups at the same time** — group ordering encodes real dependencies
- **Always mark todos in_progress before launching** — this makes progress visible in the UI
- **Read the plan fully before launching any agent** — some plans have prerequisite notes or constraints outside the todos
- **If a plan has no group prefixes**, default to launching one agent per todo sequentially, not in parallel

## Error Handling

- **Agent reports an error**: Mark the todo as blocked, report the error to the user, and ask how to proceed before continuing
- **File conflict detected**: Stop the group, resolve the conflict manually or with a single agent, then re-run the affected group
- **Verification fails after a group**: Do not proceed to the next group — diagnose and fix first
- **Plan file not found**: Ask the user to reference a plan file or enter plan mode
- **No group prefixes on todos**: Suggest running `/extract` first, or ask user to confirm sequential execution
