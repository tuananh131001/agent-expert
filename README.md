# agent-expert

My skills for Claude Code, Codex and Pi. Edit `skills/<name>/SKILL.md`, push, and every agent gets the update.

## Install

**Claude Code**
```
/plugin marketplace add tuananh131001/agent-expert
/plugin install agent-expert@agent-expert
```
Enable auto-update in `/plugin`. Bump `version` in `.claude-plugin/plugin.json` on each change.

**Codex / Pi**
```bash
curl -fsSL https://raw.githubusercontent.com/tuananh131001/agent-expert/main/install.sh | bash
```
Re-run to update.

## Skills

- `create-plan` — writes `docs/<task-name>/PLAN.md` (Goal, Tasks, Key Results)
