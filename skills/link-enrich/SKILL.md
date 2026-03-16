---
name: link-enrich
description: "Obsidian vault graph doctor. Use whenever someone wants to improve, audit, or understand how their notes link to each other. This includes: finding unlinked mentions, inserting missing [[wiki-links]], creating Map of Content (MOC) or index notes for folders, detecting orphan notes, measuring link density, or analyzing hub connectivity. Trigger when a user says their graph is sparse, notes aren't connected, they need a MOC or index for a folder, or want to scan for missing connections. Scans the whole vault and can surgically add links or generate index notes. NOT for moving/organizing files, syncing projects, searching note contents, or formatting a single document."
version: 1.0.0
author: Yuhan Wang
license: MIT
tags: [obsidian, vault, maintenance, links, graph]
---

Vault graph optimizer: scan for unlinked mentions, enrich notes with wiki-links, and generate Map of Content index notes.

## Arguments

- `scan [path]` — Read-only audit. Reports unlinked mentions, orphan notes, graph density, and asymmetric links. No files are modified.
- `apply [path]` — Preview proposed link insertions, then write changes after user confirms.
- `moc [folder]` — Generate a Map of Content index note for a folder (or detect folders that need one).

If no argument is given, default to `scan` across the entire vault.

Path can be a folder (e.g. `02_Projects`) or a single file (e.g. `03_Thinking/My Idea.md`).

---

## Scan Mode

Read-only audit of vault graph health. Output goes to the conversation only — no files are created or modified.

### Step 1: Build the linkable terms catalog

Glob all `.md` files in the vault. For each file, extract the **filename without extension** as a linkable term.

**Exclude** from the catalog:
- Daily notes (`01_Execution/*/YYYY-MM-DD.md` pattern)
- Archive (`05_Archive/**`)
- Meta files (anything in `.obsidian/`, `CLAUDE.md`, `README.md`, `CONTRIBUTING.md`, `LICENSE`, `CODE_OF_CONDUCT.md`, `SECURITY.md`)
- The `skills/` directory

This gives you a set of terms like `ProjectAlpha`, `Weekly Review`, `Quarterly Plan`, `Some Concept Note`, etc.

**Short-title guard:** If a filename is a single common English word (e.g. `Ideas`, `Notes`, `Tasks`, `Draft`), only match it when the full title appears as a standalone phrase — not as a substring of another word. Multi-word filenames and proper nouns are safe to match as substrings within word boundaries.

### Step 2: Scan for unlinked mentions

For each file in scope (respecting the `[path]` argument, or the whole vault if none):

1. Read the file content
2. Identify **protected zones** where links must never be inserted:
   - YAML frontmatter (`---` ... `---` at the top)
   - Code blocks (`` ``` `` ... `` ``` `` and indented code)
   - Existing wiki-links (`[[...]]` — both the brackets and their contents)
   - Heading lines (`# `, `## `, etc.)
   - The file's own title (never self-link)
3. In the remaining text, search for occurrences of catalog terms (case-insensitive for the first letter, exact match otherwise)
4. Record each match: `{file, line, term, context snippet}`

### Step 3: Detect orphan notes

An orphan note is a file that:
- Has **zero incoming links** (no other file contains `[[This Note]]`)
- Has **zero outgoing links** (contains no `[[...]]` references)

Exclude daily notes, templates, and archive from orphan detection.

### Step 4: Compute graph metrics

- **Total notes** in scope (excluding daily notes and archive)
- **Total wiki-links** found across all files
- **Link density** = total links / total notes (average links per note)
- **Orphan count** and list
- **Unlinked mention count** and top 10 by frequency
- **Asymmetric hubs**: notes with >10 outgoing links but <2 incoming (linked-to but not linked-from, or vice versa)

### Step 5: Report

Present a structured report to the user:

```
## Vault Graph Audit

### Metrics
- Notes scanned: X
- Total wiki-links: X
- Link density: X.X links/note
- Orphan notes: X
- Unlinked mentions found: X

### Top Unlinked Mentions
1. "ProjectAlpha" — found in 12 files (currently linked in 5)
2. "Some Concept" — found in 8 files (currently linked in 0)
...

### Orphan Notes
- [[Forgotten Idea]] (03_Thinking/)
- [[Old Research Note]] (04_Knowledge/)
...

### Asymmetric Hubs
- [[ProjectAlpha]] — 15 outgoing, 1 incoming (hub that nobody links to)
...
```

If running on a specific path, scope all metrics to that path but still use the full vault catalog for term matching.

---

## Apply Mode

Preview proposed link enrichments, then write changes after user confirmation.

### Step 1: Run scan

Execute Steps 1-2 from Scan Mode to identify all unlinked mentions in scope.

### Step 2: Preview changes

For each file that has unlinked mentions, show a preview:

```
### 03_Thinking/My Idea.md (3 links to add)
- Line 12: "discussed this with the ProjectAlpha team" → "discussed this with the [[ProjectAlpha]] team"
- Line 25: "similar to Quarterly Plan goals" → "similar to [[Quarterly Plan]] goals"
- Line 31: "see the Decision Framework" → "see the [[Decision Framework]]"
```

Group by file. Show the before→after for each line with enough context to judge.

### Step 3: Confirm

Ask the user to confirm before writing. Accept:
- **"yes" / "all"** — apply all proposed changes
- **"skip [filename]"** — exclude specific files
- **"only [filename]"** — apply only to specific files
- **"no"** — abort

### Step 4: Write changes

For each confirmed file, apply the link insertions. Use the Edit tool for surgical replacements — replace the exact unlinked mention with the `[[wiki-link]]` version.

**Insertion rules:**
- Only wrap the first occurrence of each term per file (avoid over-linking)
- Never modify frontmatter, code blocks, existing links, or headings
- Never create self-links
- Preserve the original casing of the matched text inside the link: if the text says "quarterly plan", write `[[Quarterly Plan|quarterly plan]]` (display alias preserves original case)

### Step 5: Summary

After applying, report:
- Files modified: X
- Links added: X
- Suggest running `scan` again to verify idempotency (should find zero new matches)

---

## MOC Mode

Generate Map of Content index notes for folders that lack them.

### Step 1: Identify target folders

If a specific folder is given, use it. Otherwise, scan for folders that:
- Contain 5+ notes
- Have no existing `MOC.md`, `Index.md`, or `_Index.md` file
- Are not daily note folders (`01_Execution/YYYY-WXX/`), archive, or meta directories

Suggest these folders to the user and ask which ones to create MOCs for.

### Step 2: Build the MOC

For each target folder, read all `.md` files in it (non-recursive — subfolders get their own MOC if needed). For each note, extract:
- **Title** — from the first `# heading`, or filename without extension
- **Summary** — first meaningful paragraph or content under the first `##` heading (one sentence max)
- **Frontmatter fields** — `type`, `status`, `date`, `project` if present

### Step 3: Organize entries

Group notes by `type` frontmatter field if present. Within each group, sort by `date` descending (newest first). If no `type` field exists, list alphabetically.

### Step 4: Write the MOC

Write `[Folder Name] MOC.md` in the target folder:

```markdown
---
type: moc
date: YYYY-MM-DD
---

# [Folder Name] — Map of Content

> Auto-generated by /link-enrich moc on YYYY-MM-DD. Safe to edit — re-running will regenerate.

## [Group Name]

- [[Note Title]] — One-sentence summary
- [[Another Note]] — Summary here
...
```

### Step 5: Report

List the MOC files created and how many notes each indexes.

---

## Idempotency

All modes are safe to re-run:
- `scan` is read-only and always produces a fresh report
- `apply` after a previous `apply` should find zero new unlinked mentions (if it does, that indicates a bug)
- `moc` regenerates the MOC from scratch each time — existing MOC content is replaced, not appended

## Language

Write all output and generated content in English.
