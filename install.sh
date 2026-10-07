#!/usr/bin/env bash
# Clone (or update) this repo and link every skill into ~/.agents/skills,
# the shared skills folder read by Codex and Pi.
# Re-run any time to pull the latest version.
set -euo pipefail

REPO_URL="${AGENT_EXPERT_REPO:-https://github.com/tuananh131001/agent-expert.git}"
DEST="${AGENT_EXPERT_HOME:-$HOME/.local/share/agent-expert}"
SKILLS_DIR="${AGENTS_SKILLS_DIR:-$HOME/.agents/skills}"

if [ -d "$DEST/.git" ]; then
  git -C "$DEST" pull --ff-only --quiet
else
  git clone --quiet "$REPO_URL" "$DEST"
fi

mkdir -p "$SKILLS_DIR"
for skill in "$DEST"/skills/*/; do
  name="$(basename "$skill")"
  target="$SKILLS_DIR/$name"
  if [ -e "$target" ] && [ ! -L "$target" ]; then
    echo "skip $name: $target exists and is not a symlink" >&2
    continue
  fi
  ln -sfn "${skill%/}" "$target"
  echo "linked $name -> $target"
done
