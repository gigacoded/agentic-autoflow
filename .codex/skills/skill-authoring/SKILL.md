---
name: skill-authoring
description: Write or edit a skill in this kit so it activates reliably and a junior engineer or smaller model can execute it without extra context. Use when adding a new skill, porting one from another project, encoding a lesson from a review or failed loop, or when a skill exists but never fires. Covers description craft, body structure, trigger rules, the Codex mirror, registration, and verification. For hooks (deterministic checks) see hook-development instead.
---

# Authoring Skills

A skill is knowledge that must survive its author. Write every skill for a
capable junior with no memory of this conversation: procedures, not vibes;
exact commands, not "run the usual checks"; pass/fail criteria, not "make
sure it looks right".

## Skill, rule, hook, or CLAUDE.md?

| The lesson is... | Encode it as |
|---|---|
| A procedure the agent should follow when the situation applies | Skill (`.claude/skills/<name>/`) |
| A constraint tied to specific paths or topics | Rule (`.claude/rules/*.md`) |
| A check that must run every time, deterministically | Hook — see `hook-development` |
| A short project-wide fact or command | `CLAUDE.md` / `AGENTS.md` (keep them lean) |

If the same mistake shows up twice, stop patching instances — encode the
lesson in one of these. Fix the system.

## Anatomy

```
.claude/skills/<name>/
├── SKILL.md          # frontmatter + body, target ≤ 150 lines
└── resources/        # optional deep reference, loaded only on demand
```

Naming: kebab-case; verb-first for procedures (`verify-frontend-change`),
domain-noun for knowledge (`convex-backend-dev`).

## The description is the API

Claude Code and Codex decide whether to load a skill from the frontmatter
`description` alone — the body is invisible until then. Use this shape
(`verify-frontend-change` is the house benchmark):

1. First sentence: the job, phrased around the use case, imperative mood.
2. "Use when/after ..." — trigger situations in the words a user would type.
3. Scope boundary — what it does NOT cover, naming the neighbor skill.

Anti-patterns: "Helper for X" (no trigger), listing section headings instead
of situations, describing the document instead of the work.

## Writing the body for smaller models

These rules are what let a weaker model execute the skill unsupervised:

- State the failure mode being guarded against in bold, up front
  ("**Never report a UI change as complete based on a successful edit alone.**").
- Numbered procedure, one action per step, each step ending in an observable
  result ("Confirm the page rendered — not an error boundary").
- Copy-pasteable commands and exact tool names. Never "run the type check";
  write `npx tsc --noEmit`.
- Decision tables instead of prose for branching.
- Explicit pass criteria, and a Reporting section requiring exactly one of
  `Verified: <what ran, what it showed>` / `Unverified: ... because <reason>`
  for any skill that verifies work.
- Keep SKILL.md under ~150 lines; overflow goes to `resources/*.md` linked
  by relative path (progressive disclosure — see `frontend-dev/resources/`).
- No time-sensitive facts (model names, versions, URLs that rot) unless
  pinning them is the skill's purpose. Date-stamp any that must stay.

## Trigger rules (hook-side suggestion)

Model-side activation reads the description; the UserPromptSubmit hook
additionally *suggests* skills from `.claude/skills/skill-rules.json`.
Add an entry per skill:

```json
"my-skill": {
  "type": "domain",
  "enforcement": "suggest",
  "priority": "high",
  "description": "One line shown in the suggestion banner.",
  "promptTriggers": {
    "keywords": ["new skill", "port a skill"],
    "intentPatterns": ["(add|create|write).*?(skill)"]
  },
  "fileTriggers": { "pathPatterns": [".claude/skills/**/*"], "contentPatterns": [] }
}
```

`type` is `meta` for kit/process skills, `domain` for tech-stack skills.
`priority` (high/medium/low) only orders the suggestion banner. Keywords are
case-insensitive substring matches against the whole prompt — prefer 2+ word
phrases ("new skill", not "skill") or the entry fires on everything.
`intentPatterns` are JavaScript regexes tested with the `i` flag.

## Registration checklist — all move together

1. `.claude/skills/<name>/SKILL.md`
2. `.codex/skills/<name>/SKILL.md` — mirror (next section)
3. `.claude/skills/skill-rules.json` entry
4. One-line entry in the Skills list of all four instruction files:
   `CLAUDE.md`, `AGENTS.md`, `.claude/CLAUDE.template.md`,
   `.codex/AGENTS.template.md`
5. `README.md` skills table row
6. `usage-guide` "Which skill, when" table — BOTH copies

## Mirroring to Codex

Default is a verbatim copy — `diff` between the two skill dirs is empty for
most skills. Diverge only for:

- Claude-Code-only primitives (`/goal`, `/loop`, `/schedule`, subagents,
  slash commands) → substitute the Codex equivalent (goals feature,
  scheduled `codex exec`). `agentic-loops` shows the full adaptation.
- Literal `.claude/...` paths in body text → `.codex/...` where the Codex
  copy should point at its own tree (`usage-guide` shows the pattern).

## Verify before done

1. `python3 -c "import json; json.load(open('.claude/skills/skill-rules.json'))"`
2. Exercise the trigger with the real hook (stdin redirected from a file —
   see the sandbox note in `kit-release-checklist`):
   ```bash
   printf '{"prompt":"<a prompt that should fire it>"}' > /tmp/p.json
   npx tsx .claude/hooks/user-prompt-submit.ts < /tmp/p.json
   ```
   Pass: the banner names your skill.
3. `diff -r .claude/skills/<name> .codex/skills/<name>` — empty, or only the
   intended runtime adaptations.
4. Registration sweep — every file hits:
   ```bash
   grep -l "<name>" CLAUDE.md AGENTS.md README.md \
     .claude/CLAUDE.template.md .codex/AGENTS.template.md \
     .claude/skills/skill-rules.json .claude/skills/usage-guide/SKILL.md
   ```

Report `Verified:` with what fired, or `Unverified:` with the reason.
