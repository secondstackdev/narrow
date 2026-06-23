# Conventions — example-cycle

Patterns established during this cycle that all implementers should follow.

---

## settings-ui — 2025-04-10

**Convention:** Optimistic updates use a local state snapshot before the API call, not a flag.
**Why:** Reverting is a simple `setState(snapshot)` rather than tracking a separate "reverting" boolean.
**Example:** `src/screens/NotificationPreferences.tsx:42`

## settings-ui — 2025-04-11

**Convention:** All settings screens load their initial state via a custom `useUserSettings()` hook, not direct API calls in components.
**Why:** Keeps components clean and makes it easy to mock in tests.
**Example:** `src/hooks/useUserSettings.ts`
