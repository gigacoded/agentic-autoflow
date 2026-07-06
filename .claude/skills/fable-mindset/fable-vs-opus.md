# Fable 5 vs Opus 4.8 — what actually makes the difference in agentic coding

Companion document to `SKILL.md` (the fable-mindset skill). That file tells a
model *what to do*; this one explains *where the gap comes from* — which parts
of Fable's advantage are behavioral (closable with instructions) and which are
capability (not closable, only compensated for).

**Honesty note up front.** This is written by Fable 5 about itself. The
positioning facts below are public; the behavioral characterization is an
honest description of how the differences manifest in real coding sessions.
It deliberately contains no benchmark numbers — I won't invent figures I can't
verify. See https://www.anthropic.com/news/claude-fable-5-mythos-5 for
Anthropic's official comparison.

## Positioning

- Fable 5 is the first model in the Claude 5 family, in a new **Mythos-class
  tier that sits above Claude Opus in capability**. It is not "Opus 4.8 plus
  tuning" — it is a generation boundary, the way Opus 4 was to Claude 3.
- Fable 5 and Claude Mythos 5 share the same underlying model; Fable is the
  generally available version with additional safety measures for dual-use
  capabilities, Mythos is available without those measures to approved
  organizations only.
- Opus 4.8 remains a strong frontier model. The gap described here is a gap
  between two good models, not between a good one and a bad one — but in
  long-horizon agentic work, small per-step differences compound hard.

## The core mechanism: error compounding over long horizons

Agentic coding is a long chain of small judgments: what to read, what to
believe, what to change, whether it worked. If a model is even slightly more
accurate *per step*, the difference compounds over a 50–200-step session.
A 2% per-step error rate versus 5% is invisible on a single question and
decisive on a two-hour task. Almost everything below is a specific form of
"fewer errors per step, and better recovery when one happens."

## Where the gap actually shows up

### 1. Sustained task coherence (capability — the big one)

Fable holds a coherent working model of the task — the goal, the constraints
stated 80 turns ago, the architecture it discovered, the three things it
already ruled out — and keeps every subsequent decision consistent with it.

Opus-class models exhibit **context drift** on long tasks: a constraint from
early in the session stops binding later decisions; a fact established at step
12 gets re-derived (sometimes differently) at step 90; the model re-explores a
path it already eliminated. The information is *in* the context window — the
failure is in reliably *using* it. This is the single largest driver of the
experience gap, and no prompt fully fixes it. Mitigations: dev-docs files,
restating constraints in the task file, shorter sessions per task.

### 2. Evidence discipline as a native reflex (mostly behavioral)

Fable's default is to treat unread code as unknown. Weaker defaults produce
the classic failures: confabulating the contents of a file that was never
read, calling an API with a signature remembered from training data rather
than the one in the repo, "fixing" code based on what the function *probably*
does. Opus 4.8 does this less than its predecessors but still measurably more
than Fable — especially deep into a session when attention is spread thin.
This is the most instruction-closable gap; it's the reason `SKILL.md` leads
with the observed/inferred/assumed tier system.

### 3. Depth of causal reasoning in debugging (capability)

Given a symptom, Fable traces the causal chain further back before acting —
and, critically, checks that a candidate explanation accounts for *all*
observations, including why the failing case fails and the passing cases
pass. Opus-class debugging more often stops at the first plausible
explanation, which is how symptom-patches (null-checks, retries, reorderings)
get shipped as "fixes." The skill's hypothesis-testing rules recover a lot of
this by forcing the discipline externally, but on genuinely subtle bugs —
race conditions, cross-module invariant violations, action-at-a-distance state
— Fable simply sees further.

### 4. Calibration: knowing what it knows (capability, partially behavioral)

The most expensive agent failure mode is *confidently wrong*: reporting "done
and working" for something unverified, presenting a guess with the same tone
as a verified fact. Fable's self-reports track its actual epistemic state more
tightly — it knows the difference between "I verified this," "I inferred
this," and "I'm pattern-matching," and its language reflects it. This makes
its output *trustworthy* in the operational sense: you can act on its reports
without re-checking them. Instructions ("report faithfully, quote failures
verbatim") close part of this; the underlying self-knowledge is capability.

### 5. Effort allocation and planning economy (mixed)

Fable scales effort to the task in both directions: it doesn't write a
three-phase plan for a one-line change, and it doesn't hand-grind a 40-file
migration serially when it should decompose and parallelize. It also spends
its context budget deliberately — delegating bulk exploration, keeping
conclusions, reserving its own window for judgment. Opus-class models tend to
be uniform: same ceremony for small tasks, same serial grind for big ones,
context spent on file dumps that crowd out later reasoning.

### 6. Long-turn persistence and recovery (mostly behavioral)

Fable finishes turns: it treats a failed command as "change something and
retry," missing information as "go find it," and never ends on "next I'll…"
Opus 4.8 is decent here but degrades late in long sessions — stopping to ask
questions it could answer itself, ending on plans, or retrying a failed
command verbatim. This gap closes well with the skill's "finish the turn"
rules because it's habit, not ability.

### 7. Code taste under constraint (mixed)

Both models write good code from scratch. The difference shows in *editing
someone else's code*: Fable more reliably produces the minimal in-style diff —
matching idiom, reusing the existing helper instead of writing a twin,
declining the drive-by refactor. Weaker behavior isn't wrong code; it's a
correct patch wrapped in noise (style mismatches, narration comments,
opportunistic rewrites) that costs review time and merge risk.

### 8. Parallel and multi-agent orchestration (capability)

When work fans out to subagents, someone has to write prompts precise enough
that an agent with zero shared context does the right thing, then integrate
results that disagree. Fable is markedly better at both ends — specifying
the contract, and adjudicating conflicting findings — which is what makes
large parallel sweeps (audits, migrations) actually converge instead of
producing a pile of half-consistent outputs.

## Summary table

| Dimension | Opus 4.8 typical failure mode | Fable 5 | Closable by prompt? |
|---|---|---|---|
| Long-horizon coherence | Constraints/facts drift late in session | Holds task model across 100+ steps | Partially (external notes) |
| Evidence discipline | Occasional confabulated file/API details | Unread = unknown, by default | Largely yes |
| Debugging depth | Stops at first plausible cause | Traces to first cause; explanation must fit all observations | Partially |
| Calibration | Sometimes confidently wrong; hopeful reporting | Reports track actual epistemic state | Partially |
| Effort scaling | Uniform ceremony regardless of task size | Scales up and down; guards context budget | Largely yes |
| Turn persistence | Stalls, asks answerable questions, ends on plans (late-session) | Finishes or is genuinely blocked | Largely yes |
| Diff hygiene | Correct patch + style noise + drive-bys | Minimal, in-style diff | Largely yes |
| Orchestration | Vague subagent prompts, weak conflict resolution | Precise contracts, real adjudication | Partially |

## Practical implications for running Opus 4.8

1. **Load the fable-mindset skill** — it targets exactly the "largely yes"
   rows, which is where most of the day-to-day experience gap lives.
2. **Compensate for coherence drift externally**: keep tasks shorter, use dev
   docs / task files as durable memory, restate hard constraints in the file
   the model will re-read rather than trusting the conversation.
3. **Demand verification explicitly** and treat unverified "done" claims as
   unverified — the calibration gap means Opus's confidence is a weaker signal
   than Fable's.
4. **Reserve Fable for the "partially/no" rows**: gnarly multi-cause bugs,
   large refactors with many simultaneous constraints, long autonomous runs,
   and orchestration-heavy work. Opus 4.8 with the skill is genuinely strong
   for well-scoped, shorter-horizon tasks — that's the economical split.
