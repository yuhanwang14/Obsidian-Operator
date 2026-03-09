---
name: project-init
description: Initialize a new project with standard folder structure and project note.
version: 1.0.0
author: Yuhan Wang
license: MIT
tags: [obsidian, project, scaffolding, initialization]
---

Initialize a new project with standard folder structure and project note.

## Arguments

This command accepts one or two arguments:
1. **Project name** (required) — e.g. `FM-Copilot`, `ASR-Pipeline`
2. **Category** (optional) — e.g. `side-project`, `startup`, `academic`. Defaults to `project`.

Example: `/project-init FM-Copilot side-project`

If no argument is provided, ask the user for the project name and a one-line description.

## Step 1 — Validate

1. Check that `02_Projects/$name/` does NOT already exist. If it does, stop and tell the user: "Project folder already exists at `02_Projects/$name/`. Use `/project-sync $name` to update it."
2. Confirm the project name with the user if it contains spaces or special characters — suggest a hyphenated version.

## Step 2 — Gather context

Ask the user (in one prompt, not multiple):
1. **One-line description** — what is this project in one sentence?
2. **Now** — what's the immediate focus or next step?
3. **Risks** — any known risks or blockers? (optional, can be added later)

## Step 3 — Create folder structure

Create the following directories and files:

### Directories
- `02_Projects/$name/`
- `04_Knowledge/$name/`

Subfolders (`Meeting Transcripts/`, `Meeting Plan/`, `Meeting Knowledge/`, `Decision Challenges/`) are created on-demand by their respective commands (`/meeting`, `/meeting-prep`, `/decision`).

### Project note: `02_Projects/$name/$name.md`

```markdown
---
type: project
status: active
date: $TODAY
project: $name
category: $category
---

# $name

$one_line_description

## Now

$now_text

## Risks

$risks_text

---

## Knowledge Base

## Weekly Progress
```

Use today's date for `date:`. If the user provided no risks, write a single placeholder bullet: `- (none identified yet)`.

## Step 4 — Open the file

Run `obsidian open path="02_Projects/$name/$name.md"` to open the new project note in Obsidian.

## Step 5 — Confirm

Tell the user what was created:
- Project note location
- Knowledge folder location
- Remind them they can use `/project-sync $name` to aggregate knowledge later
- Remind them to add `$name` to their quarterly plan if it's strategic

## Idempotency

This command refuses to run if the project folder already exists. It is a one-time scaffolding command. Use `/project-sync` for ongoing updates.

## Language

Match the user's language for the confirmation message. Project note content should be in English unless the user explicitly writes in another language.
