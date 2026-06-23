# CLAUDE.md — Shape Ship v6

## Project

- **Name:** [project name]
- **Stack:** [e.g., React Native / Expo / TypeScript / Supabase]
- **Repo:** [GitHub URL]

## Non-Functional Requirements

- [e.g., Offline-first: core features must work without network]
- [e.g., Performance: initial load < 3s on 3G]
- [e.g., Accessibility: WCAG 2.1 AA minimum]
- [e.g., i18n: Traditional Chinese + English from day one]

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
