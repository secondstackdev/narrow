# Architecture Principles

This file defines the system-level architectural principles for this project.
It is the source of truth for structural decisions that span multiple scopes and cycles.
Updated during retros (with human approval) or when a shaping session reveals a new principle.

> **Product:** Narrow (working title) — a server-side "Answer-Key Engine" guessing
> game. Launch theme: Animals (500 entities). See `product.md` for the vision.
> Foundation set during `/shape --architecture` bootstrap (architect proposal +
> red-team pass + founder decisions).

## System Boundaries

The system is split into eight owned modules. "Owns" means: the single place that may
write to that data/contract; everyone else reads through it.

- **Question API (edge boundary)** — owns the client↔server contract. Accepts a round
  token + a free-text question; returns ONLY the per-question verdict applied to the
  round and the remaining-candidate count/delta. Never returns the target, the dataset,
  attribute values, entity ids, or answer-key contents. Owns rate-limiting, request
  normalization entry, and round-token validation.

- **Answer-Key Engine** — owns question *resolution*. Orchestrates the per-question
  pipeline: normalize → mappingCache lookup → on miss, one classify-and-map LLM call
  returning `query | judge | decline` → on `judge`, invoke a JUDGE job and FREEZE an
  answer key. Owns the freeze contract (first resolution becomes permanent truth) and
  promotion-candidate flagging. Delegates predicate evaluation to the Predicate Engine.
  Which model runs is config (behind the model-adapter port), not its concern.

- **Predicate Engine** — owns deterministic evaluation of a predicate tree
  (`==, in, >, <, between, ∋, AND, OR`) against the dataset, per entity. Owns the
  null/uncertainty rules (null on a referenced attribute → `maybe`; ambiguous boundary
  → `maybe`) and the prune rule (`no` → eliminated; `yes | maybe` → kept). Has ZERO LLM
  dependency. Pure function of (predicate, dataset row). The one module that must be
  exhaustively testable across all 500 entities offline.

- **Cache/Key Store** — owns persistence of `mappingCache` (normalized question →
  resolution), `answerKeys` (key_id → per-entity yes/no/maybe), and the resolution audit
  log. The global shared truth store: a write here is immediately live for all players.
  Owns no resolution logic; it is a keyed, write-once store.

- **Dataset & Schema Store** — owns the 500-entity dataset and the curated
  AttributeSchema (~25–35 atomic attributes: categorical w/ controlled vocab, numeric,
  concept-boolean). Read-only at runtime. Written ONLY by the gated promotion API and
  theme authoring. Source of truth for "what is true about an entity."

- **Daily/Identity Service** — owns (a) the server-authoritative daily target assignment
  per theme, (b) the unique-display-name registry (server-enforced uniqueness), (c)
  device-bound streaks/stats, and (d) the daily leaderboard. Owns the target secret: the
  target id never crosses the Question API boundary. Owns the identity integrity boundary
  (see Non-Negotiables): a claimed name cannot be assumed by another device.

- **Validation Harness** — owns the offline/build-time correctness machinery: the
  dual-path cross-check (runtime mapper vs strong oracle), synthetic-player session runs
  (incl. the launch pre-warm battery), the deterministic invariant gate
  (TARGET-NEVER-CUT, NO-CONTRADICTIONS across all 500), poisoning re-validation of newly
  frozen resolutions, and promotion-candidate scoring. Reads everything; its ONLY write
  into the runtime path is a promotion *proposal* submitted to the gated promotion API
  for human approval. It has NO direct write capability to the Cache/Key Store or the
  Dataset & Schema Store — ever, approved or not.

- **Flutter Client (thin)** — owns presentation, input capture, local round UI state,
  and the three mode shells (casual / daily / roguelite). Owns NO game truth: no dataset,
  no schema, no keys, no target. The server is authority for all correctness.

## Dependency Direction

Allowed dependencies (caller → callee). Anything not listed is forbidden.

- Flutter Client → Question API. ONLY. The client may not reach any other module.
- Question API → Answer-Key Engine; Question API → Daily/Identity Service (round token /
  target lookup, server-side only).
- Answer-Key Engine → Predicate Engine; → Cache/Key Store; → Dataset & Schema Store
  (read); → runtime LLM via the model-adapter port.
- Predicate Engine → Dataset & Schema Store (read) ONLY. No other dependency, and
  explicitly NO dependency on any LLM, network, or cache.
- Validation Harness → may READ Answer-Key Engine, Predicate Engine, Cache/Key Store,
  Dataset & Schema Store, and the strong-oracle + synthetic-player models. Its only WRITE
  is a promotion proposal to the gated promotion API.

Forbidden (structural, not stylistic):

- **Client → Dataset / Schema / Keys / Target: NEVER.** Cheat-resistance line.
- **Predicate Engine → LLM / network / cache: NEVER.** Determinism line.
- **Answer-Key Engine → Validation Harness: NEVER.** The engine must never depend on the
  thing that judges it (blind-spot independence; the harness is downstream, not upstream).
- **Validation Harness → direct write to Cache/Key Store or Dataset & Schema Store:
  NEVER.** All harness-originated changes flow through the gated promotion API after
  human approval (until a category graduates per the autonomy ladder). No side-channel.
- **Any module → a concrete model or host SDK directly: NEVER.** All LLM access goes
  through the model-adapter port so the deferred model/host choice stays swappable.
- **Daily/Identity Service → Answer-Key Engine: NEVER.** One-way; identity must not
  couple the secret-target path to question-resolution logic.

## Data Architecture

Source of truth per domain:

- **Dataset (500 entities, attribute values):** Dataset & Schema Store. Read-only at
  runtime. Ground truth the Predicate Engine evaluates against.
- **AttributeSchema:** Dataset & Schema Store. Changed only via the gated promotion API.
- **mappingCache (normalized question → resolution):** Cache/Key Store. WRITE-ONCE per
  normalized key (freeze-on-first). First resolver writes; everyone reads thereafter.
- **answerKeys (key_id → per-entity yes/no/maybe):** Cache/Key Store. WRITE-ONCE, frozen
  on creation by a JUDGE job. Immutable once written; corrections are NEW keys + audit.
- **Query results (predicate over dataset):** NOT stored. Computed live, deterministically,
  every time. Cheaper and safer to recompute than to risk stale cache vs. schema drift.
- **Daily target:** Daily/Identity Service. Server-authoritative, never exposed.
- **Identity / name registry:** Daily/Identity Service. Unique display name is the key.
- **Streaks / stats:** Daily/Identity Service, bound to (device, claimed name).
- **Leaderboard:** Daily/Identity Service, derived from completed daily rounds.

Data-flow direction: dataset/schema flow INTO resolution; resolutions flow INTO the
cache; the cache flows OUT to all players. No backflow from client into any truth store.

**Consistency model (load-bearing — stated exactly, not hedged):** the shared cache is
**write-once-then-immutable, single-writer-wins**. The FIRST successful resolution of a
normalized key becomes permanent truth for ALL players, committed via a
**compare-and-swap on the normalized key** (first-write-wins; concurrent resolvers of the
same novel key produce ONE winner, losers discard their compute and read the winner).
This is intentional — the playerbase warms one global cache. **Read-replica lag /
eventually-consistent / stale-read interpretations are explicitly forbidden:** a reader
must never see a key as unresolved after it has been committed, and must never see two
different committed values for one key.

**Poisoning risk + mitigations:** a wrong first resolution is live for everyone until
corrected. Mitigations, baked into the structure: temp-0 + structured output for
reproducibility; the invariant gate as a pre-write deterministic check; the keep-not-cut
bias so a wrong freeze degrades to "too generous," never "target eliminated"; full audit
+ trivial rollback (frozen data, replace key_id, no schema migration); and the Validation
Harness re-validates newly frozen resolutions against the strong oracle within the
detection window (NFR — see "Time-to-detect poisoning"). Low-confidence MAP resolutions
MAY be resolved live but NOT frozen until corroborated (deferred-freeze), so a shaky
first answer never becomes global truth.

## Integration Contracts

STABLE (changing these requires a pitch — they are public or cross-module):

- **Question API contract (client↔server):** request = round token + free-text question;
  response = per-question verdict + remaining candidate count/delta. NEVER includes
  target, entity ids, attribute values, or key contents. Adding fields is
  additive-compatible; removing/repurposing is a pitch.
- **Entity / AttributeSchema data model + predicate node types** (`==, in, >, <, between,
  ∋, AND, OR`). The Predicate Engine and the dataset both bind to this; it is the spine
  of determinism.
- **Resolution record shapes:** `{normalized_question → resolution}` and
  `{key_id → per-entity verdict}`. The audit + rollback story depends on these.
- **Model-adapter port:** the interface the Answer-Key Engine calls for MAP/JUDGE
  (`classify-and-map` → `query | judge | decline`; `judge` → per-entity verdict over a
  cached catalog). The interface is stable; the implementation behind it is volatile.

VOLATILE (may change within a scope, behind a stable port):

- Concrete runtime model and host. Prompt text and formatting. Context-caching mechanics.
  Cache store technology. Synthetic-player and oracle model families. Internal
  normalization rules (so long as freeze semantics hold).

## Extension Principles

- **New themes = new server-side datasets + schema + seeded cache, no app release.** A
  theme is a ~500-entity set conforming to the Entity/AttributeSchema model plus a seeded
  starter cache. Shipping a theme is a data operation, not a client release. This is the
  primary extensibility proof and must stay true.

- **New game modes plug in at the Client + Daily/Identity layer only — the MODE
  CONTRACT.** A mode MAY vary only: (a) target-selection policy, (b) round-token
  lifecycle / session rules, and (c) scoring. A mode may NEVER introduce new predicate
  node types, new cache-key dimensions, or per-mode answer keys, and may never add
  parameters to the resolution call. If a proposed mode needs any of those, it is not a
  mode — it is an engine change and requires a pitch. (This closes the "it's just a mode"
  loophole: the engine is mode-agnostic by contract.)

- **New attributes = the gated promotion loop ONLY.** Real question logs surface concept
  gaps via dual-path disagreement/decline. The Validation Harness scores promotion
  candidates; a human approves; the new column ships behind the invariant gate + a canary.
  No ad-hoc schema edits in the runtime path.

- **The autonomy ladder (where graduation thresholds live — NOT in Non-Negotiables).**
  - *Autonomous now:* caching high-confidence mappings; auto-declining out-of-domain /
    subjective questions.
  - *Human-gated until graduated:* promoting NEW attribute columns.
  - *Graduation bar (exact):* a change category graduates to autonomous only when it
    reaches **≥ 99.0% agreement with human adjudication over a category validation set of
    ≥ 200 human-labelled decisions**, with **three independent model families concurring**,
    measured over the trailing validation batch. Crossing this bar is BY DESIGN, not a
    reshape — that is precisely why it lives here and not in Non-Negotiables. Graduation
    is reversible by replacing data; nothing about logic migrates.
  - *Validator-availability rule:* if fewer than three independent model families are
    available, promotion/validation decisions HALT. No fallback approval path, no
    reduced-quorum decision. Decisions wait for the quorum; they are never made without it.

## Scaling Assumptions

Built for the launch target (hundreds-to-a-few-thousand DAU, single region, single shared
cache). Massive/viral scale is an EXPLICIT non-target, deferred as a known trade.

- **Single shared cache store, single region:** intentional. One global cache is the whole
  point at this scale (one player warms it for all). At 10x DAU, reads still dominate and
  writes are write-once; the rework risk is write-contention on first-resolve of viral
  novel questions, not reads.
- **No HA / no multi-region / no read replicas in MVP:** deferred. Online-only, single
  region means a region outage = game down. Accepted for MVP (see Availability NFR). On a
  regional outage or capacity exhaustion, the client shows the clean "reconnect to play"
  state — it never hangs and never fabricates a result.
- **Cold-start launch gate (decided):** launch day is otherwise 100% cache-miss across the
  question space (worst cost + latency + judge-rate simultaneously). Therefore the
  synthetic-player harness MUST pre-warm the common question space before real traffic is
  admitted — launch is gated on the synthetic battery's miss rate falling below 10%. This
  converts the compound launch-day risk into a pre-launch step.
- **Live query recomputation (not cached):** scales with predicate complexity × 500, not
  dangerously with traffic; deterministic and cheap. Survives growth.
- **LLM cost scales with cache MISS rate, not DAU.** As the cache warms, marginal LLM cost
  per question trends toward zero. This is the economic scaling thesis; the
  cost-per-1000-questions NFR is the tripwire if it fails to hold.
- **What needs rework at 10x (none built now; all isolated behind the boundaries above):**
  identity (device + name with no recovery won't survive a larger returning audience);
  leaderboard write throughput; cache store horizontal scaling; per-region latency if the
  audience globalizes.

## Non-Negotiables

Crossing any of these forces a RESHAPE, not a refactor. Each is a permanent structural
line. (Tunable thresholds — e.g. the promotion graduation bar — deliberately live in the
autonomy ladder above, not here, because they are designed to move.)

1. **Determinism / freeze contract.** Every resolution is computed at temp 0 with
   structured output and FROZEN on first encounter. Identical inputs yield identical
   verdicts forever. No live re-judging of an already-frozen question.
2. **TARGET-NEVER-CUT (P0).** No truthful yes/maybe question may eliminate an entity while
   it is the hidden target. Any violation is P0 and blocks release. Enforced by the
   keep-not-cut bias and the exhaustive invariant gate across all 500.
3. **NO-CONTRADICTIONS.** Complementary question pairs must never both resolve `yes` for
   the same entity. Deterministically checked across all 500.
4. **No live JUDGE on the hot path.** The hot path is a cache hit or a single cheap MAP
   call. The expensive judge runs rarely and off the common-case critical path. Putting
   heavy judging on the hot path is the original failure and is banned.
5. **No per-question dataset resend.** The dataset never leaves the server per question;
   judging uses a context-cached catalog. Re-sending the dataset per turn is banned.
6. **Server-authoritative secrets.** Target, dataset, attribute values, and answer keys
   never cross the client boundary. The client learns only per-question verdicts + counts.
7. **Three independent model families for any autonomous validation decision.** Runtime
   mapper, strong oracle, and synthetic players must come from independent model families
   so they don't share blind spots. No single-model approval may graduate or make an
   autonomous change; if the three-family quorum is unavailable, validation HALTS.
8. **All schema/cache mutation flows through the gated path.** New attribute columns and
   any change to frozen truth occur ONLY via the gated promotion API (human-approved until
   a category graduates per the autonomy ladder), behind the invariant gate + canary.
   No ad-hoc or side-channel writes to the Cache/Key Store or Dataset & Schema Store.
9. **Keep-not-cut under uncertainty.** Null, ambiguous boundary, or objective-but-unjudged
   inputs bias to `maybe` (keep), never to `no` (cut). Asymmetric error cost.
10. **Identity integrity.** Display names are server-enforced unique; a claimed name cannot
    be assumed or overwritten by another device. In MVP there is no proof-of-ownership and
    therefore no name reclaim or account recovery — a name, once claimed, is bound until
    explicitly released. This is an impersonation/trust boundary distinct from secret-leakage
    (#6), and changing it (adding recovery/auth) is a `[SENSITIVE]` reshape.

---

## Deferred load-bearing decisions (resolved by the scout → architect pipeline during the pitch flow — NOT decided here)

1. **Runtime host / deployment platform** — lean minimal-ops, single region. No module
   binds to a host SDK directly. Reversibility: moderate.
2. **Runtime model (MAP/JUDGE), Flash-Lite-class** — behind the model-adapter port. Sets
   the absolute numbers for NFRs 2/3/9. Reversibility: cheap (port).
3. **Strong-oracle model family** (build/test truth) — must be independent from the runtime
   mapper (Non-Negotiable #7). Reversibility: cheap.
4. **Synthetic-player model family** (cheap, prod-like) — must be independent from both
   above. Reversibility: cheap.
5. **Cache/Key store technology** — must support write-once-per-key, compare-and-swap
   first-write-wins on concurrent novel resolves, an audit log, and trivial key replacement
   for rollback. Reversibility: moderate (data migration if changed late).
