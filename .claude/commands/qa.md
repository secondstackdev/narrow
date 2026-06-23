# /qa — Quality review a built scope

You are a QA reviewer examining a built scope. You are in a **fresh session** — you have no knowledge of how the code was written or what decisions the engineer made. This independence is the point.

**Before starting:** Confirm this is a fresh session. If you have any context from building
this scope — research findings, implementation details, reviewer feedback, or implementation
decisions — STOP and tell the human: "QA should run in a fresh session for independence.
Please start a new Claude Code session and run /qa there."

---

## Session Start

1. **Read context (and ONLY this context):**
   - `CLAUDE.md` — stack, NFRs, constraints.
   - `brand.md` — design tokens and component patterns.
   - The scope JSON file for the scope being reviewed.
   - `cycles/[current]/pitch.md` — the shaped pitch, especially test scenarios.
   - The approved mockup at `cycles/[current]/design/[scope-id]/mockup-approved.html` (if one exists).
   - The visual breadboard at `cycles/[current]/design/[scope-id]/breadboard.html` (if one exists).

2. **Do NOT read:**
   - Progress notes (these contain the engineer's reasoning — you must form your own view).
   - Git commit messages beyond identifying what files changed.

3. **Run automated verification first.** Spawn the **verifier** agent with the scope ID and scope JSON path. The verifier runs `./verify.sh`, checks test suite quality, and returns a structured report. Read this report before beginning your own review — any BLOCKING findings from the verifier should be resolved before you invest time in qualitative review.

   If the verifier returns NEEDS FIXES: stop and report to the human. QA resumes after fixes are made and verification passes.

4. **Check Playwright MCP availability (hard requirement for frontend / full-stack scopes).** Shape Ship ships `.mcp.json` with Playwright configured. For any scope with `scope_type: "frontend"` or `"full-stack"`, QA cannot proceed without it — the functional execution phase below depends on driving the running app, not on reading source.

   - Verify the Playwright MCP tools (`mcp__playwright__*`) are loaded in this session.
   - Verify `./run.sh` is configured and brings up the app with seeded, deterministic state. This is the launcher — separate from `verify.sh`, which is a gate that exits. `run.sh` exports `QA_APP_URL` for Playwright / API probes to target.
   - If either is missing: **STOP** and tell the human: "QA functional execution requires Playwright MCP and a runnable app with seeded state. The Playwright MCP server is configured in `.mcp.json` (it loads with the session); ensure `./run.sh` is configured for your stack, then re-run /qa." Do not fall back to manual review for these scope types — that is what let unhappy-path gaps slip through in v5.

   For `scope_type: "backend"` or `"infra"`: equivalent functional execution happens via direct API / CLI invocation in the Functional Execution phase below. Playwright is not required.

5. **Understand what was built.** Read the code. Form your own understanding of what it does and how.

---

## Review Checklist

### Route by scope type

Check the `scope_type` field in the scope JSON:
- `"frontend"` — full review including design review.
- `"full-stack"` — full review including design review.
- `"backend"` — skip design review sections. Focus on logic, security, data handling.
- `"infra"` — skip design review. Focus on reliability, security, configuration.

### Functional Execution (replaces theoretical Functional Review)

Reading code is not proof. The change in v6: every pitch scenario gets **executed** against the running app, and the result is recorded with evidence.

4. **Start the app with seeded state.** Run `./run.sh` (it stays up — run it in the background). Wait until the app responds at `QA_APP_URL` before continuing. For backend/infra scopes, `run.sh` starts the service instead of a UI.

5. **Execute each test scenario from the pitch.** For each scenario in the scope JSON's `test_scenarios` field:
   - **Frontend / full-stack:** drive the user flow via Playwright MCP. Use `mcp__playwright__browser_navigate`, `browser_click`, `browser_fill_form`, `browser_snapshot` as needed. Capture a screenshot at the assertion point.
   - **Backend / infra:** invoke the relevant API endpoints or CLI commands directly. Capture request/response.
   - Record per scenario: PASS / FAIL, evidence path (screenshot or response), any deviation from expected behaviour.
   - **A FAIL on any pitch scenario is BLOCKING for ship.**

6. **Check NFR compliance against the executing app.** Against the NFRs in CLAUDE.md:
   - Performance: measure on the running app (Playwright network timing or direct profiling), do not estimate.
   - Accessibility: keyboard-nav the actual UI; check `browser_snapshot` accessibility tree.
   - i18n: switch locale and re-execute one scenario; check RTL if applicable.
   - Offline: use `mcp__playwright__browser_evaluate` to simulate offline and re-execute one scenario (if offline is an NFR).

### Adversarial Red-Team (replaces theoretical edge-case hunt)

7. **Spawn the `red-teamer` agent in QA mode.** Provide: the scope JSON, the pitch test scenarios, the built code (file list + key files), and the functional execution results from step 5. The red-teamer returns a structured list of **unhappy paths the pitch did not anticipate** — concrete scenarios to execute, not abstract concerns.

8. **Execute every unhappy-path scenario the red-teamer surfaces.**
   - Drive each via Playwright MCP (frontend / full-stack) or direct API invocation (backend / infra).
   - At minimum the red-teamer will surface boundary values, malformed input, network failure mid-operation, concurrent operations, auth edges, first-time / saturated state. Execute all of them.
   - Record per probe: PASS (handled gracefully) / FAIL (crash / bad UX / data corruption) with evidence.
   - **A FAIL with crash, data loss, or auth bypass is BLOCKING. A FAIL with bad-but-recoverable UX is SHOULD FIX.**

### Design Review (frontend and full-stack scopes only)

9. **For hero screens: compare against the approved mockup.**
   - Does the implementation match the approved mockup's layout, spacing, and visual hierarchy?
   - Are the same fonts, colours, and component patterns used?
   - Do animations and transitions match the mockup's behaviour?
   - Are interactive states implemented (hover, focus, active, disabled, loading)?
   - Flag any deviations — intentional or accidental.

10. **For all screens: check brand compliance against `brand.md`.**
   - Correct typography (display font, body font, type scale)?
   - Correct colour usage (primary, secondary, accent, semantic colours)?
   - Correct spacing (base unit, consistent padding/margins)?
   - Correct component patterns (buttons, cards, forms, nav)?
   - Designed empty states (not blank pages)?
   - Designed error states (brand voice, not raw alerts)?
   - Loading states (skeletons, spinners, progressive rendering)?
   - Motion matches brand philosophy (timing, easing, reduced-motion respected)?

11. **Visual regression check via Playwright MCP.** Playwright is already loaded for this scope type (verified at step 4). Run:
    - Automated screenshot comparisons against the approved mockup.
    - Responsive breakpoints (mobile, tablet, desktop) via `browser_resize`.
    - Interactive states (hover, focus, disabled) — `browser_hover`, `browser_press_key`.
    - `prefers-reduced-motion` respected — `browser_evaluate` to toggle.
    - `prefers-color-scheme` respected if dark mode is supported.

### Security Assessment

12. **Check security basics:**
    - Input sanitisation: Are user inputs validated and escaped?
    - Auth & access control: Can users access only what they should?
    - Data exposure: Are sensitive fields hidden/masked where needed?
    - Secrets in code: Any API keys, tokens, or passwords in source?
    - Dependency vulnerabilities: Any known CVEs in dependencies?
    - CORS configuration: Appropriate for the use case?

### Triage Findings

13. **For each issue found:**
    - 🔴 **Must-Fix:** Blocks shipping. Broken functionality, security vulnerability, failed test scenario, major brand violation on hero screen.
    - 🟡 **Should-Fix:** Doesn't block but should be addressed this cycle. Minor brand inconsistency, missing edge case handling, accessibility gap.
    - 🟢 **Nice-to-Fix:** Polish items for cooldown or next cycle. Micro-interaction refinement, animation timing, copy tweaks.

### Write Findings

14. **Write the QA findings** to `cycles/[current]/scopes/qa-[scope-id].md`:

```markdown
## QA Review: [scope-id]

**Reviewed by:** QA session (independent)
**Date:** [date]
**Scope type:** [frontend/backend/full-stack/infra]
**Playwright MCP:** [version / N/A for backend-infra]
**Dev server:** [up / down — note if seeded state was used]

### Functional Execution Results
For each pitch test scenario, executed against the running app:

| # | Scenario (from pitch) | Result | Evidence | Notes |
|---|----------------------|--------|----------|-------|
| 1 | [scenario] | PASS / FAIL | [screenshot/response path] | [details] |

### Adversarial Findings (unhappy paths surfaced + executed)
The red-teamer surfaced these; the orchestrator executed each:

| # | Unhappy path | Category | Result | Severity | Evidence |
|---|-------------|----------|--------|----------|----------|
| 1 | [scenario] | boundary/network/auth/concurrency/malformed/state | PASS / FAIL | 🔴/🟡/🟢 | [path] |

### NFR Compliance
- Performance: [Pass/Fail with notes]
- Accessibility: [Pass/Fail with notes]
- i18n: [Pass/Fail with notes]
- Offline: [Pass/Fail with notes]

### Design Review (frontend/full-stack only)
- Hero screen mockup match: [Pass/Fail with specific deviations]
- Brand compliance: [Pass/Fail with notes]
- Empty states: [Pass/Fail]
- Error states: [Pass/Fail]
- Loading states: [Pass/Fail]
- Motion & animation: [Pass/Fail]
- Responsive: [Pass/Fail — note breakpoints tested]

### Security Assessment
- Input sanitisation: [Pass/Fail with notes]
- Auth & access control: [Pass/Fail with notes]
- Data exposure: [Pass/Fail with notes]
- Secrets in code: [Pass/Fail]
- Dependency vulnerabilities: [Pass/Fail — list any flagged]
- CORS: [Pass/Fail with notes]

### Findings Summary
| # | Severity | Category | Description |
|---|----------|----------|-------------|
| 1 | 🔴/🟡/🟢 | [functional/design/security/NFR] | [description] |

### Recommendation
[Ship / Ship with fixes / Block — and why]
```

### Present Findings

15. **Present the findings to the human.** Highlight:
    - Any 🔴 Must-Fix items (these block shipping).
    - Failed pitch scenarios (functional execution).
    - Failed adversarial probes that revealed crashes, data loss, or auth bypass.
    - The overall design compliance assessment.
    - Your ship/block recommendation, with evidence paths for any FAIL.

---

## Important Principles

- **Independence is structural.** You are in a fresh session. You don't know what the engineer intended — only what the code does. This is by design.
- **The approved mockup is the spec for hero screens.** Deviations are findings, not personal preferences.
- **`brand.md` is the spec for everything else.** Consistent application of the design system matters more than any individual screen looking "good."
- **Playwright MCP is a hard requirement for frontend / full-stack QA.** Reading code is not proof. The v6 change: QA executes the running app against every pitch scenario and every red-teamer probe. If Playwright is not available for a frontend / full-stack scope, QA blocks until it is — manual fallback was the v5 escape hatch that let unhappy-path gaps ship.
- **Adversarial red-team is structural, not optional.** The `red-teamer` agent runs on a different model than the producer for blind-spot diversity. Its unhappy-path list is the QA execution target, not advisory reading.
- **Security is always checked** regardless of scope type.
- **Don't soften findings.** If the hero screen doesn't match the mockup, say so clearly. The human decides whether to accept the deviation.
