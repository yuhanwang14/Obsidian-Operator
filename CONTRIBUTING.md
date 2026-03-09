# Contributing to Operator

Thanks for your interest in improving Operator! This guide covers how to contribute skills, vault structure improvements, and documentation.

## How to Contribute

### Reporting Bugs

Open a [GitHub issue](https://github.com/yuhanwang14/Obsidian-Operator/issues) with:

- Which skill is affected (e.g. `daily-init`, `meeting`)
- Steps to reproduce
- Expected vs actual behavior
- Your environment (OS, Obsidian version, Claude Code version)

### Suggesting Features

Open an issue describing:

- The problem you're trying to solve
- How it fits within the existing skill/vault architecture
- Whether it's a new skill, an enhancement to an existing one, or a vault structure change

### Submitting Changes

1. Fork the repo and create a branch from `main`
2. Make your changes
3. Test your changes in a real Obsidian vault
4. Submit a pull request

## Development Setup

### Prerequisites

- [Obsidian](https://obsidian.md) installed
- [Claude Code](https://claude.ai/code) CLI installed
- A test vault (use `vault-template/` as a starting point)

### Local Setup

```bash
git clone https://github.com/YOUR_USERNAME/Obsidian-Operator.git
cd Obsidian-Operator

# Create a test vault from the template
cp -r vault-template/ /path/to/test-vault/
cp CLAUDE.md /path/to/test-vault/

# Install a skill locally for testing
# Skills live in ~/.claude/skills/ — symlink or copy your modified skill there
```

### Testing Skills

There's no automated test suite — skills are tested by running them in a real Obsidian vault with Claude Code:

```bash
cd /path/to/test-vault
claude
# Then invoke the skill you modified, e.g.:
/daily-init 6
```

Verify that:
- The skill runs without errors
- Output notes have correct frontmatter and structure
- Wiki-links resolve correctly in Obsidian
- No unintended side effects on other notes

## Project Structure

```
skills/           — Claude Code skill definitions (one folder per skill)
  <skill>/
    SKILL.md      — Skill definition (YAML frontmatter + markdown prompt)
    scripts/      — Helper scripts (if any)
vault-template/   — Scaffold for new Obsidian vaults
CLAUDE.md         — Vault configuration and AI agent instructions
```

## Writing Skills

Each skill is a `SKILL.md` file with YAML frontmatter:

```yaml
---
name: my-skill
version: 1.0.0
description: One-line description
author: Your Name
license: MIT
tags: [obsidian, operator]
user_invocable: true
---
```

The markdown body is the prompt Claude Code receives when the skill is invoked.

### Skill Guidelines

- **Follow existing conventions** — read 2-3 existing skills before writing a new one
- **Use the vault structure** defined in CLAUDE.md (00_Strategy through 05_Archive)
- **Use Obsidian wiki-links** (`[[Note Title]]`) for cross-references
- **Follow the checkbox states** convention: `[ ]` todo, `[x]` done, `[>]` carry forward, `[-]` cancelled
- **Reference CLAUDE.md settings** for paths and preferences rather than hardcoding values
- **Keep skills focused** — one skill, one job

## Pull Request Guidelines

- Keep PRs focused on a single change
- Describe what changed and why
- If modifying a skill, explain how you tested it
- If adding a new skill, include usage examples
- Update README.md if adding a new skill or changing the vault structure

## Scope

Operator is an opinionated system. We welcome contributions that:

- Fix bugs or improve reliability
- Improve documentation and examples
- Add skills that fit the existing architecture (daily ops, weekly ops, strategic planning, knowledge synthesis)
- Improve the vault template

We'll likely decline contributions that:

- Fundamentally change the vault structure or conventions
- Add dependencies on specific paid services (beyond Obsidian/Claude Code)
- Duplicate functionality of existing skills
- Are too niche for general use

When in doubt, open an issue to discuss before building.

## Code of Conduct

This project follows the [Contributor Covenant Code of Conduct](CODE_OF_CONDUCT.md). By participating, you agree to uphold it.
