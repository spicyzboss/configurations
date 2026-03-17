# shape

Review the current plan and shape it into a perfect one. This command will:
1. Read the current plan file
2. Evaluate plan completeness and quality
3. Ask clarifying questions to fill gaps
4. Update the plan until it's ready to build

## Workflow

When the user runs this command, follow these steps:

### Step 1: Read and Analyze the Plan
- Read the entire plan file contents
- Evaluate the plan for:
  - **Clear objective**: Is the goal well-defined?
  - **Implementation approach**: Are the steps clear and actionable?
  - **Critical files**: Are the files to be modified identified?
  - **Verification**: Is there a testing/verification section?
  - **Edge cases**: Are potential issues addressed?
  - **Dependencies**: Are external dependencies or assumptions noted?

### Step 2: Determine Plan Quality
- **Plan is ready** if:
  - Objective is clear and specific
  - Implementation steps are well-defined
  - Critical files are identified
  - Verification/testing approach is described
  - No major ambiguities or missing information

- **Plan needs shaping** if any of the above are missing or unclear

### Step 3: Shape the Plan (if needed)
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

### Step 4: Confirm Readiness
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
1. Read and analyze the plan
2. **If plan needs shaping**:
   - "I reviewed the plan. I have a few questions to shape it:
     1. Which specific files need to be modified for this feature?
     2. Should we follow the existing pattern in `src/components/`?
     3. How should we verify this works - manual testing or automated tests?"
   - Gather answers
   - Update plan file with clarified details
3. **Final summary**:
   - Present the completed plan summary
   - "The plan is now ready to build when you're ready."

## Error Handling

- **No plan file exists**: Inform the user: "No plan file found. Please enter plan mode first."
- **Plan file is empty**: Ask the user what they want to plan
- **Plan file is malformed**: Ask the user to clarify what they're trying to accomplish
- **User wants more changes**: Continue asking questions and updating the plan
