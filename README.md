# agent-expert

My skills for Claude Code, Codex and Pi. Edit `skills/<name>/SKILL.md`, push, and every agent gets the update.

## Install

**Claude Code**
```
/plugin marketplace add tuananh131001/agent-expert
/plugin install agent-expert@agent-expert
```
Enable auto-update in `/plugin`.

**Codex / Pi**
```bash
curl -fsSL https://raw.githubusercontent.com/tuananh131001/agent-expert/main/install.sh | bash
```
Re-run to update.

## Skills

- `create-plan` — writes `docs/<task-name>/PLAN.md` (Goal, Tasks, Key Results)
- `grilling` — interviews you relentlessly about a plan, decision, or idea until you share an understanding. It works through the decisions as a design tree, asking one round of numbered questions at a time, each with a recommended answer
- `grill-me` — manual-only shortcut that runs `grilling` (the model can't invoke it on its own)
- `podcast-to-article` — turns a podcast episode (Spotify / Apple / RSS / audio link) into a long-form article as PDF + EPUB + Markdown. Transcribes locally with Whisper; needs `python3`, `ffmpeg`, `pandoc`, `pdftoppm` (poppler) and `agent-browser`
- `pr` — writes a PR body from a template: a Summary shown as a diagram, diff sketch or tree, before/after Evidence, and Merge Danger (one-way or two-way door, blast radius). Adapted from Humanlayer's `show-me` skill
- `teach` — manual-only tutor that turns the current directory into a learning workspace across sessions: a mission, curated resources, HTML lessons and reference sheets, and learning records that track progress
- `write-down` — manual-only handoff that compacts the current conversation into a document in the OS temp directory for a fresh agent to pick up, with suggested skills and secrets redacted. Pass what the next session is for to tailor it
