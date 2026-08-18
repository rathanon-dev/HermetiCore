---
name: adhd
description: Parallel divergent ideation for coding agents. Spawns N isolated branches under different cognitive frames (regulator, biology, speedrunner, 10-year-old, $0 budget), scores, clusters, prunes traps, and deepens top survivors. Use on /adhd, "ADHD mode", brainstorm/ideate intents, or open-ended design, architecture, naming, API/SDK surface, and fuzzy-debugging decisions. Skip for syntax, lookups, bugs with known root cause, or closed phrasing ("quick", "standard", "canonical", "textbook"). Full pre-flight gate is in the skill body.
license: MIT
---

# ADHD

Stop picking the textbook answer. The first three answers the model would
give are the answers a senior engineer would give in thirty seconds.
Correct. Forgettable. The interesting answers live past number three, in
the awkward middle nobody walks into. This skill makes the model walk
there.

## Pre-flight (run before Phase 1)

This skill is expensive. About 10 Agent calls, 30 to 90 seconds wall clock,
5 to 10x a single answer. Do not pay that cost when a direct answer is
better. Run this gate before Phase 1.

**Step 1. Explicit invocation check.**

If the user typed `/adhd` or explicitly asked for ADHD mode, "use the
adhd skill", or "run ADHD on this", **SKIP the rest of this section and go
straight to Phase 1**. The user opted in. Do not second-guess.

**Step 2. Self-judge (only if Step 1 did not match).**

Ask yourself three questions. If the answer to any is no, ABORT.

1. **Open-ended?** Would a senior engineer give multiple viable answers
   here, or is there one canonical answer? If canonical, abort.
2. **High-stakes?** Is the cost of the obvious answer being wrong actually
   high? Architecture decisions, public API surfaces, naming a real
   product, fuzzy bugs with no known root cause, schema design = yes.
   Side project at 11pm = no.\n3. **Open phrasing?** Did the user avoid words like "quick", "standard",
   "canonical", "textbook", "just", "one-line"? If they used any of those,
   they want the direct answer. Abort.

If all three checks pass, proceed to Phase 1.

## The loop

Two strict phases. Mixing them kills idea quality, because the critic
strangles the generator.

### Phase 1 — Diverge (no critic)

For the problem P:

1. Pick 5 cognitive frames from the table below. Bias toward engineering
   tags when the problem is code-shaped. Always include at least one wild
   frame to keep range.

2. Spawn 5 **parallel** Agent/Task tool calls. One per frame.

### Phase 2 — Focus (critic on)

1. Score and cluster ideas.
2. Deepen top 3 candidates.
3. Render structured output.
