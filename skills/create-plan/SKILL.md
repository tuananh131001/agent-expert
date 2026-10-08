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
3. Use grilling skill to clarify the user's intention and the scope and the size(tiny - small - medium - large - very large: include the describe how the size) of the work 
3. Write `docs/<task-name>/PLAN.md` using exactly this structure:

```markdown
# <Task title>

Status: <pending|in_progress|done>

## Functional Requirement
<use format user has ability to...>
<clarify the scope of the work and non-scope of the work>

## Non-functional Requirement
<consider the application CAP Theorums, Low Latency, Scablebility>

## Core Models
<input the erd diagram here>

## High-level diagram
<use mermaid js to draw the high levels of diagrams>

## Tasks (For AI Agents to read)
- [ ] <concrete, verifiable todo>
- [ ] ...

## Specs
<List test cases here and easy for human read>

## Key Results
- <measurable outcome that shows the goal is met>
- ...
```

4. Reply with the file path and a one-paragraph summary.
