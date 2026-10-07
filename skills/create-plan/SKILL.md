---
name: create-plan
description: Create a plan for a task and write it to docs/<task-name>/PLAN.md with Goal, Tasks (todos) and Key Results. Use when the user asks to plan, scope or break down a task.
argument-hint: [instruction]
---

# Create plan

Create a plan for the user's instruction and write it to `docs/<task-name>/PLAN.md`.

Instruction: $ARGUMENTS

## Steps

1. Pick a short kebab-case `<task-name>` from the instruction.
2. Clarify concerns before writing. Use the agent's ask-the-user tool when one exists
   (`AskUserQuestion` in Claude Code, `ask_user_question` in Pi); otherwise ask in chat
   and wait for the answer. Ask only about decisions that change the plan.
3. Write `docs/<task-name>/PLAN.md` using exactly this structure:

```markdown
# <Task title>

Status: <pending|in_progress|done>

## Goal
<what this task achieves and why, 1-3 sentences>

## Tasks
- [ ] <concrete, verifiable todo>
- [ ] ...

## Key Results
- <measurable outcome that shows the goal is met>
- ...
```

4. Reply with the file path and a one-paragraph summary.
