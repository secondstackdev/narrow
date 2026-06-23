---
name: session-protocols
description: Progress note format and compaction guidance for /work sessions.
---

## Progress Note Format

Write progress notes to `cycles/[current]/progress/[YYYY-MM-DD]-[scope-id]-[brief-description].md` at the end of a session to preserve context for the next one:

```
## Session: [YYYY-MM-DD] — [scope-id]

### What I did
- [concrete, specific list of what was accomplished]

### State
- Hill position: [X] → [Y]
- Unknowns resolved: [list, or "none"]
- Tasks completed: [list]
- Tasks remaining: [list]

### Design decisions
- [any mockup selected, UI adjustments, or brand.md patterns applied — or "n/a"]

### Proposed doc updates
- CLAUDE.md: [proposed change, or "none"]
- brand.md: [proposed change, or "none"]
- architecture.md: [proposed change, or "none"]

### What's next
- [what the next session should pick up, with enough context to start immediately]

### Flags for human
- [anything requiring human attention — or add to open_questions in scope JSON instead]
```

## Compaction Guidance

When context is filling and compaction triggers, add to CLAUDE.md (under a "Compaction rules" section):

```
When compacting, always preserve:
- Current scope ID and task being worked on
- List of all files modified this session
- Verify.sh status and last run output
- Any learnings discovered this session not yet written to learnings files
```

If you trigger compaction manually with `/compact`, add these instructions: "Preserve: scope being worked on, files modified, verify.sh status, open unknowns."
