# CLAUDE.md — Shape Ship v6

## Project

- **Name:** Guess Game (working title) — AI-powered large-pool deduction game
- **Stack:** Flutter thin client / server-side Answer-Key Engine + shared cache; external
  LLM APIs (runtime mapper + build-time oracle + synthetic players). Server language, host,
  and runtime model are DEFERRED to the scout (see `architecture.md` → Deferred decisions).
- **Repo:** github.com/secondstackdev/narrow

## Non-Functional Requirements

Measurable, with units and a measurement method. Server timings are server-side processing
latency (exclude network/RTT) unless stated. NFRs 5–7 are **release-blocking**; the rest are
alerting/budget NFRs. Bound by the principles in `architecture.md`.

- **NFR-1 — Cache-hit latency:** p95 ≤ 80 ms, p99 ≤ 150 ms server-side (store lookup +
  predicate eval, network excluded). *Measure:* harness warm-cache question-stream replay.
  *Why:* the common path is a cache hit — this is the felt "instant shrink."
- **NFR-2 — MAP latency (cache miss → query/decline):** p95 ≤ 600 ms, p99 ≤ 900 ms
  server-side. *Measure:* harness forces misses against the runtime mapper. *Why:* one cheap
  structured call; p99 bounds the tail so a miss never feels broken.
- **NFR-3 — JUDGE latency + rate:** p95 ≤ 2.0 s, p99 ≤ 3.5 s; **judge rate ≤ 2% of
  questions after warm-up**. *Warm-up ends* when the mapping-cache miss rate first drops
  below 10% over a rolling 24h window, OR at day 14 post-launch, whichever comes first.
  *Measure:* harness for latency; 7-day rolling prod log for rate. *Why:* judge may be slow
  only because it is rare; a rate breach is a schema-coverage signal, not a latency failure.
- **NFR-4 — Animation framerate _(NOT YET ACTIVE)_:** ≥ 58 fps sustained while animating
  the 500-entity pool shrink (≤ 1% of frames > 16.7 ms). *Status:* inactive until the
  mid-tier reference device is chosen at the Flutter animation spike; activate then.
  *Measure:* Flutter profiler, scripted shrink, on the locked reference device.
- **NFR-5 — Determinism _(release-blocking)_:** 100% identical resolution across N ≥ 50
  repeated temp-0 runs per question, over a fixed 500-question regression set. *Measure:*
  harness; any divergence fails the build. *Why:* the freeze contract made testable —
  zero tolerance.
- **NFR-6 — TARGET-NEVER-CUT _(release-blocking, P0)_:** 0 violations across all 500
  entities × the full frozen question corpus, every build. *Measure:* deterministic
  exhaustive gate — for each entity as hypothetical target, no truthful yes/maybe question
  eliminates it. Any hit blocks release.
- **NFR-7 — NO-CONTRADICTIONS _(release-blocking)_:** 0 complementary-pair both-yes results
  across all 500 entities, every build. *Measure:* deterministic gate over the registered
  complementary-pair set × all entities.
- **NFR-8 — Availability (split SLA):** core loop (Question API + Answer-Key Engine)
  ≥ 99.0% monthly; social/identity (leaderboard, streaks) ≥ 98.0% monthly with degraded
  (stale/read-only leaderboard) acceptable. **Graceful degradation:** on model/judge
  unavailability the server returns `maybe`-keep or a clean decline, NEVER a fabricated
  `no`, and on regional outage the client shows "reconnect to play," never a hang.
  *Measure:* host uptime metrics + harness fault-injection (kill the model adapter, assert
  no `no` is fabricated). *Why:* the core moment matters more than social; single-region
  online-only is an accepted MVP trade.
- **NFR-9 — Cost per 1,000 questions _(tracked, not gated until scout lands)_:** ≤ US$0.50
  per 1,000 questions at steady-state warm cache (miss rate ≤ 10%). Cold-start cost is
  bounded instead by the synthetic-player **pre-warm launch gate** (see architecture.md),
  not by live traffic. *Status:* the dollar figure is provisional pending the runtime
  model/host scout; tracked and alerted, becomes gated once the scout lands. *Why:* the
  economic thesis is "cost scales with miss rate, not DAU" — this is the tripwire.
- **NFR-10 — Schema coverage / decline rate:** ≤ 8% of in-domain objective questions hit
  `judge`-or-`decline` after warm-up, and the rate must trend down **week-over-week**
  (fixed calendar cadence, independent of release events, since schema changes don't
  require an app release). *Measure:* prod question-log classification + dual-path labels.
  *Why:* operationalizes the validation flywheel — if coverage isn't converging, the
  promotion loop is stalled.
- **NFR-11 — Time-to-detect a poisoned resolution:** any newly frozen resolution that
  disagrees with the strong oracle is flagged for review within **24h** of first freeze.
  *Measure:* the Validation Harness continuously re-validates newly frozen keys against the
  oracle. *Why:* the global write-once cache means one bad freeze is live for everyone —
  bounded detection time caps the blast radius of trust damage.

## Design System

- **Brand & design tokens:** See `brand.md` (created via `/shape --brand`, updated during cooldown only).
- **Frontend design skill:** `.claude/skills/frontend-design/` — always use `brand.md` tokens, never generic defaults.
- **Mockups:** `cycles/[current]/design/[scope-id]/` — generated during `/work` for hero screens.

## Architectural Constraints

- [e.g., All state management through Zustand — no Redux, no MobX]
- [e.g., API calls go through a single service layer — components never call APIs directly]
- [e.g., No ORM — use raw SQL via Supabase client]

See `architecture.md` for system-level boundaries, dependency direction, and non-negotiables. If `architecture.md` sections are still empty, run `/shape --architecture` before any normal `/shape` invocation — the bootstrap gate in `/shape` enforces this.

## Model Assignments (v6 multi-model pipeline)

Different lifecycle phases run on different Claude models to get adversarial diversity (the reviewer doesn't share the producer's blind spots) and cost-appropriate intelligence (I/O on Haiku, architecture on Opus, review on Sonnet).

| Agent | Model | Why |
|---|---|---|
| researcher (codebase + scout modes) | Haiku 4.5 | I/O-bound — file reads, web fetches, doc lookups |
| architect | Opus 4.8 | Synthesis under constraints; load-bearing decisions |
| red-teamer | Sonnet 4.6 | Different model from producers for blind-spot diversity |
| reviewer (plan review in /work) | Sonnet 4.6 | Architecture review on a different model from implementer |
| implementer | Sonnet 4.6 | Code generation with strong tool restrictions |
| verifier | Haiku 4.5 | Mechanical pass/fail checks |

The orchestrator commands (`/shape`, `/work`, `/qa`) run on whatever session model you launched with. The expensive synthesis is delegated to the architect subagent; the interactive PM-grilling phases of `/shape` can run on Sonnet without losing quality.

## Work Routing

When given a task, determine the route first:

- **Scope work** (scope JSON exists): Run `/work` — researcher → reviewer → implementer pipeline.
- **Bug fix** (`bug` label, root cause clear): Fix directly. Write failing test, fix it, run `./verify.sh`, open PR.
- **Complex bug** (root cause unclear): Investigate before fixing. If structural, comment on issue with `needs-shaping` label instead of patching.
- **Spike** (`needs_spike: true` in scope): Timeboxed investigation only. Produce validation proof or report. No production code.

## Git Protocol

**Branches:** `main` (protected), `feat/[scope-id]`, `fix/[issue-number]`, `spike/[scope-id]`

**Commits:** `[scope-id] short description` — include scope ID in every message so git log is filterable.
For auth, payments, migrations, or security-sensitive changes: smaller commits, extra test coverage, prefix `[SENSITIVE]`.

**Pull requests:** One PR per scope. Description must reference scope file. Never force push to shared branches. Never commit to main directly. Never merge your own PR without QA review.

**Parallel agents:** Multiple agents MUST be on separate branches for separate scopes. Merge conflicts resolved by rebasing, never force-pushing.

## Token Efficiency — Haiku Delegation

Delegate I/O-heavy work to a Haiku sub-agent to keep your own context lean. Use the Agent tool with `model: "haiku"`.

### Delegate to Haiku

**Bulk reads** — when you would read 3+ files, or any single file >400 lines:
```
Agent(model: "haiku", prompt: "Read [files]. Answer: [question]. Return a concise structured summary.")
```
Use the summary. Do NOT load raw file content into your own context.

**Boilerplate writes** — test scaffolding, config files, repetitive patterns, any file where the structure is predictable:
```
Agent(model: "haiku", prompt: "Generate [file] matching the pattern in [reference]. Write it to [target path].")
```
Then review and make surgical edits yourself.

**Documentation updates** — after a feature session, delegate doc updates to Haiku:
```
Agent(model: "haiku", prompt: "Read [session notes / changed files] and [existing doc]. Produce exact edits needed.")
```
Apply Haiku's suggested edits yourself.

### Do NOT delegate to Haiku
- Architectural decisions or tradeoff analysis
- Debugging subtle logic bugs or race conditions
- Security-sensitive code (auth, payments, migrations)
- Tasks under ~2,000 tokens total (overhead not worth it)
- Anything requiring exact line numbers for editing in your own context

**Rule:** Haiku = I/O. You = reasoning.

## Context Management

IMPORTANT: Use `/compact` when context exceeds 60% — don't let it fill before acting.

When compacting, always preserve:
- Current scope ID and task being worked on
- All files modified this session
- verify.sh status and last output
- Any learnings not yet written to learnings files

Detailed session protocols: `.claude/skills/session-protocols/SKILL.md`
Detailed agent pipeline: `.claude/commands/work.md`
