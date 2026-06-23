#!/bin/bash
# verify.sh — Deterministic verification script
# Run this before every commit. It must pass before code can be merged.
# Customise for your project's stack.
#
# IMPORTANT: This script must do real work.
# An empty or all-commented script gives false confidence — the Stop hook
# runs this after every turn and will always show green.
#
# IMPORTANT: This is a GATE, not a launcher. It must run to completion and
# exit. Never start a long-running dev server here — the Stop hook runs this
# after every turn and a blocking server would hang it forever. To launch the
# app with seeded state for /qa functional execution, use run.sh instead.
#
# Uncomment at least one check below, or replace this script entirely.

set -e

echo "Running verification..."

CONFIGURED=false

# 1. Lint
# echo "  Linting..."
# npm run lint
# CONFIGURED=true

# 2. Type check
# echo "  Type checking..."
# npx tsc --noEmit
# CONFIGURED=true

# 3. Unit tests
# echo "  Running tests..."
# npm test
# CONFIGURED=true

# 4. Build check
# echo "  Building..."
# npm run build
# CONFIGURED=true

# 5. Scope JSON validation (always runs — no configuration needed)
SCOPE_VALID=true
for scope in cycles/*/scopes/*.json; do
  [ -f "$scope" ] || continue
  type=$(jq -r '.scope_type // empty' "$scope" 2>/dev/null)
  if [ -n "$type" ]; then
    case "$type" in
      frontend|backend|full-stack|infra|bug) ;;
      *) echo "  Invalid scope_type '$type' in $scope"; SCOPE_VALID=false ;;
    esac
  fi
  status=$(jq -r '.status // empty' "$scope" 2>/dev/null)
  if [ -n "$status" ]; then
    case "$status" in
      not_started|in_progress|done|blocked) ;;
      *) echo "  Invalid status '$status' in $scope"; SCOPE_VALID=false ;;
    esac
  fi
done
if [ "$SCOPE_VALID" = false ]; then
  echo "Scope JSON validation failed."
  exit 1
fi
CONFIGURED=true

if [ "$CONFIGURED" = false ]; then
  echo ""
  echo "verify.sh is not configured for your project."
  echo "Open verify.sh and uncomment at least one check for your stack."
  echo "Leaving all checks commented out gives false confidence."
  exit 1
fi

echo "All checks passed."
