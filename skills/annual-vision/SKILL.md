---
name: annual-vision
description: "Use when the user wants to set their annual vision, define yearly goals, or conduct a year-end retrospective. Triggers for: creating or updating a yearly vision document (north star, annual goals, key bets, themes, quarterly targets), reviewing how a full year went against the original vision, setting strategic direction for an upcoming year, or defining what success looks like for a specific year. Also triggers for the /annual-vision command. Does NOT apply to quarterly reviews, monthly pulses, weekly planning, project-specific context lookups, or multi-year career/strategic plans."
version: 1.0.0
author: Yuhan Wang
license: MIT
tags: [obsidian, strategy, annual, vision, retrospective]
---

Annual vision setting and year-end retrospective.

## Arguments

- `[year]` — target year. Default: current year.
- `review` — run in retrospective mode instead of vision-setting.

Auto-detect: if `00_Strategy/YYYY Vision.md` exists and it's December → review mode. Otherwise → vision mode.

## Vision Mode (Year-Start)

### Step 1: Read sources
- Existing `00_Strategy/YYYY Vision.md` (if exists — this becomes the baseline for updating rather than starting from scratch)
- Last year's Annual Review (if exists)
- Last year's Q4 Quarterly Review (if exists)
- All active project notes in `02_Projects/`
- Any existing quarterly plans for this year

### Step 2: Guide strategic session
If an existing Vision file was read in Step 1, present the current goals, bets, and themes to the user for review. Ask which items to keep, update, or remove before asking for new additions. Otherwise, ask the user one question at a time:
1. "What does success look like at the end of this year?" → North Star
2. "What are the 3-5 most important goals?" → Annual Goals
3. "What are you betting on — big assumptions or strategic choices?" → Key Bets
4. "What recurring themes should guide weekly decisions?" → Themes
5. For each quarter: "What should this quarter achieve toward the annual goals?" → Quarterly Targets

### Step 3: Write or update Vision
Write (or update) `00_Strategy/YYYY Vision.md` using the template. If updating an existing file, preserve structure and merge changes from the discussion.

### Step 4: Open the file
Run `obsidian open path="00_Strategy/YYYY Vision.md"` to open the file in Obsidian.

## Review Mode (Year-End)

### Step 1: Read sources
- `00_Strategy/YYYY Vision.md` — what was envisioned
- Existing `00_Strategy/YYYY Annual Review.md` (if exists — use as starting point to enrich rather than replace)
- All 4 Quarterly Reviews from the year
- All active project notes in `02_Projects/`
- Key knowledge notes from the year

### Step 2: Synthesize
- Goals achieved vs planned
- Quarter-by-quarter narrative arc
- Biggest wins and lessons
- What to do differently
- Trajectory into next year

### Step 3: Write or update Annual Review
Write (or update) `00_Strategy/YYYY Annual Review.md` using the template. If updating an existing file, preserve existing assessments and enrich with new analysis.

### Step 4: Open the file
Run `obsidian open path="00_Strategy/YYYY Annual Review.md"` to open the file in Obsidian.
