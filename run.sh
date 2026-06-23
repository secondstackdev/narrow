#!/bin/bash
# run.sh — Launch the app with seeded state for functional QA.
#
# This is the entry point /qa uses to drive the running app via Playwright
# (frontend / full-stack) or direct API calls (backend / infra) during the
# Functional Execution and Adversarial Red-Team phases.
#
# This is NOT verify.sh. verify.sh is a gate that runs to completion and
# exits (the Stop hook runs it after every turn). This script starts a
# LONG-RUNNING process and must keep the app up until killed. Never put a
# dev server in verify.sh — it would block the hook forever.
#
# Requirements for /qa functional execution:
#   - The app must come up on a known, documented address (export QA_APP_URL).
#   - State must be SEEDED and DETERMINISTIC — the same fixtures every run, so
#     pitch scenarios and adversarial probes are reproducible.
#   - Auth must be reachable (a seeded test user or a documented bypass for
#     local QA), so auth-edge probes can actually be executed.
#
# Customise for your project's stack. Uncomment and adapt one block below.

set -e

CONFIGURED=false

# The URL Playwright / API probes will target. /qa reads this.
export QA_APP_URL="${QA_APP_URL:-http://localhost:3000}"

echo "Launching app for QA at ${QA_APP_URL} ..."

# 1. Seed deterministic state (idempotent — safe to re-run).
# echo "  Seeding fixtures..."
# npm run db:reset && npm run db:seed:qa
# CONFIGURED=true

# 2. Start the dev server (foreground, long-running).
# echo "  Starting dev server..."
# npm run dev
# CONFIGURED=true

# --- Backend / infra scopes: no UI. Start the service instead. ---
# echo "  Starting API..."
# npm run start:qa
# CONFIGURED=true

if [ "$CONFIGURED" = false ]; then
  echo ""
  echo "run.sh is not configured for your project."
  echo "Open run.sh and configure seeding + app launch for your stack."
  echo "/qa functional execution for frontend/full-stack scopes cannot run without it."
  exit 1
fi
