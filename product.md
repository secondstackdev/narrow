# Product Vision

## What is this product?

Narrow (working title) is a mobile guessing game where players pin down a hidden target —
an animal, a city, a world leader, a literary character — by asking free-form natural
language questions. Like Guess Who, but instead of 20 fixed faces, the pool starts at
hundreds. Instead of a fixed list of attributes, players ask whatever they want. Under the
hood an AI interprets each question, the game answers honestly, and the visible pool of
candidates narrows toward the answer.

The horizon vision is nine themed worlds (cities, animals, world leaders, cultural figures,
landmarks, cuisine, mythology, sports heroes, literary characters), three game modes
(casual, daily, roguelite), and a social layer of leaderboards and shareable score cards.
Interpretation runs server-side: cloud LLMs enrich datasets at build time and power the
runtime interpretation engine. The game is online-first.

This document holds the long vision. Each cycle's pitch is much smaller — we earn the right
to expand by validating the open risks one at a time.

## Who are the users?

Casual mobile gamers and puzzle enthusiasts who play Wordle at breakfast and want more depth
and replay value through the day. Friend groups who enjoy lightweight competition. A global
audience — the dataset breadth is intended so a player in Brazil, Japan, or Nigeria all find
something built for them. Multilingual support is a v2 expansion; English is the launch
surface.

The user we are explicitly NOT targeting is the trivia player who wants multiple choice or
recall tests. Narrow rewards reasoning, not knowledge.

## What does success look like?

- A player finishes a round and immediately wants another.
- A player tells a friend about it unprompted.
- A player checks the daily challenge before opening any other app.
- The "I cracked it" moment lands hard enough to be worth sharing.

The leading indicator we watch in early playtesting: do testers ask for another round
without being prompted? If yes, we have something. If no, no amount of polish saves it.

## Strategic context

**Closest comp:** Akinator (AI asks you questions to guess what you're thinking) validates
the "big pool + deduction" format at scale. Narrow inverts the role — the player asks the
questions — which we believe makes each round more creative and personal.

**Honest read:** This is a vitamin, not a painkiller. Nobody needs Narrow. But the best
mobile habits are vitamins. Wordle proved a daily puzzle with a social share mechanic can
become a ritual. The risk is not "will people want this" — it is "will the question-asking
loop feel good enough that rounds are satisfying, not frustrating?" That is the question
every cycle of this project must keep validating.

**Architecture horizon:** A three-layer system separating data, interpretation, and game
logic. Build-time enrichment populates a structured attribute database. A swappable
interpretation engine maps natural language to structured queries. The game engine filters
and scores. The interpretation layer is the entire product — a slow or unreliable
interpreter would kill the game regardless of how good everything else is. (Online-first,
server-side interpretation is the committed direction; on-device interpretation is *not*
pursued.)

**Business model intent (figures indicative):** One-time purchase (~$4.99) for the core
nine datasets, three of which are free. DLC packs (~$1.99–$9.99) for specialist topics.
Optional supporter tier (~$1.99/year) for those who want to fund ongoing development. The
positioning commitment that matters more than the exact numbers: **no ads, no subscriptions,
no engagement-loop friction.**

**Visual identity intent:** Generic silhouettes — never photographs of real people, never
licensed branding. The silhouette is the mystery; revealing the entity at round end is what
makes the moment land. As candidates are eliminated, the remaining pool clusters by visual
attribute (national colour, era, type), giving players an emergent meta-signal. Note: this
mechanic is unproven and should be prototype-tested before being committed to as the visual
identity.

**What is de-risked vs. what is not:**
- ✅ Legal exposure at launch: factual public-domain datasets, generic silhouettes, no
  licensed IP at launch
- ⏳ Fun of the core loop — cycle 01 (PoC)
- ⏳ Interpretation accuracy at production-grade cost — depends on PoC findings
- ⏳ Visual mechanic of shrinking colour-clustered pool — needs prototype test
- ⏳ Right-of-publicity exposure on real-person themes (world leaders, cultural figures,
  athletes) — needs legal sign-off before those paths open

**Working principle:** Each cycle must validate one or more open risks. This vision evolves
with learnings; the document above is updated during cooldown when learnings invalidate or
refine it. Cycle pitches do not rewrite this file.
