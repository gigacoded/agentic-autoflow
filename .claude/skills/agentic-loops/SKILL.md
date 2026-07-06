---
name: agentic-loops
description: Design loops instead of one-shot prompts — pick the right loop primitive (turn-based, /goal, /loop, /schedule, proactive routines) for long-running or recurring agentic work, with explicit stop conditions and token budgets. Use when setting up recurring tasks, long autonomous runs, "keep going until", CI babysitting, or when deciding how to structure work that outlives a single turn.
---

# Agentic Loops

A loop is an agent repeating cycles of work until a **stop condition** is met.
The quality of a loop is decided by three things you set up front: the trigger,
the stop condition, and the verification inside each cycle. Not every task
needs a loop — start with the simplest primitive that fits.

## Choosing the primitive

| Loop | You hand off | Use when | Reach for |
|------|--------------|----------|-----------|
| Turn-based | The check | Exploring or deciding; short tasks | Verification skills (`verify-frontend-change`, `verify-backend-change`, `e2e-testing-framework`) |
| Goal-based | The stop condition | You know what "done" looks like and it's checkable | `/goal` |
| Time-based | The trigger | Work depends on an external system or schedule | `/loop`, `/schedule` |
| Proactive | The prompt itself | Recurring, well-defined streams of work | `/schedule` + `/goal` + skills + auto mode |

## Turn-based loops (every prompt)

Each turn is already a loop: gather context → act → check → respond. The
highest-leverage improvement is the **check** step. Encode manual verification
as skills so the agent self-verifies end-to-end, with quantitative pass
criteria (tests passed, zero console errors, Lighthouse ≥ N) — the more
measurable the check, the less the agent has to judge "good enough."

## Goal-based loops (`/goal`)

Define done; an evaluator sends the agent back until the goal is met or a turn
cap is reached.

```
/goal get the homepage Lighthouse score to 90 or above, stop after 5 tries
/goal all vitest suites green, stop after 4 tries
```

Rules for good goals:
- **Deterministic criteria** — a number, a passing command, a threshold.
  "Improve performance" is not a goal; "LCP under 2.5s on /" is.
- **Always set a turn cap** ("stop after 5 tries") — it is the token budget.
- `/goal` with no arguments shows turns and token usage so far.

## Time-based loops (`/loop`, `/schedule`)

For work that changes on the other side of an external system (CI, reviews,
a queue):

```
/loop 5m check my PR, address review comments, and fix failing CI
```

- Match the interval to how fast the watched thing actually changes — don't
  poll a 20-minute pipeline every 2 minutes.
- `/loop` runs locally and dies with your machine; `/schedule` creates a cloud
  routine (cron) that survives it. One-time future runs also use `/schedule`.
- Stop conditions: you cancel it, or the work completes (PR merged, queue
  empty). State the completion condition in the prompt so the loop can end
  itself.

## Proactive loops (composed routines)

Compose the primitives for unattended recurring work — bug triage, dependency
upgrades, migrations:

```
/schedule every hour: check the project-feedback channel for bug reports.
/goal: don't stop until every report found this run is triaged, actioned, and
responded to. When fixing a bug, explore solutions in parallel worktrees and
have a judge adversarially review them.
```

Ingredients: `/schedule` for the trigger, `/goal` for done, skills for how to
verify, subagents/worktrees for parallel attempts, a reviewer agent with fresh
context for judgment, auto mode for permissions.

## Maintaining quality inside any loop

- Keep the codebase clean — the agent follows the patterns that already exist.
- Give the loop a way to verify its own work (the verification skills above).
- Use a second agent for review (`/code-review`): fresh context, no anchoring
  on the author's reasoning.
- When one iteration produces a bad result, don't just fix the instance —
  encode the lesson into a skill, rule, or hook so every future iteration
  improves. **Fix the system, not the output.**

## Managing token usage

- Right-size the primitive and the model; small recurring tasks can run on
  smaller/faster models, judgment calls on the most capable one.
- Specific done-criteria let the loop exit sooner.
- Pilot on a small slice before a large fan-out run.
- Ship deterministic steps as **scripts the skill runs**, not steps the agent
  re-reasons each time (a script is cheaper than reasoning).
- Review with `/usage` (per-skill/subagent/MCP breakdown) and `/workflows`
  (per-agent usage, stoppable).

## For the agent: your own turn discipline inside a loop

- Every cycle ends with a verification step and an honest
  `Verified:` / `Unverified:` line — a loop that can't tell whether it
  succeeded will run forever or stop early.
- Never end a cycle on a plan or promise; do the work or report the blocker.
- Track state across cycles in `dev/active/<task>/` notes so compaction and
  restarts don't lose progress.
