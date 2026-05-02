# Gmail MCP Alternatives for Codex CLI

The skills `daily-init` and `content-extract` invoke Gmail via MCP. Claude Code's default install includes claude.ai's `mcp__claude_ai_Gmail__*` tools. Codex CLI users: install one of the alternatives below and configure it in `~/.codex/config.toml`.

## Compatible Gmail MCP servers

| Server | Tool name prefix | Repo / docs |
|---|---|---|
| Google Workspace MCP | `mcp__google_workspace__gmail_*` | https://github.com/taylorwilsdon/google_workspace_mcp |
| Composio Gmail | `mcp__composio__gmail_*` | https://composio.dev/toolkits/gmail/framework/codex |
| Nylas CLI (16 tools, 6 providers) | `mcp__nylas__*` | https://cli.nylas.com/guides/give-ai-agent-email-address |

All three accept Gmail-style search queries (`newer_than:1d`, `from:substack.com`, etc.) — query syntax is portable across servers.

## Configuration example (Google Workspace MCP)

In `~/.codex/config.toml`:

```toml
[mcp_servers.google_workspace]
command = "uvx"
args = ["google-workspace-mcp"]
env_vars = { GOOGLE_OAUTH_CLIENT_ID = "...", GOOGLE_OAUTH_CLIENT_SECRET = "..." }
```

Restart Codex after editing.

## Skill behavior when Gmail MCP is missing

- **`daily-init` Step 4 (Data Sources / Gmail)**: skip the email step, log `⚠️ Gmail MCP not configured` in `### Flags`. Briefing still produces.
- **`content-extract` Step 2.6 (Newsletter emails)**: skip silently, continue with vault-only sources (daily note, knowledge, thinking, AI-weekly, GitHub trending).

No errors are raised — the skill degrades gracefully.

## Search query portability

Gmail's search query language (`from:`, `newer_than:`, `before:`, `is:unread`) is a Google standard. All three alternatives accept the same syntax. Skills' query strings transfer 1:1.
