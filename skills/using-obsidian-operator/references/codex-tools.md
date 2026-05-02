# Claude Code ↔ Codex CLI Tool Mapping

Obsidian-operator skills are written in Claude Code vocabulary. Codex CLI users: substitute the Codex equivalent below. Most skills do not reference these tools by name and need no substitution.

## Tool name map

| Skill references | Claude Code | Codex CLI equivalent |
|---|---|---|
| File read | `Read` tool | Native file read |
| File write | `Write` tool | Native file write / `apply_patch` |
| File edit | `Edit` tool | `apply_patch` |
| Shell | `Bash` tool | Native shell |
| Web search | `WebSearch` | `WebSearch` (same name, native) |
| Web fetch | `WebFetch` | `WebFetch` (same name, native) |
| Subagent dispatch | `Agent` tool, multiple calls in one message | `spawn_agent(agent_type="worker", message=...)`, multiple calls in one message + `wait` to collect + `close_agent` per agent |
| Plan / todos | `TodoWrite` | `update_plan` |

Where a skill body says "use the Edit tool" or similar, treat it as a hint — your platform's equivalent operation is what to use.

## Multi-agent feature gate (`deep-research`)

`spawn_agent` is gated by a Codex feature flag. Add to `~/.codex/config.toml`:

```toml
[features]
multi_agent = true
```

Then restart Codex. If `multi_agent` is not enabled, `deep-research` falls back to **sequential** thread execution (slower but functional) — the skill detects this and emits a one-line user-facing note.

## Subagent dispatch — message framing

`spawn_agent`'s `message` parameter is user-level input. Frame agent prompts with task-delegation language:

```
Your task is to perform the following. Follow the instructions below exactly.

<agent-instructions>
[research thread question + search strategy hints, per skill body]
</agent-instructions>

Execute this now. Output ONLY the structured response specified above.
```

This compensates for `spawn_agent` not exposing a system-prompt slot — the XML wrapping gives the wrapped block authoritative weight.
