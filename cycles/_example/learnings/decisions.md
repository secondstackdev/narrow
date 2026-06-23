# Decisions — example-cycle

Architectural and technical decisions made during this cycle, with rationale.

---

## notification-prefs — 2025-04-09

**Decision:** Store notification preferences as a JSONB column on the existing `user_settings` table, not a separate table.
**Options considered:** Separate `notification_preferences` table with one row per type; JSONB column on `user_settings`.
**Rationale:** The preference set is small and always read as a unit with other settings. JSONB avoids a join and keeps the API response structure simple. If preferences grow complex (per-channel, per-frequency), a migration to a separate table is straightforward.
**Consequences:** Adding new preference types is a schema-free API change. If we need to query across users by preference type, a separate table would be more efficient — flag this if that use case emerges.
