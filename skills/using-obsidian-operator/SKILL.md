---
name: using-obsidian-operator
description: "Reference skill providing Claude Code ↔ Codex CLI tool mapping for obsidian-operator skills that dispatch parallel agents (deep-research) or use platform-specific MCPs (daily-init, content-extract for Gmail). Other skills point here for cross-platform syntax."
---

This skill is a **reference container**, not an entry point. It does not route or enforce other skills — each obsidian-operator skill is self-triggered by its own description.

Skills that need cross-platform syntax point here:

- **`deep-research`** — multi-agent dispatch (Claude Code: `Agent` tool; Codex CLI: `spawn_agent` + `wait` + `close_agent`, gated by `[features] multi_agent = true`). See [`references/codex-tools.md`](references/codex-tools.md).
- **`daily-init`**, **`content-extract`** — Gmail MCP tool names differ across platforms. See [`references/codex-mcp.md`](references/codex-mcp.md).

For platform install + setup, see `.codex/INSTALL.md` (Codex CLI) or `README.md` Quick Start (Claude Code).
