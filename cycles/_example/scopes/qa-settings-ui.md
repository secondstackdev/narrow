## QA Review: settings-ui

**Reviewed by:** QA session (independent)
**Date:** 2025-04-14
**Scope type:** full-stack
**Playwright MCP:** not available

### Test Scenario Results

| Scenario | Result | Notes |
|----------|--------|-------|
| User opens Settings, taps Notifications, sees all three toggle types | Pass | All three types present with correct labels |
| User toggles Digest off — updates immediately, API called, persists after restart | Pass | Optimistic update works, verified in API logs |
| API call fails — toggle reverts, error toast appears | Pass | Error toast uses correct brand voice |
| Loading state shown before API response | Pass | Skeleton row shown correctly |

### Edge Cases Found

- **[SHOULD FIX]** If the user rapidly toggles the same switch on/off before the first API call completes, a second call fires with stale state. The final UI state may not match the server. Consider debouncing or disabling the toggle while a save is in flight.

### NFR Compliance

- Performance: Pass — initial load < 200ms on fast network, within budget
- Accessibility: Pass — toggles have accessible labels, focus indicators visible
- i18n: Pass — all strings externalised
- Offline: N/A — settings require network by design, documented in no-gos

### Design Review

- Hero screen mockup match: Pass — layout, spacing, and typography match mockup-approved.html
- Brand compliance: Pass — correct type scale, colour usage, and spacing throughout
- Empty states: N/A — there is always at least one notification type
- Error states: Pass — error toast uses brand voice, not a raw alert
- Loading states: Pass — skeleton row shown during initial fetch
- Motion & animation: Pass — toggle animation respects prefers-reduced-motion
- Responsive: N/A — mobile-only app

### Security Assessment

- Input sanitisation: Pass — display name is read-only in this scope, toggles are boolean
- Auth & access control: Pass — settings endpoint requires authenticated session
- Data exposure: Pass — no sensitive fields exposed
- Secrets in code: Pass — no hardcoded keys or tokens
- Dependency vulnerabilities: Pass — no new dependencies added
- CORS: Pass — no change to CORS configuration

### Findings Summary

| # | Severity | Category | Description |
|---|----------|----------|-------------|
| 1 | SHOULD FIX | Functional | Rapid toggle before save completes can leave UI and server out of sync |

### Recommendation

Ship with fix for finding #1 this cycle. The race condition is reproducible and creates a silent inconsistency. Fix: disable toggle while save is in flight and re-enable on resolution.
