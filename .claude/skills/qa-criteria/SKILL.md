---
name: qa-criteria
description: Quality assessment heuristics for verifying and reviewing built scopes. Preloaded into the verifier agent. Covers test quality assessment, severity triage, and coverage criteria.
---

## Test Quality Assessment

When assessing whether tests are adequate, go beyond "do they pass?" Ask:

**Do tests cover the pitch scenarios?**
The scope JSON has `test_scenarios` written from the PM perspective during shaping. Each scenario should have a corresponding test. If a scenario has no test, that is a gap — not a matter of opinion.

**Are edge cases tested?**
For each happy-path test, consider what happens at the boundary:
- Empty / zero / null inputs
- Maximum / overflow inputs
- Network failure or timeout
- Concurrent operations or race conditions
- First-time use (no existing data)
- Permission or auth failures

**Test integrity checks:**
- Does the test assert something meaningful, or just that no error was thrown?
- Would the test catch a regression if the implementation broke?
- Does the test name describe what behaviour it verifies, or just what function it calls?
- Are there tests that always pass because they only test mocks?

## Severity Triage

**BLOCKING — must fix before shipping:**
- Test scenario from the pitch fails
- Security vulnerability (injection, auth bypass, data exposure, hardcoded secrets)
- Verify.sh fails
- Application crashes or throws unhandled errors in normal use
- Data loss or corruption possible

**SHOULD FIX — address this cycle:**
- Edge case not handled, causes bad user experience but not data loss
- Accessibility gap on a core flow
- Missing test for a non-trivial code path
- Performance significantly outside budget
- Code left in that should not be there (debug logging, TODO comments on shipped paths)

**MINOR — polish or next cycle:**
- Minor UI inconsistency
- Non-critical test missing
- Optimisation opportunity
- Copy or micro-interaction refinement

## Coverage Heuristics

A scope is adequately covered when:
- All pitch test scenarios have passing tests
- Happy path works end-to-end
- Primary error states are handled and tested
- No hardcoded credentials or secrets

A scope is NOT adequately covered just because line coverage is high. Line coverage measures execution, not correctness. A test that calls every line without asserting any behaviour is worse than no test — it creates false confidence.

## Verification Sequence

Run in this order so failures are caught at the cheapest layer first:
1. Linting / formatting (static, instant)
2. Type checking (static, fast)
3. Unit tests (fast)
4. Integration tests (slower)
5. verify.sh (all of the above in one)

If verify.sh already runs all of these, run verify.sh. Only decompose it if you need to isolate a specific failure.

## Adversarial Heuristics (for `/qa` execution, not theorising)

These are probes the red-teamer surfaces and the QA orchestrator **executes** against the running app. They are not items to "consider" — they are scenarios to drive end-to-end via Playwright MCP (frontend) or direct API invocation (backend).

For every pitch scenario, generate and execute at least one probe from each category that applies:

- **Boundary execution:** empty input, single item, max-allowed item count, one-over-max, off-by-one on indexing, zero / negative / very-large numeric input.
- **Malformed execution:** wrong type, unexpected nulls, very long strings, unicode edge cases (combining chars, RTL injection, NULL bytes), encoded payloads (HTML/SQL/JS) where the field should be text.
- **Network execution:** kill the network mid-request (`browser_evaluate` to toggle offline), introduce 5s latency, return 500 / 503 / 429 from the backend, partial response.
- **Concurrency execution:** double-click submit, two parallel requests writing the same resource, tab switch mid-flow, refresh during async operation.
- **Auth execution:** expire the session mid-flow, change role mid-flow, attempt action as wrong user, attempt action while logged out.
- **State execution:** first-time use (no existing data), state saturated (max data), partially corrupt state (one missing field), state from previous version (migration boundary).

A probe is only PASS if the app **handled it gracefully with a designed response** — not "didn't crash." A blank error screen is a FAIL even if no exception was thrown. Loss of user input on retry is a FAIL even if recovery worked. The criterion is "would the named user from the pitch be served well here?"

Severity follows the Severity Triage section above:
- Crash / data loss / auth bypass → **BLOCKING**
- Bad UX, recoverable → **SHOULD FIX**
- Polish / nice-to-have → **MINOR**
