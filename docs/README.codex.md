# obsidian-operator on Codex CLI

How obsidian-operator's 19 skills work on OpenAI Codex CLI. For install, see [`.codex/INSTALL.md`](../.codex/INSTALL.md).

## How discovery works

Codex CLI scans `~/.agents/skills/` at startup and parses each SKILL.md frontmatter. Routing is by the `description` field — natural-language requests + slash command patterns both work:

- `/daily-init 6` → matches `daily-init` description's slash trigger
- "start my day" → matches `daily-init` description's natural-language phrase
- "scan arxiv today" → matches `daily-academic` description's natural-language phrase

Slash commands are not enforced — they're just one of several trigger patterns each skill description lists.

## Per-skill status on Codex CLI

| Skill | Status | Notes |
|---|---|---|
| `vault-init` | ✅ full | Resolves assets via `~/.codex/obsidian-operator/...` cascade |
| `daily-init` | ✅ full | Hook + Gmail MCP both required for full functionality (graceful degradation if missing) |
| `weekly-init`, `weekly-review` | ✅ full | No platform-specific deps |
| `daily-github`, `daily-academic`, `ai-weekly-digest` | ✅ full | `WebSearch` / `WebFetch` are native on Codex |
| `quarterly-plan`, `annual-vision` | ✅ full | osascript runs on macOS regardless of platform |
| `meeting`, `meeting-prep` | ✅ full | Bash transcription script, osascript |
| `project-init`, `project-sync`, `deadline-plan` | ✅ full | No platform-specific deps |
| `add-events` | ✅ full | osascript |
| `deep-research` | ⚠️ requires `multi_agent` feature flag | Falls back to sequential if not enabled |
| `content-extract` | ⚠️ requires Gmail MCP for newsletter step | Skips silently if missing, continues with vault sources |
| `content-draft`, `link-enrich` | ✅ full | No platform-specific deps |
| `using-obsidian-operator` | ✅ full | Reference container only |

## Cross-platform tool mapping

Skills are written in Claude Code vocabulary. Codex CLI's agent maps automatically for most cases (file ops, shell, web search). For dispatch primitives (`deep-research`'s parallel agents) and Gmail MCP (different server names), see:

- `skills/using-obsidian-operator/references/codex-tools.md`
- `skills/using-obsidian-operator/references/codex-mcp.md`

## Why Codex App is not supported

Codex App runs agents in `$CODEX_HOME/worktrees/...` with a Seatbelt sandbox: no `git checkout -b`, no `git push`, no network on macOS, no user-configurable hooks. obsidian-operator's daily-vault-edit use case requires:

- A persistent vault (not a per-task worktree)
- Network for Gmail OAuth + arXiv / GitHub fetches
- The `UserPromptSubmit` hook for boundary-cascade enforcement

None of these survive in the App's sandbox. If you absolutely need vault automation in App, run only read-only skills (`/link-enrich scan`, `/weekly-review`) from a vault repo — but this is not a supported configuration.

## Maintaining vault `CLAUDE.md` and `AGENTS.md`

`vault-init` Step 4 copies both files into your vault root. They start with identical content. **If you customize `CLAUDE.md`** (e.g. updating the Customization table), copy the same edit into `AGENTS.md` to keep them in sync. Drift between the two means Claude Code and Codex CLI agents will see different vault config.

A future `vault-init --check` mode could detect drift; not implemented yet.

## Troubleshooting

### Skills not appearing

```bash
ls -la ~/.agents/skills/obsidian-operator       # symlink resolves to your clone?
ls ~/.codex/obsidian-operator/skills/ | wc -l   # 20?
```

Restart Codex if the symlink is correct but skills don't activate.

### Hook not firing on `/daily-init`

```bash
echo '{"hook_event_name":"UserPromptSubmit","prompt":"/daily-init"}' \
  | bash ~/.codex/obsidian-operator/hooks/preflight-enforce.sh
```

Should output JSON containing `hookSpecificOutput.additionalContext` if any boundary artifact is missing in your vault.

### `/deep-research` running sequentially

Verify `~/.codex/config.toml` contains:
```toml
[features]
multi_agent = true
```
Restart Codex after editing.
