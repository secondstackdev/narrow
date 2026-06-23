---
name: shape-up-methodology
description: Shape Up conceptual framework — appetite, scopes, hill chart, struggling moments, and pitch anatomy. Load this skill for deeper grounding in the methodology during shaping conversations.
---

Shape Up is a product development methodology from Basecamp. These are the core concepts used throughout Shape Ship.

## Appetite

Appetite is a time budget set before designing the solution, not an estimate of how long it will take. It works as a constraint that shapes what gets built:

- **Small Batch (1-2 weeks):** The solution must be genuinely small. A 2-week solution to a problem looks fundamentally different from a 6-week one.
- **Big Batch (6 weeks):** Meaningful work with room for complexity.

The question is not "how long will this take?" but "how much time is this problem worth?" That answer shapes the solution.

## The Struggling Moment

The struggling moment is how Shape Up frames problems. Instead of "users want X," write a specific scenario: a real person in a real context hitting a real obstacle.

Good: "A freelancer finishing a project at 11pm needs to send the invoice right now, but has to dig through old emails to find the client's address — by the time they find it, the momentum is gone."

Bad: "Users need a better way to manage client information."

The struggling moment anchors the solution to real need. Test each solution element against it: does this help that person in that moment?

## Scopes

Scopes are the units of work within a pitch. Not tasks, not features — they are vertical slices of the solution that could theoretically ship independently.

Good scopes:
- Deliver something meaningful end-to-end
- Can be assessed on the hill chart independently
- Have a clear done state

Bad scopes:
- "Backend work" (horizontal, not vertical)
- "Testing" (a phase, not a slice)
- Everything lumped together

Each scope gets its own hill chart position: 0.0 (unknown approach) through 0.5 (approach clear, executing) to 1.0 (done).

## The Hill Chart

Two halves:
- **Uphill (0.0–0.5):** Resolving unknowns. The work is figuring out the approach.
- **Downhill (0.5–1.0):** Executing against a known approach. The work is building.

The transition from uphill to downhill is the most important moment in a scope. At 0.5, you know exactly what to build and how. Before that, you don't.

Unknowns that aren't resolved at 0.5 create risk. Any unknown that can derail the scope should be investigated (spiked) before building starts.

## Rabbit Holes

Rabbit holes are parts of the solution that look simple but hide unexpected complexity. Shape Up's response: name them explicitly in the pitch and declare a boundary.

"We will NOT support X in this version" is a feature, not a failure. Declaring no-gos before building starts prevents scope creep and mid-cycle pivots.

## Pitch Anatomy

A complete pitch has:
1. **Problem** — the struggling moment, specific and scenario-based
2. **Appetite** — how much time this is worth, and why that scope fits the solution
3. **Solution** — breadboards showing places, affordances, and connections
4. **Rabbit holes** — named, with declared boundaries
5. **No-gos** — explicitly excluded work
6. **Scopes** — vertical slices ready for the hill chart

A pitch is not a spec. It leaves room for implementation decisions. The goal is enough definition that implementation can start without discovery derailing the appetite.

## Shaping vs Building

Shaping happens before the cycle, in a separate context. The shapers are not interrupted by implementation questions; the builders are not blocked by missing decisions.

Shape Ship enforces this separation: `/shape` produces a pitch that `/work` builds against. The pitch is signed off before building begins. Changes to the pitch during building require a human decision — the scope may need to split, or the no-go boundary may need moving.
