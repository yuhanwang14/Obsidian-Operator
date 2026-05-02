---
name: quarterly-plan
description: "TRIGGER for /quarterly-plan (subcommands: init, review, pulse), or when the user wants to check quarterly goals, assess objective status, set up a new quarter, review a completed one, or run a monthly pulse checkpoint. NOT for annual vision, weekly planning, or meeting prep."
---

Strategic quarterly planning: init, review, and monthly pulse checkpoint.

## Arguments

- `pulse [MM]` — Run monthly pulse for month MM (default: last month). Auto-triggered by `/daily-init` on 1st of each month.
- `init [YYYY-QX]` — Initialize a new quarter's plan. Auto-triggered by `/daily-init` on first Monday of quarter.
- `review [YYYY-QX]` — Review a completed quarter. Auto-triggered by `/daily-init` on first Monday of new quarter.

If no argument given, auto-detect mode:
- If current quarter has no `Quarterly Plan.md` → init
- If last quarter has no `Quarterly Review.md` → review
- Otherwise → pulse for current month

## Pulse Mode (Monthly Checkpoint)

### Step 1: Determine context
Compute current quarter string `YYYY-QX`. Determine which month within the quarter (1st, 2nd, or 3rd). Default month = last month if not specified.

### Step 2: Read sources
- All Weekly Reviews from the target month in `01_Execution/YYYY-WXX/Weekly Review.md` — especially `### Horizon Items` (under `## AI Synthesis`) and `## Reflection` sections (surface reflection themes in qualitative assessment)
- Current `00_Strategy/YYYY-QX/Quarterly Plan.md` — the goals being tracked
- Active project notes in `02_Projects/` (status: active) — recent progress, `## Now`, `## Risks`, and `## Strategic Signals` sections
- Knowledge notes created during the target month in `04_Knowledge/` — meetings, decisions, research, brainstorms

### Step 3: Assess quarterly goals
For each objective/milestone in the Quarterly Plan, assess status:
- 🟢 on track — clear progress, no blockers
- 🟡 at risk — some progress but behind schedule or blocked
- 🔴 off track — no progress or major blockers

When assessing each goal, incorporate signals from project-level research (knowledge notes and `## Strategic Signals` from project notes). If recent research reinforces, challenges, or introduces new considerations for a goal, note it inline with the assessment — e.g. "🟡 at risk — competitive landscape shifted per [[Relevant Knowledge Note]]".

### Step 4: Collect horizon items
Aggregate all `### Horizon Items` from weekly reviews in the target month. Deduplicate by semantic meaning.

### Step 5: Identify maturing deadlines

**Auto-mode skip (CRITICAL):** When this skill is auto-triggered by `/daily-init` (Pre-Flight Step 1c), **skip this entire step** and proceed directly to Step 6. The Monthly Pulse file is the primary deliverable; calendar/reminder creation is opt-in interactive work that requires the user explicitly running `/quarterly-plan pulse` themselves. Surfacing interactive confirmations during auto-trigger causes the parent `/daily-init` to flag-and-skip the trigger entirely (observed regression 2026-05-01 + 2026-05-02 — April pulse missed for 2 consecutive days).

**Manual-mode only:** From collected horizon items and project notes, identify items that now have concrete dates. Classify each:
- **Has exact date + time** → offer to create Apple Reminder (via osascript, using the reminders list name from CLAUDE.md)
- **Has exact date only** → offer to create Apple Calendar all-day event (via osascript, using the calendar name from CLAUDE.md)
- **Still soft** → keep in vault planning layer

For each item to be created, present to user and confirm before running osascript:
```applescript
-- Apple Calendar all-day event (use calendar name from CLAUDE.md Customization)
tell application "Calendar"
    tell calendar "<calendar_name>"
        make new event with properties {summary:"DEADLINE: <item>", start date:date "<YYYY-MM-DD>", allday event:true}
    end tell
end tell

-- Apple Reminder with exact time (use reminders list from CLAUDE.md Customization)
tell application "Reminders"
    tell list "<reminders_list>"
        make new reminder with properties {name:"<item>", due date:date "<YYYY-MM-DD HH:MM:SS>"}
    end tell
end tell
```

### Step 6: Write Monthly Pulse
Write `00_Strategy/YYYY-QX/Monthly Pulse - MM.md` using the template structure. Populate all sections from the analysis above.

### Step 7: Update the Quarterly Plan with revisions detected this pulse (CRITICAL — living-doc fix introduced 2026-05-02 / v1.7.9)

The Quarterly Plan is a **living document**, not a frozen snapshot. After writing the Monthly Pulse, fold any divergence between plan-as-written and reality-as-observed back into the plan's `## Current State` section. Original intent stays preserved in `## Locked Original`.

**When to update:** if Steps 3–4 surfaced ANY of:
- A new objective / workstream that wasn't in the plan (additive)
- A KR rendered moot by reality (cancelled, dropped, reassigned)
- A KR target that was never achievable as written (downward-revised)
- A `[?]` KR that now has concrete shape (promote to `[ ]`)
- A milestone that's slipped or cancelled

**How to update:**
1. Read `00_Strategy/YYYY-QX/Quarterly Plan.md`.
2. Append a new dated entry to the `## Plan Revisions Log` section (most recent first), with this structure:
   ```markdown
   ### Rev N — YYYY-MM-DD (brief context, triggered by `/quarterly-plan pulse YYYY-MM`)

   **Added:**
   - [new objective or KR with one-line reason]

   **Dropped (with reason):**
   - [item → CANCELLED/DROPPED — reason]

   **Modified:**
   - [original → new — reason]

   **Deferred:**
   - [item → new target date — reason]

   **`[?]` → `[ ]` promotions** (if any):
   - [previously `[?]`] → [now `[ ]` with concrete shape — what info landed]

   **Calibration note** (optional): one-sentence learning for next quarter's planning.

   **Linked pulse:** [[Monthly Pulse - MM]]
   ```
3. Apply the same changes to the `## Current State` section in-place — update objectives, KRs, milestones to match reality.
4. **Never edit `## Locked Original`** — that section is frozen at quarter start for honesty + post-quarter calibration.
5. Bump the `last-revised` field in frontmatter to today's date.

**Auto-mode behavior (when triggered by /daily-init):** Write revisions directly without asking. The pulse itself documents what changed; user can git-revert if they disagree. Don't surface confirmation prompts (would cause the parent /daily-init to rationalize-skip the entire trigger).

**Manual-mode behavior:** Same — write directly. The non-destructive append + Current State edit is safe; user reviews after.

**No-revisions case:** If the pulse assessment found nothing to revise, skip Step 7 entirely. Add a one-line note to the Pulse: "Plan unchanged — no revisions this month."

**Editing convention:** Use the platform's file edit operation (read-then-edit, not full rewrite) — preserves the Locked Original section and any manual user edits to Current State that weren't captured in this pulse.

### Step 8: Open the pulse + the revised plan
Run `obsidian open path="00_Strategy/YYYY-QX/Monthly Pulse - MM.md"` to open the pulse. If Step 7 wrote revisions, ALSO `obsidian open path="00_Strategy/YYYY-QX/Quarterly Plan.md"` so the user sees what changed.

## Init Mode (Start of Quarter)

### Step 1: Determine quarter
Compute current quarter `YYYY-QX`. Create folder `00_Strategy/YYYY-QX/` if it doesn't exist.

### Step 2: Check for existing plan
If `00_Strategy/YYYY-QX/Quarterly Plan.md` already exists, switch to **update mode**: read the existing plan and use it as the starting point. Steps 3–4 still run to gather fresh context, but Step 5 merges new insights into the existing plan rather than writing from scratch. Preserve existing objectives and structure; add new items, update statuses, and incorporate any new context from sources. Inform the user: "Quarter already has a plan — updating with fresh context."

### Step 3: Read sources
- `00_Strategy/YYYY Vision.md` — annual goals and themes (if exists)
- Last quarter's `Quarterly Review.md` — suggested focus + lessons (if exists)
- Last quarter's monthly pulses — trajectory and open items
- Active project notes in `02_Projects/`

### Step 4: Guide goal-setting

**Auto-mode skip (CRITICAL):** When this skill is auto-triggered by `/daily-init` (Pre-Flight Step 1e), **skip the interactive presentation** and proceed directly to Step 5. Write the Quarterly Plan with **draft objectives sourced from**:
1. Carried horizon items from last quarter's monthly pulses
2. Last quarter's review's "Suggested next quarter focus" (if exists)
3. Annual Vision goals mapped to this quarter (read `00_Strategy/YYYY Vision.md` if exists)
4. Active project notes' `## Now` sections

The auto-generated plan must include a `## ⚠️ TODO: User Review` block at the top: "Objectives drafted in auto-mode by the new-quarter trigger. Review and adjust manually — re-run `/quarterly-plan init` interactively to lock final objectives." This makes the draft visible + invites the user to override. Surfacing interactive confirmations during auto-trigger causes the parent `/daily-init` to flag-and-skip the trigger entirely (regression analog to the April 2026 pulse miss).

**Manual-mode (interactive — when user invokes `/quarterly-plan init` directly):** Present to user:
- Annual goals relevant to this quarter (from Vision)
- Suggested focus from last quarter's review
- Carried horizon items that weren't resolved
- Ask user to confirm/adjust objectives before writing

### Step 5: Write Quarterly Plan

Write `00_Strategy/YYYY-QX/Quarterly Plan.md` using the new **living-document structure** (introduced 2026-05-02 / v1.7.9):

```markdown
# Quarterly Plan · YYYY-QX

## Vision Alignment
[from annual vision]

## Q(X-1) Inheritance — What Carries Forward
[from last quarter review]

---

## Locked Original (frozen at quarter start, never edited after init)

### Initial Objectives (set YYYY-MM-DD)
[the original objectives]

### Initial Key Milestones (set YYYY-MM-DD)
[milestone table]

### Initial Monthly Focus (set YYYY-MM-DD)
[monthly breakdown]

---

## Plan Revisions Log (append-only — most recent first)

> Empty at init. Pulse skill (Step 7) appends dated revision entries here when reality diverges from plan.

---

## Current State (live — reflects all revisions to date)

### Current Objectives
[copy of Initial Objectives at init time; pulse updates this in-place via revisions]

### Current Key Milestones
[copy of Initial Key Milestones; pulse updates]

### Current Monthly Focus
[copy of Initial Monthly Focus; pulse updates]

---

## Risks
[risk table — can be updated via revisions]

## Open Questions
[question list]

## Links
[wiki-links]
```

**KR markers convention:**
- `[ ]` — concrete, pending
- `[x]` — done
- `[?]` — pending discovery; not actionable until info lands. Use for genuinely-unknowable items (e.g. "4 Equity IT peer outreach plan" before knowing peers/cadence). Pulse Step 7 promotes `[?]` → `[ ]` when concrete info lands.

Populate Locked Original + Current State (initially identical) with objectives, KRs, milestones, and monthly focus from Step 4's discussion (manual mode) or auto-mode draft sources.

### Step 6: Open the file
Run `obsidian open path="00_Strategy/YYYY-QX/Quarterly Plan.md"` to open the file in Obsidian.

## Review Mode (End of Quarter)

### Step 1: Determine quarter
Default: last completed quarter. Compute `YYYY-QX`.

### Step 2: Check for existing review
If `00_Strategy/YYYY-QX/Quarterly Review.md` already exists, switch to **update mode**: read the existing review and use it as the starting point. Steps 3–4 still run to gather fresh data, and Step 5 merges new analysis into the existing review. Preserve existing assessments; enrich with additional context. Inform the user: "Quarter already has a review — updating with fresh context."

### Step 3: Read sources
- `00_Strategy/YYYY-QX/Quarterly Plan.md` — what was planned
- All monthly pulses for the quarter
- All weekly reviews for the quarter (from `01_Execution/YYYY-WXX/`) — including `## Reflection` sections for qualitative themes
- All active project notes in `02_Projects/`
- All knowledge notes created during the quarter in `04_Knowledge/`

### Step 4: Synthesize
Produce analysis:
- Objective-by-objective: achieved / partial / missed
- Wins and misses with reasons
- Patterns across the quarter (from monthly pulses + weekly reviews)
- Horizon items that were collected but unresolved → carry to next quarter
- Suggested next quarter focus

### Step 5: Write Quarterly Review
Write `00_Strategy/YYYY-QX/Quarterly Review.md` using the template. Leave space for manual reflection.

### Step 6: Open the file
Run `obsidian open path="00_Strategy/YYYY-QX/Quarterly Review.md"` to open the file in Obsidian.
