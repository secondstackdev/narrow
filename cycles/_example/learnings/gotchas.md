# Gotchas — example-cycle

Traps, surprises, and non-obvious behaviours discovered during this cycle.

---

## settings-ui — 2025-04-10

**Gotcha:** The settings API returns `null` for the notifications object if the user has never set preferences, not an empty object or default values.
**Symptom:** Toggle states all appear undefined on first load, causing a flash before defaults are applied.
**Fix:** Normalise the API response in `useUserSettings()` — if `notifications` is null, replace with `{ digest: true, mentions: true, replies: true }` before storing in state.
