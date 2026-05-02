# Operator

An AI-native personal operating system built on Obsidian + Claude Code.

Operator is an opinionated system of 19 Claude Code skills that turn an Obsidian vault into a structured execution engine — daily briefings, arXiv paper scanning, weekly reviews, strategic planning, meeting processing, deadline tracking, deep research, and a content engine for publishing, all orchestrated by AI agents.

## Quick Start

### 1. Install the plugin

**Claude Code** (recommended — includes auto-updates):

```bash
# Add the marketplace and install (auto-updates enabled)
/plugin marketplace add https://github.com/yuhanwang14/obsidian-operator
/plugin install obsidian-operator
```

**Codex CLI**: clone + symlink + register hook. See [`.codex/INSTALL.md`](.codex/INSTALL.md) for the 6-step install. After install, run `/vault-init` exactly as below.

### 2. Initialize the vault

Open your (empty or existing) Obsidian vault directory and run:

```bash
cd /path/to/your/vault
claude       # or: codex

/vault-init
```

`/vault-init` creates the six core folders, installs `CLAUDE.md`, walks you through the Customization table (vault owner, calendar names, meeting paths), and optionally sets up `~/.secrets` + the transcription script for `/meeting`. It's idempotent — safe to rerun.

### 3. Start using

```bash
# Your first day:
/project-init MyProject
/daily-init 6
```

<details>
<summary>Manual setup (without the plugin)</summary>

```bash
git clone https://github.com/yuhanwang14/obsidian-operator.git
cp -r obsidian-operator/skills/vault-init/assets/vault-template/* /path/to/your/vault/
cp    obsidian-operator/skills/vault-init/assets/CLAUDE.md         /path/to/your/vault/
# then edit the Customization table in CLAUDE.md by hand
```

</details>

## Prerequisites

| Requirement | Required | Notes |
|-------------|----------|-------|
| [Obsidian](https://obsidian.md) | Yes | The vault app |
| [Claude Code](https://claude.ai/code) **or** [Codex CLI](https://developers.openai.com/codex/cli) | Yes | One required. See [Codex install](.codex/INSTALL.md) and [docs/README.codex.md](docs/README.codex.md) for Codex CLI specifics. |
| [Day Planner](https://github.com/ivan-lednev/obsidian-day-planner) plugin | Recommended | Time-blocking in daily notes |
| [Obsidian CLI](https://github.com/Obsidian-TTRPG-Community/obsidian-cli) | Recommended | Skills fall back to file tools if unavailable |
| [ffmpeg](https://ffmpeg.org/) | Optional | For `/meeting` auto-transcription (`brew install ffmpeg`) |
| Gmail MCP | Optional | For email integration in `/daily-init` |
| [Templater](https://github.com/SilentVoid13/Templater) plugin | Optional | For daily note templates |

## Configuration

`/vault-init` handles the common settings interactively: the **Customization** table in [CLAUDE.md](skills/vault-init/assets/CLAUDE.md) (vault owner, calendar names, meeting paths) and, optionally, `~/.secrets` + the `/meeting` transcription script. Rerun it any time to update values.

Two integrations live outside Claude Code and need a one-time setup of their own:

### Gmail MCP (optional — for `/daily-init`)

**Claude Code:** Connect your Google account under **Claude Code settings → MCP integrations** and grant Gmail read access.

**Codex CLI:** Configure a Gmail MCP server in `~/.codex/config.toml`. Three compatible options (Google Workspace MCP, Composio Gmail, Nylas) — see [`docs/README.codex.md`](docs/README.codex.md) for setup snippets and tool-name differences.

If not configured (either platform), `/daily-init` silently skips the email section and `/content-extract` skips the newsletter step.

### Apple Calendar & Reminders (macOS only — for `/deadline-plan`, `/quarterly-plan`, `/add-events`)

No OS setup needed beyond macOS. Configure the calendar and list names via `/vault-init`, or edit them directly in the Customization table of [CLAUDE.md](skills/vault-init/assets/CLAUDE.md).

## Vault Structure

```
00_Strategy/            — annual vision, quarterly plans, monthly pulses
01_Execution/           — daily notes, weekly todos, blockers, reviews
02_Projects/            — per-project folders with meeting plans, transcripts, deadlines
03_Thinking/            — reflections, ideas, mental models
04_Knowledge/           — research, meeting knowledge, deep research, digests
05_Content/             — content backlog, drafts, published, archived, voice guide
```

See [CLAUDE.md](skills/vault-init/assets/CLAUDE.md) for full conventions, frontmatter spec, checkbox states, and AI agent instructions.

## Skills Reference

### Setup

| Skill | Description |
|-------|-------------|
| `vault-init` | One-shot vault bootstrap — creates the 6-folder structure, copies `CLAUDE.md`, walks through the Customization table, optionally installs `~/.secrets` + the `/meeting` transcription script. Idempotent. Run this first. |

### Daily Operations

| Skill | Description |
|-------|-------------|
| `daily-init` | Generate today's briefing — syncs completions, gathers email/calendar/vault data, produces action items + time-blocked schedule |
| `daily-github` | Fetch trending GitHub repos, write full report to knowledge folder, append summary to daily note |
| `daily-academic` | Scan today's arXiv papers across AI/robotics categories — quality-gated to 3–5 papers/day from established labs/universities or top-venue acceptances, with a PDF deep-read per paper before writing the report |

### Weekly Operations

| Skill | Description |
|-------|-------------|
| `weekly-init` | Create or update week folder + Weekly Todo — carries items from last week, injects deadline tasks, populates Blockers from calendar. Merges into existing files without overwriting. |
| `weekly-review` | AI synthesis of the week — progress, stalled items, patterns, intention tracking, horizon items, next-week focus |
| `ai-weekly-digest` | Curated AI landscape digest — research trends (aggregated from `/daily-academic` reports), big tech, startups, open-source, landscape. Merges new findings into existing digests. |

### Strategic Planning

| Skill | Description |
|-------|-------------|
| `quarterly-plan` | Three modes: `init` (set quarterly goals), `review` (end-of-quarter synthesis), `pulse` (monthly checkpoint). Init and review update existing files rather than aborting. |
| `annual-vision` | Annual vision setting or year-end retrospective — reads existing files as baseline for updates |

### Knowledge & Synthesis

| Skill | Description |
|-------|-------------|
| `meeting` | Process meeting transcripts (auto-transcribe, chunked, or direct) — produces transcript + knowledge note, routes actions |
| `meeting-prep` | Generate meeting agenda from project context — reads project note, blockers, weekly progress, deadlines |
| `project-init` | Scaffold a new project — creates folder structure + project note with frontmatter |
| `project-sync` | Aggregate knowledge notes + weekly reviews into the project note — Knowledge Base, Weekly Progress, Strategic Signals |
| `deadline-plan` | Backward-schedule deadlines with ramp algorithm — task queues, automatic progress tracking, weekly allocation |
| `add-events` | Batch-add events to Apple Calendar + Reminders — stores in `Upcoming Events.md` for pipeline integration, routes current-week events to Blockers |
| `deep-research` | Multi-agent deep research — decomposes a question into parallel threads, researches each with Opus agents, synthesizes into a detailed knowledge note |

### Content Engine

| Skill | Description |
|-------|-------------|
| `content-extract` | Scan yesterday's notes and Substack newsletter emails for publishable insights — appends 0-3 ideas to `05_Content/Backlog.md` with pillar tags. Integrated into `/daily-init` post-briefing. Also includes catch-up pass for unscanned this-week notes. |
| `content-draft` | Generate platform-specific drafts from backlog items or notes — presents backlog sorted by priority (P1 own thinking > P2 summaries > P3 external). Formats: LinkedIn (delegates to `linkedin-content`), Twitter/X threads, non-technical articles (uses Voice Guide), technical blogs (delegates to `technical-blog-writing`), newsletters |

### Vault Maintenance

| Skill | Description |
|-------|-------------|
| `link-enrich` | Three modes: `scan` (audit unlinked mentions, orphans, graph density), `apply` (preview + insert wiki-links), `moc` (generate Map of Content index notes) |

## System Architecture

### How skills work together

```
                        ┌─────────────────────────────────────────────┐
                        │      NEW-WEEK BOUNDARY /daily-init          │
                        │  (first /daily-init of a new ISO week)      │
                        │                                             │
                        │  1.  /weekly-review  (close last week)      │
                        │  1b. /ai-weekly-digest (AI landscape)       │
                        │  1c. /quarterly-plan pulse (new month)      │
                        │  1d. /quarterly-plan review (new quarter)   │
                        │  1e. /quarterly-plan init  (new quarter)    │
                        │  2.  /weekly-init    (open new week)        │
                        │  3.  briefing        (today's data)         │
                        │  4.  /daily-github   (trending repos)       │
                        │  4b. /daily-academic (arXiv papers)         │
                        │  5.  /content-extract (content ideas)       │
                        └─────────────────────────────────────────────┘

                        ┌─────────────────────────────────────────────┐
                        │      SAME-WEEK /daily-init                  │
                        │  (subsequent days within same ISO week)     │
                        │                                             │
                        │  0.  sync yesterday's [x] → Weekly Todo    │
                        │      ([-] = dropped, no sync)               │
                        │  0b. sync [x] → Deadline Plans (task queue) │
                        │  1.  (skip weekly transition)               │
                        │  1c. /quarterly-plan pulse (new month)      │
                        │  2.  /weekly-init (update mode)             │
                        │  3.  briefing        (today's data)         │
                        │  4.  /daily-github   (trending repos)       │
                        │  4b. /daily-academic (arXiv papers)         │
                        │  5.  /content-extract (content ideas)       │
                        └─────────────────────────────────────────────┘
```

### Data flow

```
Daily notes accumulate in 01_Execution/YYYY-WXX/
    ↓ [x] completions sync back to Weekly Todo + Blockers automatically
    ↓ [x] deadline tasks sync back to Deadline Plan task queue + hours
    ↓ [>] items carry forward to next day's briefing
    ↓ [>] with future date (e.g. -> 周五 (May 1), → 2026-05-01) → #### Deferred section
    ↓ [-] items are DROPPED — no sync, no carry-forward, inert
    ↓
/meeting routes actions after processing transcripts:
    → Vault owner's independent actions → Weekly Todo
    → Cofounder deliverables → Blockers.md ## Waiting On
    → Meeting-dependent work → Blockers.md ## Meetings
    ↓
/daily-init reads Blockers.md + Deadline Plans → surfaces in ### Flags:
    → Waiting-on items (always), today's meetings + agenda + /meeting reminder
    → Tomorrow's meetings: auto-runs /meeting-prep if no plan exists
    → Deadline warnings (🟡/🔴, within 14 days) + task queue health
    ↓
/weekly-review reads all daily notes + Weekly Todo + Blockers + projects
    → writes Weekly Review.md (AI synthesis + suggested next-week todos)
    → detects horizon items (monthly/quarterly deferrals & deadlines)
    ↓
/ai-weekly-digest reads arXiv daily files + GitHub trending files + RSS + web search
    → writes AI Weekly Digest (research trends + industry), appends summary to Weekly Review
    ↓
/weekly-init reads Weekly Review "Todos next week" + uncompleted Weekly Todo
    → carries them into new week's Weekly Todo
    → pulls top deadline tasks from task queues into Weekly Todo
    → carries undelivered Blockers ## Waiting On items
    → populates ## Meetings from Weekly Review + ICS calendar data
    ↓
Cycle repeats
    ↓
/quarterly-plan pulse (monthly) reads weekly reviews + horizon items + projects
    → writes Monthly Pulse, assesses quarterly goals (🟢🟡🔴)
    ↓
/quarterly-plan review (end of quarter) reads plan + pulses + weekly reviews
    → writes Quarterly Review, carries unresolved items forward
    ↓
/quarterly-plan init (start of quarter) reads vision + last review
    → guides goal-setting, writes Quarterly Plan
    ↓
/annual-vision reads quarterly reviews + projects
    → writes annual Vision or Annual Review
```

### Knowledge pipeline

```
/meeting-prep → 02_Projects/[P]/Meeting Plan/            (agenda)
/meeting      → 02_Projects/[P]/Meeting Transcripts/     (raw)
              → 04_Knowledge/[P]/Meeting Knowledge/       (synthesis)
              → Weekly Todo + Blockers.md                 (action routing)

/deep-research→ 04_Knowledge/[P or topic]/Research/         (deep research report)
/deadline-plan→ 02_Projects/[path]/Deadline Plan.md       (ramp schedule + task queue)
/add-events  → Apple Calendar "Operator"                    (timed + all-day events)
             → Apple Reminders "Operator"                    (associated deadlines)
             → 02_Projects/[P]/Upcoming Events.md           (staging for /weekly-init)
             → 01_Execution/YYYY-WXX/Blockers.md            (current-week only)
/daily-github    → 04_Knowledge/GitHub/                    (daily trending)
/daily-academic  → 04_Knowledge/Academic/                  (daily arXiv)
/ai-weekly-digest → 04_Knowledge/AI-Weekly/               (weekly AI landscape)
/quarterly-plan   → 00_Strategy/YYYY-QX/                  (plan | review | pulse)
/annual-vision    → 00_Strategy/                          (vision | annual review)

/project-init → 02_Projects/[P]/ + 04_Knowledge/[P]/     (scaffolding)
/project-sync → 02_Projects/[P]/[P].md                   (Knowledge Base + Strategic Signals)

/content-extract → 05_Content/Backlog.md                  (content ideas from vault notes + newsletters)
/content-draft   → 05_Content/Drafts/YYYY-MM-DD-slug/    (LinkedIn, Twitter, article, newsletter)
```

### Dependency graph

```
/daily-init ──► /weekly-review (new-week boundary)
            ──► /ai-weekly-digest (new-week boundary)
            ──► /quarterly-plan pulse (new-month boundary)
            ──► /quarterly-plan review (new-quarter boundary)
            ──► /quarterly-plan init (new-quarter boundary)
            ──► /weekly-init (always — update mode if exists)
            ──► /daily-github (post-briefing)
            ──► /daily-academic (post-briefing, after daily-github)
            ──► /content-extract (post-briefing, after daily-academic)
            ──► /meeting-prep (tomorrow's meetings)

/meeting ───► (self-contained: transcript + knowledge + action routing)

/add-events ► (consumed by /weekly-init Step 7d when week arrives)

/weekly-review  (standalone)
/project-sync   (standalone — pure synthesis)
/link-enrich    (standalone — vault graph optimizer)
/content-extract (standalone or via /daily-init post-briefing)
/content-draft  (standalone — reads backlog or notes, generates drafts)
```

## Customization

This is an opinionated system — the vault structure, note conventions, and skill behaviors are designed to work together. To customize:

1. **CLAUDE.md** is the configuration layer. Edit folder paths, frontmatter fields, checkbox states, or agent behavior in your vault's `CLAUDE.md`.
2. **Individual skills** — for durable changes, fork this repo and install from your fork. Editing files in `~/.claude/plugins/cache/obsidian-operator/…` (Claude Code) or `~/.codex/obsidian-operator/skills/…` (Codex CLI) works for quick experiments. Claude Code overwrites its cache on plugin update; Codex's clone is yours to maintain via `git pull`.
3. **Vault structure** can be extended — add new folders as needed. Avoid renaming the core 6 folders without updating CLAUDE.md and skill references.

## Contributing

We welcome contributions! See [CONTRIBUTING.md](CONTRIBUTING.md) for how to get started.

- [Skill style guide](docs/skill-style-guide.md) — frontmatter, description, and body conventions
- [Repo guide for agents](CLAUDE.md) — rules for agents working on this codebase
- [Code of Conduct](CODE_OF_CONDUCT.md)
- [Security Policy](SECURITY.md)

## License

[MIT](LICENSE)
