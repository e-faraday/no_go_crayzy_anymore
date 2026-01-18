# Plan Continuation Prompt Template

Template for spawning mdd-executor agent to continue after a checkpoint.

---

## Template

```markdown
<objective>
Continue execution of Plan {N}: {plan-name} from feature {feature-name}
</objective>

<prior_state>
Feature file: @.claude/active/{feature-file}.md
Plan: Plan {N}: {plan-name}
Completed tasks: {completed}/{total}
</prior_state>

<completed_tasks>
| Task | Name        | Commit | Files                        |
| ---- | ----------- | ------ | ---------------------------- |
| 1    | [task name] | [hash] | [key files created/modified] |
| 2    | [task name] | [hash] | [key files created/modified] |
</completed_tasks>

<checkpoint_response>
**Type:** {checkpoint_type}
**Response:** {user_response}
</checkpoint_response>

<decision_result>
**Decision Result (if checkpoint type = decision):**
{decision_result}

**Action Result (if checkpoint type = human-action):**
{action_result}

**Note:** These results are explicitly provided so you can implement them even in fresh context. If checkpoint type is decision, use the decision result below. If checkpoint type is human-action, use the action result below.
</decision_result>

<resume_point>
**Resume from:** Task {N}
**Status:** {blocked | awaiting verification | awaiting decision}
**Previous blocker:** {specific blocker}
</resume_point>

<continuation_instructions>
1. Verify previous commits exist (check git log)
2. DO NOT redo completed tasks
3. Handle checkpoint response:
   - If human-action: Verify action worked using action result below, then continue
   - If human-verify: User approved, continue to next task
   - If decision: Implement the selected option using decision result below
4. Continue from Task {N} until plan completes or next checkpoint

**Important:** If checkpoint type is decision or human-action, the result is explicitly provided in the decision_result section above. Use that result directly in your implementation.
</continuation_instructions>
```

---

## Placeholders

| Placeholder | Source | Example |
|-------------|--------|---------|
| `{feature-name}` | From feature file title | `Dark Mode` |
| `{N}` | Plan number | `1`, `2`, `3` |
| `{plan-name}` | Plan name | `Setup`, `Implementation` |
| `{feature-file}` | Feature filename | `feature-dark-mode.md` |
| `{completed}` | Number of completed tasks | `2` |
| `{total}` | Total tasks in plan | `5` |
| `{checkpoint_type}` | Type from checkpoint | `human-verify`, `decision`, `human-action` |
| `{user_response}` | User's response | `approved`, `option-a`, `done` |
| `{decision_result}` | Decision result (if type=decision) | `Auth0 selected - use Auth0 SDK for authentication` |
| `{action_result}` | Action result (if type=human-action) | `Vercel authenticated - vercel whoami returns account` |
| `{task name}` | Task description | `Create ThemeContext` |
| `{hash}` | Commit hash | `d6fe73f` |
| `{key files}` | Modified files | `src/theme.ts, src/context.tsx` |

---

## Usage

**From orchestrator after checkpoint:**

```markdown
## CHECKPOINT RESPONSE

**Type:** {checkpoint_type}
**Response:** {user_response}

[Orchestrator spawns fresh agent with continuation template]
```

**Example continuation:**

```python
Task(
  prompt=filled_continuation_template,
  subagent_type="mdd-executor",
  description="Continue Plan 1: Setup after checkpoint"
)
```

---

## Checkpoint Response Handling

### After human-verify (approved)
- User approved the work
- Continue to next task
- No changes needed to completed work

### After human-verify (issues described)
- User found issues
- Fix issues before continuing
- May need to amend previous commit or create new fix commit

### After decision
- User selected an option
- **Decision result is explicitly provided in the continuation prompt** (see decision_result section)
- Implement the selected option using the decision result
- Continue with implementation

### After human-action
- User completed the manual step
- **Action result is explicitly provided in the continuation prompt** (see decision_result section)
- Verify the action worked using the action result
- Continue with task execution

---

**Note:** Continuation agents start with fresh context but have access to:
- Completed tasks table for verification and context
- Decision/action results explicitly provided in the prompt (for decision and human-action checkpoints)
