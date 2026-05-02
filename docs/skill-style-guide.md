# Skill Style Guide

The format conventions for every `skills/*/SKILL.md` in this plugin. Read before adding a new skill or editing an existing one.

## Why this guide exists

Skills are loaded into Claude's plugin listing on every session — every byte of a skill description costs tokens for *every* future conversation that uses this plugin. Sloppy descriptions also damage routing: when a description summarizes a skill's workflow, Claude may follow the description as a shortcut and skip the skill body entirely (this is a documented anti-pattern, see [`superpowers/writing-skills`](https://github.com/obra/superpowers/blob/main/skills/writing-skills/SKILL.md)).

We adopt the lean format below selectively from `superpowers`. Where our needs differ — these are domain-automation skills, not behavior-shaping skills — we deviate deliberately, and the divergence section at the bottom explains where.

## Frontmatter rules

Only two fields. That's it.

```yaml
---
name: skill-name
description: Use when ...
---
```

**Forbidden in frontmatter:**

- `version:` — duplicates `.claude-plugin/plugin.json`. The plugin version is canonical.
- `author:` / `license:` — duplicates `.claude-plugin/plugin.json`.
- `tags:` — does not affect skill loading; clutter.

**Naming:** lowercase, hyphens, no underscores or special characters. Match the directory name.

## Description rules

- **≤300 characters.** No exceptions. Hit `wc -c` on the value before saving.
- **Trigger-only.** Describe *when* this skill should fire, not *what* it does step-by-step.
- **Start with `Use when` or `TRIGGER`** so Claude can scan it quickly.
- **Mention key signal phrases** if the skill has natural-language triggers, but ≤4 of them.
- **One `NOT for X`** clause is fine if the skill is easily confused with a sibling. Don't list more than two exclusions.
- **Forbidden:**
  - Workflow summaries ("First does X, then Y, then Z…")
  - Subcommand syntax (`subcommand <slug> generates v2.md…`) — body content
  - Output-format catalogs ("Supports LinkedIn, Twitter, blog, newsletter…") — body content
  - Long exclusion lists ("NOT for A, NOT for B, NOT for C…")

### Before / after examples

❌ **Before** (`content-draft`, 1173 chars):

```yaml
description: "Generate platform-specific content drafts from vault notes, backlog items, or free topics; iterate on existing drafts; or archive stale ones. TRIGGER when the user wants to draft a LinkedIn post, write a tweet thread, create a blog article, write a newsletter, turn a note into publishable content, revise an existing draft, or archive a draft. Signal phrases: 'draft a post about', 'turn this into a LinkedIn post', 'write a thread about', 'create content from', 'draft from this note', 'write up this idea', 'revise this draft', 'iterate on linkedin draft', 'make a v2 of', 'archive this draft', 'move to archived'. Also triggers for /content-draft. Subcommands: 'revise <slug>' generates the next version of an existing draft (writes linkedin-v2.md, linkedin-v3.md, etc.); 'archive <slug>' moves a stale draft to 05_Content/Archived/ and marks the backlog item [-]. Supports multiple output formats: LinkedIn (delegates to linkedin-content skill), Twitter/X threads, non-technical articles, technical blogs (delegates to technical-blog-writing skill), and newsletters. NOT for extracting content ideas (use /content-extract), not for meeting processing (use /meeting)."
```

✅ **After** (~210 chars):

```yaml
description: "TRIGGER for /content-draft, or when the user wants to draft a LinkedIn post, tweet thread, blog article, or newsletter; iterate an existing draft; or archive a stale one. NOT for extracting content ideas (use /content-extract)."
```

The subcommand syntax, signal-phrase exhaustive list, output-format catalog, and the second exclusion all moved into the skill body's `## When to use` section.

## Body structure

Two valid shapes — pick by skill type.

### Procedural (deterministic flows)

For skills like `daily-init`, `vault-init`, `weekly-init` where the steps must run in fixed order:

```markdown
[1-2 line lead — what the skill produces]

## Inputs / Arguments

[args, flags, modes]

## Step 1 — [name]
...
## Step 2 — [name]
...
```

Sequential numbering is fine and expected here. The skill *is* the procedure.

### Reference (judgment-heavy skills)

For skills like `content-draft`, `link-enrich`, `meeting-prep` where Claude is making nuanced choices:

```markdown
[1-2 line lead]

## When to use
- [trigger 1]
- [trigger 2]

## When NOT to use
- [exclusion 1] — use [other skill] instead

## Quick reference
| Mode | Behavior |
|------|----------|
| ...  | ...      |

## Implementation
[details, organized by mode/decision rather than step-by-step]
```

### Length targets

- **Body length:** ≤250 lines for most skills. If a skill exceeds 250 lines, split heavy reference into a sibling file (`references/foo.md`) and link to it.
- **Description:** ≤300 chars (mandatory).

## Sub-files

Inside `skills/<skill-name>/`:

| Path | Purpose |
|------|---------|
| `SKILL.md` | required. The skill definition. |
| `assets/` | template files copied into the user's vault (e.g. `vault-init/assets/vault-template/`). |
| `scripts/` | bash/python helpers invoked from inside the skill (e.g. `meeting/scripts/transcribe.sh`). |
| `references/` | heavy reference docs offloaded from SKILL.md. |
| `evals/` | smoke-test fixtures and prompts. Gitignored. |

## Testing

There is no formal pressure-test framework. Before merging a skill change:

1. Run the skill against the maintainer's live Obsidian vault end-to-end.
2. For procedural skills, verify each step produces the expected file/output.
3. For reference skills, type 2–3 vague natural-language triggers in a fresh session and confirm Claude routes to the skill (not to a sibling).

If the skill is part of a chain (e.g. `daily-init` auto-triggers `content-extract`), verify the chain runs without manual intervention.

## What we deliberately diverge from `superpowers` / Anthropic

- **No frontmatter `version`.** Plugin-level versioning only.
- **Procedural step-by-step bodies are fine.** Superpowers warns against this for behavior-shaping skills (TDD, debugging) because it produces brittle compliance. Our skills are domain automation — the steps *are* the skill — so step-by-step is the right shape.
- **No TDD-for-skills with subagent pressure tests.** Appropriate for general-purpose discipline skills; overkill for personal Obsidian automation. Live-vault dry-runs are sufficient.
- **Claude Code primary, Codex CLI supported.** Skills should reference platform-neutral concepts ("file edit operation" not "Edit tool"). Where a skill genuinely needs platform-specific syntax (e.g. `deep-research` dispatching parallel agents), document both Claude Code and Codex CLI variants inline, and offload deeper mappings to `skills/using-obsidian-operator/references/codex-tools.md`. Codex App, Cursor, Gemini, OpenCode are not supported.
- **No flowcharts unless decisions are non-obvious.** Tables and bullet lists win for reference content.

## Pre-merge checklist

When adding or editing a skill:

- [ ] Frontmatter has only `name` + `description`
- [ ] Description ≤300 chars, trigger-only
- [ ] Body ≤250 lines (or excess offloaded to `references/`)
- [ ] Smoke-tested end-to-end against the live vault
- [ ] `.claude-plugin/plugin.json` version bumped
- [ ] `.claude-plugin/marketplace.json` version mirrors `plugin.json`
- [ ] `README.md` updated if the skill is user-visible

This checklist also lives in `CLAUDE.md` for agents.
