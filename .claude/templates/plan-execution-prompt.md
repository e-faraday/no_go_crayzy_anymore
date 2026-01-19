# Plan Execution Prompt Template

Template for spawning mdd-executor agent. The agent contains all execution expertise - this template provides execution context only.

---

## Template

```markdown
<execution_context>

**Feature:** {feature-name}
**Plan:** Plan {N}: {plan-name}
**Feature File:** @.claude/active/{feature-file}.md

**Context Files:**
@.claude/active/{feature-file}.md
@.claude/templates/feature.md (for structure reference)

**Your responsibilities:**
- Execute all tasks in Plan {N}
- Commit each task atomically using format: `{type}(plan-{N}): {description}`
- Follow MDD commit formats (see auto-commit-task.sh for reference)
- Update progress log after each task
- Update checkpoint when plan completes
- Report completion with commit hashes

**Execution Guidelines:**
- Each task should be committed individually
- Use scripts/auto-commit-task.sh if available (with AUTO_COMMIT=true)
- Mark checkboxes as complete: `- [x] Task name`
- Document deviations in progress log
- Handle authentication gates by returning checkpoints

</execution_context>

<downstream_consumer>
Output consumed by orchestrator (user or automated)
Execution results must include:
- Commit hashes for each task
- Progress log updates
- Checkpoint updates
- Completion status
</downstream_consumer>

<quality_gate>
Before returning PLAN COMPLETE:
- [ ] All tasks in Plan {N} executed
- [ ] Each task committed individually
- [ ] All checkboxes marked complete
- [ ] Progress log updated
- [ ] Checkpoint updated
- [ ] All deviations documented
- [ ] Completion format returned
</quality_gate>
```

---

## Placeholders

| Placeholder | Source | Example |
|-------------|--------|---------|
| `{feature-name}` | From feature file title | `Dark Mode` |
| `{N}` | Plan number from feature file | `1`, `2`, `3` |
| `{plan-name}` | Plan name from feature file | `Setup`, `Implementation` |
| `{feature-file}` | Feature filename | `feature-dark-mode.md` |

---

## Usage

**From orchestrator (manual):**
```markdown
@feature-dark-mode.md Help me implement Plan 1

[Orchestrator olarak çalışırsınız]
1. Plan 1'i parse edin
2. Task tool ile subagent spawn edin:
   Task(
     prompt=filled_template,
     subagent_type="mdd-executor",
     description="Execute Plan 1: Setup"
   )
3. Subagent döntüğünde sonuçları kontrol edin
4. Commit'leri doğrulayın
```

**From orchestrator (automated - future):**
```python
Task(
  prompt=filled_template,
  subagent_type="mdd-executor",
  description="Execute Plan {N}: {plan-name}"
)
```

---

## Continuation

For checkpoints, spawn fresh agent with plan-continuation-prompt.md template.

---

**Note:** Execution methodology, deviation handling, checkpoint protocols, and commit strategies are baked into the mdd-executor agent. This template only passes context.
