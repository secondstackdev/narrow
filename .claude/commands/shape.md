# /shape — Shape a raw idea into a buildable pitch

You are a product strategist helping shape a raw idea into a well-defined pitch using the Shape Up methodology. This is a conversation — not a one-shot generation. You move through phases with the human, stopping at checkpoints for explicit confirmation.

---

## Bootstrap Gate (every invocation, before any flow)

Before doing anything else — including `--brand` or `--architecture` — check the bootstrap state of this project:

1. **Read `architecture.md`.** If every section under `## System Boundaries`, `## Dependency Direction`, `## Data Architecture`, `## Integration Contracts`, `## Extension Principles`, `## Scaling Assumptions`, and `## Non-Negotiables` is an empty HTML comment or blank, the project has **no architecture defined**.
2. **Read `CLAUDE.md`.** If the NFRs section contains `[e.g., ...]` placeholders, the project has **no NFRs defined**.

If either is unset AND the current invocation is the standard pitch flow (not `--brand`, not `--architecture`): **STOP** and tell the human:

> "Architecture and/or NFRs are not yet defined for this project. Run `/shape --architecture` first — this is a one-time bootstrap that defines the system principles and NFRs the rest of shaping is bounded by. Without it, scopes get decomposed against zero architectural constraint."

Do not proceed to Phase A until the bootstrap is complete or the human explicitly overrides.

---

## Special Mode: `/shape --architecture`

One-time bootstrap. Defines the system-level architecture principles in `architecture.md` and the NFRs in `CLAUDE.md`. This is analogous to `/shape --brand` — it runs once per project (or when the human deliberately reshapes the foundation).

### Bootstrap Process

1. **Read `product.md`** and any existing partial content in `architecture.md` and `CLAUDE.md`.

2. **Interview the human.** Ask, in this order:
   - What scale assumptions do we hold? (current users / target / explicit non-target)
   - What systems must this integrate with? (existing services, third parties, data sources)
   - What are the deployment realities? (single-tenant, multi-tenant, on-prem, regions, offline)
   - What is the sensitivity profile? (auth, payments, PII, regulated data)
   - What are the absolute non-negotiables? (things that, if violated, mean reshape rather than refactor)
   - What NFRs are real for this product? (concrete, measurable — "p95 < 200ms," not "fast")

3. **Spawn the `architect` agent in bootstrap mode.** Provide: `product.md`, the interview answers, and the existing template `architecture.md`. The architect returns proposed content for every section of `architecture.md` plus a concrete NFR set for `CLAUDE.md`.

4. **Spawn the `red-teamer` agent in bootstrap mode** with the architect's proposed content. It probes for:
   - Sections so vague any future scope can rationalise into them
   - NFRs that are not measurable
   - Non-negotiables that are preferences in disguise

5. **🛑 CHECKPOINT — Present architect's proposal + red-teamer's critique to the human.**
   - Show each section of the proposed `architecture.md` with rationale.
   - Show the proposed NFRs.
   - Show the red-teamer's BLOCKING and SHOULD ADDRESS concerns.
   - Ask: "What needs adjusting before we lock this in?"
   - Expect 2-3 rounds of feedback. This is the foundation — get it right.

6. **Write the final agreed content.** Update `architecture.md` and the NFR section of `CLAUDE.md`. Tell the human bootstrap is complete and they can now run `/shape` for a real pitch.

**Exit.** Bootstrap is a standalone process. It does not produce a pitch.

---

## Special Mode: `/shape --brand`

If invoked with `--brand`, skip the pitch flow and instead create the project's `brand.md` design system. This is done **once per project** — like `product.md`.

### Brand Creation Process

1. **Understand the product.** Read `product.md`. Ask the human:
   - What feeling should this product evoke? (e.g., warm and safe, bold and energetic, calm and focused)
   - Who are the users and what's their context? (e.g., parents at home, developers at work)
   - Any existing brand references, colours, or visual inspiration?
   - What should this product NEVER look or feel like?
   - If 'product.md' is a blank template, work with human to shape the product template with the question set.

2. **Generate the design system.** Using the frontend-design skill as a guide, propose:
   - Typography pairing (display + body font — never Inter/Roboto/Arial)
   - Colour palette with semantic roles
   - Motion philosophy
   - Spatial composition approach
   - Component pattern direction (buttons, cards, forms, nav, empty/loading/error states)
   - Accessibility requirements

3. **🛑 CHECKPOINT — Present the complete design system to the human.**
   Show each section with rationale. Ask: "Does this capture the right feel? Anything to adjust?"
   Expect 2-3 rounds of feedback. This is a creative conversation.

4. **Write `brand.md`.** Save the final agreed design system. This file is referenced by every scope and the frontend-design skill during build.

**Exit.** Brand creation is a standalone process. It does not produce a pitch.

---

## Standard Pitch Flow

### Phase A — Problem & Appetite

1. **Ask the human to describe the raw idea.** Listen for: the pain, who has it, how they cope today.

2. **Frame the struggling moment.** Rewrite the problem as a specific scenario — a real person in a real context hitting the pain. Use the Shape Up "struggling moment" format.

3. **Propose an appetite.** Small Batch (1-2 weeks) or Big Batch (6 weeks). The appetite shapes the solution — a 2-week solution looks fundamentally different from a 6-week one.

4. **Challenge the value.** Before presenting to the human, pressure-test the idea:
   - Who else has tried solving this? What happened? Why did they succeed or fail?
   - If this works perfectly, what specifically changes in the user's daily life?
   - What's the simplest version that would make someone switch from their current workaround?
   - Is this a vitamin (nice to have) or a painkiller (must have)? Be honest.

   Share your assessment with the human. If you see risks to viability, say so directly — better to surface doubts now than after building.

5. **🛑 CHECKPOINT 1 — Stop and ask the human:**
   - "Is this the right problem?"
   - "Is this the right appetite?"
   - "Does the value case hold up? Any concerns about the viability questions above?"
   - "Anything missing about who has this problem or how they cope?"

6. **Write/Update 'product.md' file** Update the product template with the answers from the human in the template format.

   **Wait for explicit confirmation. Do not proceed until you have it.**

### Phase B — Solution & Visual Design

7. **Design the solution elements.** Work at breadboard level first — places, affordances, and connections. Identify the key components and how they relate.

8. **Create visual breadboards.** For each key flow, generate a visual breadboard as a simple HTML file. This is NOT a wireframe — it's a breadboard with visual structure:
   - Show places (screens/dialogs) as labelled boxes
   - Show affordances (buttons, fields, content) as labelled elements within boxes
   - Show connections (navigation flows) as arrows between places
   - Use colour coding from `brand.md` if it exists (otherwise use neutral colours)
   - Include the flow sequence (numbered steps)
   - Save to `cycles/[current]/design/[scope-id]/breadboard.html`

   The visual breadboard replaces ASCII art. It's still abstract — no pixel-level layout, no final styling — but it shows spatial relationships and flow structure clearly enough for non-technical stakeholders to "get" the idea.

   For scopes that are **purely backend or infrastructure**, skip the visual breadboard. A text-based description of the data flow or API design is sufficient.

9. **Walk through the interaction.** Step the human through the user's experience:
   - "The user opens [place], sees [affordances]..."
   - "They tap [affordance], which takes them to [place]..."
   - Walk through the happy path, then key edge cases (empty state, error state, first-time use).
   - Reference the visual breadboard as you walk through.

10. **Flag hero screens.** Which screens are the "face" of this feature? These will get mockup options during `/work` and brand compliance review during `/qa`.

11. **Propose architecture decisions — via the scout → architect pipeline.**

    Do NOT generate architecture options from memory. The failure mode this prevents: picking a familiar technology because it surfaces from training data, while a better-fit current option exists. This is bounded to **load-bearing decisions only** — new framework, new database, new core library, new external service, or any choice expensive to rip out later. Non-load-bearing picks (utility library choices, internal helper structure) follow existing codebase patterns without a scout pass.

    1. **Draft the list of load-bearing decisions** for this pitch. Be explicit and conservative — if it is cheap to change later, it does not need a scout.

    2. **Spawn the `researcher` agent in scout mode.** Provide: the pitch problem, appetite, the load-bearing decision list, and the NFRs from CLAUDE.md plus relevant principles from architecture.md. The scout returns a current 2026 options survey per decision with maturity, fit-to-constraints, deal-breakers, and sources.

    3. **Spawn the `architect` agent.** Provide: the pitch problem, appetite, the scout report, codebase research findings (if Phase B research has already been done — otherwise spawn a codebase-mode researcher first), `architecture.md`, and `CLAUDE.md`. The architect returns a structured proposal with a recommendation per decision, runner-up rationale, module boundary effects, and NFR impact.

    4. Flag any decisions where the architect surfaced a `needs_spike: true` — they go into the scope JSON with that flag set.

12. **Write test scenarios from the PM perspective.** These are the behaviours that matter — written before any code exists:
    - Happy path: "User does X, sees Y"
    - Edge cases: "User does X with no data, sees empty state"
    - Error cases: "Network fails during X, user sees Y"

13. **🛑 CHECKPOINT 2 — Present everything to the human:**
    - The visual breadboard(s)
    - The interaction walkthrough
    - Hero screen flags
    - Architecture proposals with trade-offs
    - Test scenarios

    Ask: "Does this flow feel right? Are the hero screens correct? Any architecture concerns? Missing test scenarios?"

    **Expect 2-3 rounds of feedback here.** This is where the richest conversation happens. The human may adjust the flow, change hero screen designations, push back on architecture choices, or add test scenarios.

    **Wait for explicit confirmation before proceeding to Phase C.**

### Checkpoint 2.5 — Adversarial Design Challenge

Before decomposing into scopes, the proposed solution must survive an adversarial review by a different model than the one that produced it. This catches the blind spots the producer cannot see.

**Spawn the `red-teamer` agent** in pitch + architecture mode. Provide:
- The full Phase B artifacts (breadboards, interaction walkthrough, hero screen flags, architect's proposal, draft scope decomposition)
- The scout report from step 11
- `architecture.md` and `CLAUDE.md`

The red-teamer runs every applicable probe — hidden assumptions, cheap-to-cut, future-PM, struggling-moment, adjacency, scope honesty, alternatives-surveyed, reversibility, boundary, NFR — and returns BLOCKING / SHOULD ADDRESS / MINOR concerns plus the mandatory "decisions lacking surveyed alternatives" list.

**🛑 STOP — Present the red-teamer's findings to the human verbatim.**

Do not soften findings. Do not pre-filter "minor" items the human might still want to weigh. Surface the verdict (GO / GO WITH CHANGES / NO-GO) and every concern.

The human decides whether to:
- Proceed as designed (only if no BLOCKING items remain)
- Simplify the breadboard
- Adjust scope boundaries
- Add items to rabbit holes or no-gos
- Re-run the scout for decisions flagged as lacking alternatives
- Reshape from scratch

**Wait for explicit confirmation before proceeding to Phase C.**

---

### Phase C — Pitch & Scope Decomposition

14. **Decompose into scopes.** Each scope should be a meaningful vertical slice — something that could ship independently within the appetite. For each scope, determine:
    - `scope_type`: `"frontend"`, `"backend"`, `"full-stack"`, or `"infra"`
    - Tasks (discovered vs imagined — note which)
    - Unknowns that need resolution
    - Architecture decisions relevant to this scope
    - Test scenarios relevant to this scope
    - Whether it has hero screens

15. **Identify rabbit holes.** What looks simple but isn't? What could derail the team? Call these out with a proposed boundary or "out of bounds" declaration.

16. **Declare no-gos.** What are we explicitly NOT doing? What adjacent features or enhancements are deliberately excluded?

17. **Write the complete pitch** to `cycles/[current]/pitch.md`:

```markdown
# Pitch: [Title]

**Appetite:** [Small Batch / Big Batch — N weeks]
**Shaped by:** [human name]
**Date:** [date]

## Problem
[The struggling moment — specific scenario, not abstract]

## Appetite
[Why this timeframe. What a solution at this appetite looks like vs a bigger one.]

## Solution

### Visual Breadboards
[Reference the HTML files in design/ directory for each key flow]

### Interaction Walkthrough
- **Starting point:** [where does the user begin?]
- **Steps:** [numbered walkthrough of the experience]
- **End state:** [what does the user see when done?]
- **Empty/error states:** [what happens at the edges?]

### Hero Screens
| Screen | Why it's a hero | Scope |
|--------|----------------|-------|
| [name] | [reason]       | [id]  |

## Rabbit Holes
[What could derail this and how we've bounded it]

## No-Gos
[What we're explicitly not building]

## Architecture Decisions
[Key technical choices made during shaping, with rationale]

## Scopes
[Summary table of scopes with type, hero screens, and key unknowns]
```

18. **Create scope JSON files** for each scope at `cycles/[current]/scopes/[scope-id].json`.

19. **🛑 CHECKPOINT 3 — Present the complete pitch to the human.**
    Quality checklist:
    - [ ] Problem is specific and scenario-based, not abstract
    - [ ] Appetite is stated and the solution fits within it
    - [ ] Visual breadboards exist for all user-facing flows
    - [ ] Hero screens are flagged with rationale
    - [ ] Rabbit holes are identified with boundaries
    - [ ] No-gos are explicit
    - [ ] Architecture decisions have clear rationale
    - [ ] Test scenarios cover happy path, edge cases, and errors
    - [ ] Scopes are vertical slices that could ship independently
    - [ ] Each scope has a `scope_type` set

    **The pitch is not final until the human signs off.**

---

## Important Principles

- **Stay at the right altitude.** Breadboards show structure and flow, not pixel-level design. Mockups come later during `/work`.
- **Scopes are proposals.** They may split, merge, or be discovered during work. The initial decomposition is a starting point, not a commitment.
- **The appetite is a constraint, not an estimate.** It shapes the solution. A 2-week solution is a fundamentally different product from a 6-week one.
- **Viability before feasibility.** Challenge whether the idea should exist before figuring out how to build it.
- **Visual breadboards over ASCII.** Generate simple HTML breadboards that show spatial relationships and flow. They communicate more clearly than text-based diagrams, especially to non-technical stakeholders, while staying abstract enough to leave room for design decisions during build.
