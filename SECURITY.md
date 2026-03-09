# Security Policy

## Reporting a Vulnerability

**Do NOT open a public issue for security vulnerabilities.**

Email **14w.1011@gmail.com** with:

- Description of the vulnerability
- Steps to reproduce
- Impact assessment (what data or systems are at risk)

### What to Expect

- Acknowledgment within 48 hours
- Fix developed privately before public disclosure
- Credit in the security advisory (unless you prefer anonymity)

## Security Considerations

Operator skills run inside Claude Code and interact with your local filesystem. Key concerns:

### Credentials & Secrets

- Never commit API keys, tokens, or passwords to the vault or skill files
- The `CLAUDE.md` customization table references external config files (e.g. `~/.secrets`) — these should never be checked into version control
- The transcription script (`gemini-transcribe.sh`) loads credentials from environment variables, not hardcoded values

### Vault Data

- Your Obsidian vault contains personal notes, meeting transcripts, and project data
- Skills read and write to local files only — no data is sent to external services unless you explicitly configure integrations (Gmail MCP, calendar)
- The `vault-template/` contains only empty scaffold directories, no personal data

### Skill Permissions

- Skills execute as Claude Code prompts with full filesystem access within the vault
- Review any third-party or modified skills before installing them
- The `organize` skill is read-only by design (recommendations only, no modifications)

## Supported Versions

| Version | Supported |
|---------|-----------|
| 1.x     | Yes       |
| < 1.0   | No        |
