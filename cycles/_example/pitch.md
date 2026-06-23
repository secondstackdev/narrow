# Pitch: User Settings & Notification Preferences

**Appetite:** Small Batch — 2 weeks
**Shaped by:** Product team
**Date:** 2025-04-05

## Problem

A user who just got spammed by three back-to-back digest emails opens the app to turn them off.
They tap their avatar, find a "Profile" screen with name and photo fields, and hit a dead end —
there's no way to manage notifications. They give up and unsubscribe from all emails instead,
losing a user who wanted a smaller signal, not silence.

## Appetite

Two weeks. The solution is a settings screen and a notification preferences panel — not a
full account management suite. No billing, no password change, no connected accounts. Those
are a separate cycle.

## Solution

### Visual Breadboards

See `design/settings-ui/breadboard.html` — two screens: Settings hub and Notification Preferences.

### Interaction Walkthrough

- **Starting point:** User taps avatar in tab bar, opens Settings screen.
- **Step 1:** Settings screen shows display name, email (read-only), and a "Notifications" row.
- **Step 2:** User taps "Notifications", navigates to Notification Preferences screen.
- **Step 3:** User sees a list of notification types (digest, mentions, replies) with toggles.
- **Step 4:** User toggles "Digest emails" off. Change saves immediately (no submit button).
- **End state:** User returns to Settings, sees Notifications row. Their preference is saved.
- **Empty state:** Not applicable — there is always at least one notification type shown.
- **Error state:** If save fails, toggle snaps back and a toast appears: "Couldn't save — try again."

### Hero Screens

| Screen | Why it's a hero | Scope |
|--------|----------------|-------|
| Notification Preferences | First impression of our control model | settings-ui |

## Rabbit Holes

- **Real-time sync across devices:** Out of scope. Preferences update on next app launch, not instantly.
- **Granular frequency controls:** Toggles only — no "send at most once per day" in this batch.

## No-Gos

- Password change
- Connected accounts / OAuth
- Billing and subscription management
- Push notification permissions (OS-level prompts are a separate problem)

## Architecture Decisions

- Preferences persisted server-side via existing user settings API endpoint (`PATCH /api/user/settings`)
- Optimistic UI update on toggle — revert on failure
- Settings screen is a new stack screen, not a modal

## Scopes

| Scope | Type | Hero Screens | Key Unknowns |
|-------|------|-------------|--------------|
| settings-ui | full-stack | Yes (Notification Preferences) | Does the existing API support granular notification fields? |
| notification-prefs | backend | No | Schema change needed for new prefs fields |
