# /work — Build a scope

You are the orchestrator for a shaped scope. You coordinate the researcher → reviewer → implementer pipeline, enforce human checkpoints, and ensure quality before handoff to `/qa`.

---

## Session Start

1. **Read context:**
   - `CLAUDE.md` — stack, NFRs, constraints, git protocol.
   - `product.md` — vision and users.
   - `brand.md` — design tokens and component patterns.
   - `architecture.md` — system-level architectural principles (if it exists).
   - The scope JSON at `cycles/[current]/scopes/[scope-id].json`.
   - `cycles/[current]/pitch.md` — the shaped pitch.
   - Any existing mockups in `cycles/[current]/design/[scope-id]/`.
   - Any previous progress notes for this scope.
   - `cycles/[current]/learnings/` — conventions, gotchas, decisions from this cycle.

2. **Promote cycle seeds (if any).** Check for `cycles/_seeds.md`. If it exists:
   - Read it and promote relevant items into the current cycle's learnings files (conventions.md, gotchas.md, decisions.md).
   - Delete `cycles/_seeds.md` after promoting.
   - Tell the human: "Promoted [N] items from the previous cycle retro into this cycle's learnings."

3. **Check context level.** If above 60%, recommend starting a fresh session before proceeding.

4. **Determine routing** from scope JSON:
   - `scope_type: "bug"` or trivial mechanical change → **Lightweight route** (skip researcher/reviewer)
   - `needs_spike: true` → **Spike route** (researcher only, no implementation)
   - All other scopes → **Full pipeline route**

---

## Full Pipeline Route

### Step 1 — Research

Spawn the **researcher** agent **in codebase mode** (the default). Provide:
- The scope ID and description
- The directories most likely to be affected (based on the pitch)

Note: scout mode (current 2026 tech surveys) is for `/shape` only. By the time `/work` runs, load-bearing tech decisions are already locked in the pitch. If the implementer later discovers a tech choice needs revisiting, that is a flag for human review, not a mid-build pivot.

The researcher returns a structured findings document. Read it carefully.

**🛑 CHECKPOINT — Present findings summary to the human.**
Ask: "Research complete. Here's what was found: [summary]. Any concerns before planning?"

Wait for confirmation before proceeding.

### Step 2 — Review

Spawn the **reviewer** agent. Provide:
- The scope JSON
- `cycles/[current]/pitch.md`
- The research findings from Step 1
- `CLAUDE.md`

The reviewer returns GO / GO WITH CHANGES / NO-GO.

**🛑 CHECKPOINT — Present the review verdict to the human.**
- If GO: confirm and proceed to implementation.
- If GO WITH CHANGES: show required adjustments. Ask human to confirm the changes before proceeding.
- If NO-GO: present the blocking concerns. The scope may need to return to shaping.

**Do not proceed to implementation without explicit human confirmation.**

### Step 3 — Mockup (hero screens only)

If the scope has `has_hero_screens: true` and `mockup_status` is not `"approved"`:

Generate 2-3 mockup variants as HTML files **before** spawning the implementer:
- `cycles/[current]/design/[scope-id]/mockup-v1.html`
- `cycles/[current]/design/[scope-id]/mockup-v2.html`
- `cycles/[current]/design/[scope-id]/mockup-v3.html`

Each variant must use `brand.md` tokens (typography, colours, spacing, motion) and the frontend-design skill. Vary layout, emphasis, and interaction approach across options.

**🛑 STOP — Present all variants to the human.**
Describe the design rationale for each. Ask the human to select one, or describe what to combine.

Save the approved design as `mockup-approved.html`. Update `mockup_status: "approved"` in the scope JSON.

For backend/infra scopes: skip this step entirely.

### Step 4 — Implement

Spawn the **implementer** agent. Provide:
- The scope JSON
- Research findings from Step 1
- Reviewer verdict and required adjustments from Step 2
- `cycles/[current]/pitch.md`
- `CLAUDE.md`
- `brand.md` (if UI work)
- Path to approved mockup (if hero screens exist)

The implementer works in its own worktree, writes code, and returns an implementation report.

### Step 5 — Verify

Spawn the **verifier** agent. Provide:
- The scope ID
- Path to the scope JSON (to check against test scenarios)

The verifier runs `./verify.sh`, checks the test suite, and returns a verdict.

If the verifier returns NEEDS FIXES: send the verifier's report back to the implementer. Repeat until READY FOR QA.

**🛑 CHECKPOINT — Present verification results to the human.**
Show: hill position, verify.sh status, test quality summary.
Ask: "Verification passed. Ready to run `/qa` in a fresh session?"

---

## Lightweight Route (bug fixes, trivial changes)

Skip researcher and reviewer. Proceed directly:

1. Understand the issue — reproduce it, trace the root cause.
2. Write a failing test that captures the bug.
3. Fix the bug. The test must pass.
4. Run `./verify.sh`. It must pass.
5. Commit: `[fix-NNN] description`.
6. Open PR.

If investigation reveals the root cause is a deeper structural problem, stop. Comment on the issue with the finding and label `needs-shaping`. Don't patch over a structural problem.

---

## Spike Route

Spawn the **researcher** agent only. Focus on:
- The specific unknown the spike is meant to resolve
- Producing a validation proof (working prototype, benchmark, proof of concept) or a clear report of why the approach won't work

Update the scope JSON with findings:
- Set `needs_spike: false`
- Add findings to the relevant unknown's `resolution` field
- Flag for human review before any implementation starts

---

## End of Session

All session housekeeping is handled continuously:
- **verify.sh** runs automatically via the Stop hook after every turn.
- **Scope JSON** should be updated after each completed task — hill position, task statuses, resolved unknowns, open questions.
- **Learnings** should be appended after each verified task.

### Capture cost estimate (lightweight, session-attributed)

Before ending, record an approximate cost for this scope so `/retro` can flag expensive outliers:

1. Ask the human to run `/cost` and share the session total (USD). This is the only reliable read of session cost from inside the harness — there is no native per-scope meter.
2. Update the scope JSON's `cost_estimate` block:
   ```json
   "cost_estimate": {
     "usd": <total>,
     "sessions": <increment if this scope spanned multiple sessions>,
     "method": "session-attributed",
     "captured": "<date>",
     "note": "Approximate. Assumes ~one scope per /work session; includes subagent usage."
   }
   ```
3. If this scope already has a `cost_estimate` from a prior session, **add** this session's total to `usd` and increment `sessions`.

This is deliberately approximate. It is only meaningful if you keep roughly **one scope per `/work` session** — which the pipeline already nudges toward (fresh QA session, context-reset guidance). Do not over-invest in precision here; the signal that matters is relative ("scope-3 cost 4× the others"), not the absolute figure.

Commit all work with scope-prefixed messages before ending. The next `/work` invocation reads the scope JSON and progress notes to reconstruct where things stand.

---

## Important Principles

- **The pipeline protects quality.** Skipping researcher means implementing against unknown conventions. Skipping reviewer means discovering architecture problems mid-build. Skipping verifier means shipping untested code to QA.
- **Checkpoints are real gates.** Don't proceed past a checkpoint without explicit human confirmation.
- **The implementer has tool restrictions.** It cannot push to remote or edit CLAUDE.md. These are enforced by the agent definition, not by instruction.
- **The approved mockup is the build spec for hero screens.** The implementer implements against it. Deviations are flagged, not silent.
- **Scopes can change.** If the implementer discovers the scope needs to split or that a new unknown has emerged, surface it to the human. Don't change scope boundaries silently.
