#!/bin/bash
# Shape Ship stop hook — runs after every turn

# Guard against recursive invocation
[ -n "$SHAPESHIP_STOP_HOOK_ACTIVE" ] && exit 0
export SHAPESHIP_STOP_HOOK_ACTIVE=1

# Run verify.sh if it exists
if [ -f ./verify.sh ]; then
  ./verify.sh 2>&1 | tail -30
fi

# Doc-drift check: warn if source files were committed without their co-located AGENTS.md
LAST_COMMITTED=$(git diff HEAD~1 HEAD --name-only 2>/dev/null || true)
if [ -n "$LAST_COMMITTED" ]; then
  while IFS= read -r f; do
    case "$f" in
      *.ts|*.tsx|*.js|*.jsx|*.py|*.go|*.rs)
        DIR=$(dirname "$f")
        if [ -f "$DIR/AGENTS.md" ]; then
          if ! echo "$LAST_COMMITTED" | grep -q "^${DIR}/AGENTS.md$"; then
            echo "Warning: $DIR/AGENTS.md may need updating — $f was committed without it" >&2
          fi
        fi
        ;;
    esac
  done <<< "$LAST_COMMITTED"
fi

exit 0
