# Obsidian-Operator — Repo Guide for Agents

> **Note:** `AGENTS.md` at the repo root is a symlink to this file. Codex reads `AGENTS.md` natively; Claude Code reads `CLAUDE.md`. Both load the same content. The same symlink pattern exists in `skills/vault-init/assets/` for the user-runtime config.

You're editing the source of a personal Obsidian-Operator plugin: 19 production skills + 1 cross-platform reference skill that automate an Obsidian-based personal operating system. Single maintainer (`@yuhanwang14`); supports Claude Code (primary) and Codex CLI; MIT licensed.

This file is for agents working on **this repo** (the plugin code). The `CLAUDE.md` inside `skills/vault-init/assets/` is a *different* file — it ships into the user's Obsidian vault and configures the agent at vault-runtime. Don't confuse them.

## When in doubt

- Skill format → read [`docs/skill-style-guide.md`](docs/skill-style-guide.md)
- Repo conventions → this file
- Human-facing contribution rules → [`CONTRIBUTING.md`](CONTRIBUTING.md)

## Repo layout

```
.claude-plugin/         plugin manifest + marketplace metadata (versioned source of truth)
skills/<skill-name>/    one folder per skill, SKILL.md required (see style guide)
hooks/                  bash hooks invoked by Claude Code at session boundaries
docs/                   internal docs: style guide, plans
vault-template/         empty scaffold copied into a user's vault by /vault-init
.workspaces/            local scratch for skill development; gitignored
```

## Rules for editing skills

1. **Follow `docs/skill-style-guide.md`.** Frontmatter is `name` + `description` only. Description ≤300 chars, trigger-only — no workflow summaries.
2. **Bump the plugin version on every skill change.** Update all three:
   - `.claude-plugin/plugin.json` `version` field
   - `.claude-plugin/marketplace.json` `metadata.version` field
   - `README.md` if the skill is user-visible (e.g. listed in the skill table)
3. **Test against a real Obsidian vault before committing.** No automated suite. For procedural skills, run end-to-end. For routing-sensitive skills, type 2–3 vague natural-language triggers in a fresh session and confirm the right skill loads.
4. **Don't add net-new languages or runtimes** without a stated reason. The stack is markdown + bash + (optionally) python invoked via `markitdown` or one-off scripts. We deliberately do *not* maintain Cursor/OpenCode/Gemini variants, a CI test suite, or version-bump tooling.

## Rules for content & data

- **No personal vault content in the repo.** Anything personal (your daily notes, meetings, projects) lives outside the repo. Anything that ships to users goes in `vault-template/` as an empty scaffold or example placeholder.
- **No fabricated examples in skills.** If a skill needs an example output, generate it by running the skill against a clean vault — don't make up plausible-looking Markdown.
- **Workspaces are scratch only.** `.workspaces/<skill-name>/` is gitignored. Use it for skill development; don't reference its paths from skill code.

## Rules for git & releases

- **Default to creating new commits, not amending.**
- **Don't `--no-verify` or skip hooks.** If a hook fails, fix the underlying issue.
- **Don't push to `main` directly during multi-skill changes.** Stage on a branch, verify all 19 skills still load.
- After a release commit, sync `marketplace.json` to match `plugin.json` if you forgot — these have drifted before.

## Test recipe

```bash
cd ~/path/to/test-vault         # a vault, NOT this repo
claude                          # fresh session
> /daily-init 6                 # smoke-test the most-used skill end-to-end
> draft a LinkedIn post about X # vague trigger — confirm content-draft loads
> scan arxiv                    # vague trigger — confirm daily-academic loads
```

## What not to do

- Don't write skills with `version`/`author`/`license`/`tags` frontmatter fields. Plugin-level metadata only.
- Don't extend skill descriptions with signal-phrase catalogs, subcommand syntax, or output-format lists. That content belongs in the body.
- Don't add hooks, slash commands, or skills that would only benefit the maintainer's specific projects. Keep skills generalizable to any Obsidian user with a similar workflow.
- Don't replicate `superpowers`' aggressive PR-rejection rhetoric. This is a personal repo; tone is factual and friendly.
