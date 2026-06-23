# Product Vision

## What is this product?

Guess Game (working title) is a mobile guessing game where players narrow a hidden
target from hundreds of possibilities by asking natural-language questions — a
massively expanded, AI-powered Guess Who. The player asks their *own* questions in
plain language ("does it live in water?", "does it hunt other animals?") and the
pool of candidates shrinks in response, fast and consistently. Themed entity pools
(launch theme: Animals, 500 entities) keep it fresh; multiple modes (casual, daily,
roguelite) give replayability; a daily challenge with leaderboards makes it social.

The product's whole magic lives in one moment: the player asks a question and watches
the pool shrink. That moment must be fast and trustworthy — answers come back in
sub-second time and never contradict themselves across a round. The intelligence lives
server-side as an "Answer-Key Engine": the heavy LLM work (judging entities) is rare
and frozen into auditable data; the common work is cheaply mapping a question to a
structured query over a clean, curated attribute schema that then runs deterministically.

## Who are the users?

- **Casual puzzle players** — the "Wordle-at-breakfast" crowd who want more depth and
  replay value through the day. They need a quick, satisfying daily ritual and the
  "I cracked it" feeling of deduction. Today they bounce between Wordle-likes (too
  shallow/once-a-day) and trivia (recall, not reasoning).
- **Friend groups** — people who enjoy lightweight competition and sharing scores. They
  need a spoiler-free way to compare results and a daily leaderboard to rally around.

## What does success look like?

- A player types a free-text question and the pool visibly shrinks within ~1 second,
  and the same animal is never judged differently twice in a round (trust holds).
- Players return daily for the daily challenge and share spoiler-free result cards,
  pulling friends in.
- The attribute schema and question coverage improve at scale without a human reviewing
  every question — the validation flywheel converges the schema on real demand.
- A second theme can be added server-side without an app release, proving extensibility.

## Strategic context

- **Format validated, twist is ours:** Akinator proves the large-pool deduction format;
  our twist is that the *player* asks the questions in natural language, against themed
  pools, with multiple modes and a social daily.
- **The core risk is engineering trust, not novelty:** the first prototype broke because
  the wrong LLM job was on the hot path (live judging — slow and non-deterministic) and
  the full dataset was re-sent every turn. This product re-shapes the engine so pruning
  is fast, deterministic, and auditable.
- **Constraints:** 2-person co-founder team; 6-week appetite for the MVP; online-first
  thin client; cost-sensitive (lean on cheap runtime models + free tiers for playtest).
- **Out of scope for MVP:** offline mode, multiplayer real-time, UGC themes, IAP, cloud
  accounts beyond device-local.
