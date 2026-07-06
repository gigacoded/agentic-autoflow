---
name: agentic-loops
description: Design loops instead of one-shot prompts — pick the right loop shape (turn-based, goal-based, scheduled, proactive) for long-running or recurring agentic work, with explicit stop conditions and token budgets. Use when setting up recurring tasks, long autonomous runs, "keep going until", CI babysitting, or when deciding how to structure work that outlives a single turn.
---

# Agentic Loops (Codex)

A loop is an agent repeating cycles of work until a **stop condition** is met.
The quality of a loop is decided by three things set up front: the trigger,
the stop condition, and the verification inside each cycle. Not every task
needs a loop — start with the simplest shape that fits.

## Choosing the shape

| Loop | You hand off | Use when | Reach for |
|------|--------------|----------|-----------|
| Turn-based | The check | Exploring or deciding; short tasks | Verification skills (`verify-frontend-change`, `verify-backend-change`, `e2e-testing-framework`) |
| Goal-based | The stop condition | You know what "done" looks like and it's checkable | Codex goals (`[features] goals = true` in `.codex/config.toml`) or explicit success criteria + attempt cap in the prompt |
| Scheduled | The trigger | Work depends on an external system or schedule | `codex exec` from cron / CI / GitHub Actions |
| Proactive | The prompt itself | Recurring, well-defined streams of work | Scheduled `codex exec` + goal criteria + skills |

## Turn-based loops (every prompt)

Each turn is already a loop: gather context → act → check → respond. The
highest-leverage improvement is the **check** step. Encode manual verification
as skills so the agent self-verifies end-to-end, with quantitative pass
criteria (tests passed, zero console errors, Lighthouse ≥ N) — the more
measurable the check, the less the agent has to judge "good enough."

## Goal-based loops

State a deterministic goal and an attempt cap, and keep iterating until one is
hit:

```
Goal: all vitest suites green. Iterate — run, fix, rerun — and stop after 5
attempts or when green, whichever comes first. Report attempts used.
```

Rules for good goals:
- **Deterministic criteria** — a number, a passing command, a threshold.
  "Improve performance" is not a goal; "LCP under 2.5s on /" is.
- **Always cap attempts** — the cap is the token budget.
- Each attempt ends with the check actually run, not assumed.

## Scheduled loops

For work that changes on the other side of an external system (CI, reviews, a
queue), run Codex non-interactively on an interval:

```bash
# cron / CI step
codex exec "check open PR #42: address review comments, fix failing CI. \
If the PR is merged, do nothing and exit."
```

- Match the interval to how fast the watched thing actually changes.
- Put the completion condition in the prompt so each run can no-op and exit
  cheaply when there is nothing to do.

## Proactive loops (composed routines)

Compose the pieces for unattended recurring work — bug triage, dependency
upgrades, migrations: a scheduler triggers `codex exec`, the prompt carries
goal criteria, skills define how to verify, and a second fresh-context run
reviews the diff before it ships.

## Maintaining quality inside any loop

- Keep the codebase clean — the agent follows the patterns that already exist.
- Give the loop a way to verify its own work (the verification skills above).
- Review with fresh context: a second agent reviewing the diff is less biased
  than the author.
- When one iteration produces a bad result, don't just fix the instance —
  encode the lesson into a skill, rule (AGENTS.md), or hook so every future
  iteration improves. **Fix the system, not the output.**

## Managing token usage

- Right-size the model and reasoning effort per task in `.codex/config.toml`.
- Specific done-criteria let the loop exit sooner.
- Pilot on a small slice before a large fan-out run.
- Ship deterministic steps as **scripts the skill runs**, not steps the agent
  re-reasons each time (a script is cheaper than reasoning).

## For the agent: your own turn discipline inside a loop

- Every cycle ends with a verification step and an honest
  `Verified:` / `Unverified:` line — a loop that can't tell whether it
  succeeded will run forever or stop early.
- Never end a cycle on a plan or promise; do the work or report the blocker.
- Track state across cycles in `dev/active/<task>/` notes so compaction and
  restarts don't lose progress.
