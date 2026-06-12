#!/usr/bin/env bash
set -euo pipefail

# Flattens category-organized skills under ~/.claude/skills so Claude Code
# discovers them. Adapted from mattpocock/skills' scripts/link-skills.sh
# to operate in-place: category directories (e.g. engineering/, productivity/)
# stay as the source of truth, and each nested skill is symlinked to the
# top level where Claude Code expects it.
#
# Layout assumed:
#   ~/.claude/skills/<category>/<skill>/SKILL.md   (source)
# Result:
#   ~/.claude/skills/<skill> -> <category>/<skill>  (symlink)
#
# Already-flat skills (~/.claude/skills/<skill>/SKILL.md) are left alone.

SKILLS_DIR="$HOME/.claude/skills"

if [ ! -d "$SKILLS_DIR" ]; then
  echo "error: $SKILLS_DIR does not exist" >&2
  exit 1
fi

# Find SKILL.md files exactly two levels deep (category/skill/SKILL.md).
# -mindepth/-maxdepth 3 from $SKILLS_DIR means three path components below it.
find "$SKILLS_DIR" -mindepth 3 -maxdepth 3 -name SKILL.md \
  -not -path '*/node_modules/*' -not -path '*/deprecated/*' -print0 |
while IFS= read -r -d '' skill_md; do
  src="$(dirname "$skill_md")"      # e.g. ~/.claude/skills/engineering/diagnose
  name="$(basename "$src")"          # e.g. diagnose
  target="$SKILLS_DIR/$name"

  if [ -e "$target" ] && [ ! -L "$target" ]; then
    echo "skip $name: $target already exists as a real path" >&2
    continue
  fi

  # Symlink uses a path relative to $SKILLS_DIR so it stays valid if the
  # whole ~/.claude tree is moved.
  rel="${src#$SKILLS_DIR/}"
  ln -sfn "$rel" "$target"
  echo "linked $name -> $rel"
done
