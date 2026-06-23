# /retro — Cycle retrospective and knowledge graduation

You are facilitating a cycle-end retrospective. Your job is to review what was learned during the cycle and propose concrete updates to project configuration files — but NEVER apply any change without explicit human approval.

---

## Phase 1 — Gather

1. **Read all cycle learnings:**
   - `cycles/[cycle]/learnings/conventions.md`
   - `cycles/[cycle]/learnings/gotchas.md`
   - `cycles/[cycle]/learnings/decisions.md`

2. **Read all progress notes** in `cycles/[cycle]/progress/`.
   Look for: recurring themes, repeated flags, proposed doc updates that were noted but never applied.

3. **Read all QA findings** (`cycles/[cycle]/scopes/qa-*.md`).
   Look for: patterns in findings — repeated severity categories, systematic gaps in the same area.

4. **Read `cost_estimate` from each scope JSON.**
   These are approximate, session-attributed figures captured at the end of each `/work` session. Compute the cycle total and the per-scope spread. Flag any scope whose `usd` is a clear outlier (roughly ≥2× the median). An outlier is a *question*, not a verdict — surface it for the human to interrogate: over-research? plan thrashing? a scope that should have been split or tiered differently? Note if a scope's `sessions` count is high (many restarts can inflate the figure and is itself a signal).

5. **Summarise the cycle** for the human before proposing anything:
   - Scopes completed vs planned
   - Hill chart final positions across all scopes
   - Unknowns discovered during build vs during shaping (signal for shaping quality)
   - Cost: cycle total + any outlier scopes (with the caveat that figures are approximate)
   - Recurring themes — what kept coming up?

---

## Phase 2 — Propose Graduations

Review everything gathered and identify what should outlive this cycle. For each item, propose a specific update to a specific file.

### Categories of graduations

**CLAUDE.md** — conventions or constraints that should apply to ALL future cycles.
- Quote the exact text to add or change (show as a diff if modifying existing text)
- Explain why this should be permanent vs cycle-specific

**Agent files** (`.claude/agents/*.md`) — behaviour adjustments based on observed gaps.
- Name the specific agent and what to add or change
- Cite a concrete incident from the cycle where the current agent behaviour caused a problem
- Do not propose agent changes based on theory — evidence only

**brand.md** — design system refinements discovered during build.
- Only for projects using brand.md
- Quote the specific token or pattern to update
- Note why the current value was incomplete or incorrect

**Skill files** (`.claude/skills/*/SKILL.md`) — methodology or criteria refinements.
- Which skill, what to add or refine, and what gap it closes

**verify.sh** — new checks that should be permanent.
- What check to add and what it would have caught in this cycle

**architecture.md** — system-level principles discovered or refined during the cycle.
- New principles that emerged from build decisions
- Principles that were violated (reinforcement or clarification needed)
- Principles that proved wrong and should be revised
- Gaps — areas where no principle exists but should, based on what this cycle built

**Seeds for next cycle** — items that are genuinely cycle-specific but worth surfacing at the start of the next cycle rather than burying in a previous cycle's directory.
- These are NOT configuration changes — they are starting-point context for the next team

---

## Phase 3 — Present Proposals

Present ALL proposals to the human in a single structured list before doing anything:

```
## Cycle Retro: [cycle-name]

### Cycle Summary
[3-5 sentence summary: scope completion, recurring themes, quality signal]

### Proposed Graduations

| # | File | Type | One-line description |
|---|------|------|----------------------|
| 1 | CLAUDE.md | Add section | ... |
| 2 | agents/researcher.md | Modify constraints | ... |
| 3 | verify.sh | Add check | ... |

### Detailed Proposals

#### Proposal 1 — CLAUDE.md
[Full diff or new text]
Rationale: [why this graduates]

#### Proposal 2 — agents/researcher.md
[Full diff]
Evidence: [the specific incident from this cycle that justifies this change]

...

### Seeds for next cycle
- [Item 1: what to pre-populate in next cycle's learnings]
- [Item 2: ...]

### Items reviewed but NOT proposed for graduation
- [Item]: [why it stays cycle-specific]
```

**STOP. Do not touch any files.**

Ask the human: "Which proposals should I apply? Approve by number (e.g. '1, 3'), 'all', or 'none'. For any you reject, a brief reason helps document the rationale."

---

## Phase 4 — Apply Approved Changes

Wait for explicit human response before this phase.

For each approved proposal:
1. Apply the change to the specified file using Edit or Write.
2. Commit immediately with: `[retro] [cycle-name] update [filename] — [brief description]`

Do not batch all changes into one commit — one commit per file makes it easy to revert individual graduations.

For rejected proposals: note the human's reason in the retro summary so future retros have context.

---

## Phase 5 — Write Seeds File

If there are items to seed into the next cycle, write them to `cycles/_seeds.md`:

```markdown
# Seeds from [cycle-name] — [date]

These items were identified in the [cycle-name] retro as useful starting context for the
next cycle. The first /work invocation of the new cycle will detect this file, promote items
into the new cycle's learnings files, and delete it.

## Conventions to carry forward
- [item]

## Gotchas to carry forward
- [item]

## Decisions that affect future cycles
- [item]
```

---

## Phase 6 — Write Retro Summary

Save to `cycles/[cycle]/retro.md`:

```markdown
## Retrospective: [cycle-name]
**Date:** [date]
**Facilitated by:** /retro

### Cycle Summary
[3-5 sentences]

### Cost (approximate, session-attributed)
- Cycle total: $[sum of scope cost_estimate.usd]
- Per scope: [scope-id: $X, ...]
- Outliers: [scope-id at Nx median — and the suspected cause, or "none"]

### What went well
- [list]

### What didn't go well
- [list]

### Graduations applied

| File | Change | Commit |
|------|--------|--------|
| [file] | [description] | [short SHA] |

### Graduations rejected

| File | Proposed | Reason |
|------|----------|--------|
| [file] | [description] | [human's reasoning] |

### Seeded for next cycle
- [items written to cycles/_seeds.md — or "none"]
```

---

## Important Principles

- **Propose, never apply.** Every change requires explicit human approval. This is not advisory — it is a hard gate. Do not apply any changes before Phase 4.
- **Be specific.** "Update CLAUDE.md" is not a proposal. A diff is a proposal.
- **Agent changes need evidence.** Cite the specific incident. Theory is not enough.
- **Not everything graduates.** Most cycle learnings are cycle-specific. Only graduate what genuinely applies to all future work. The bar is: "Would a team starting a fresh cycle with a blank slate benefit from this?" If the answer is only "maybe," don't graduate it.
- **The retro summary is permanent.** Future retros can reference past ones to track whether the same themes recur across cycles — a signal that root causes haven't been addressed.
