---
name: deep-research
description: "TRIGGER for /deep-research, or for natural-language requests for a deep dive, comprehensive/multi-angle research, structured research brief, or a durable knowledge note saved to the vault. NOT for casual lookups, single-fact questions, or quick fact-checks (use WebSearch instead)."
---

Conduct systematic deep research on a topic using parallel agents, producing a detailed knowledge note.

## Arguments

Three input modes:

1. **Topic string** — `/deep-research "How do modern inference engines handle speculative decoding?"`
2. **File reference** — `/deep-research 02_Projects/MyProject/MyProject.md` — research the project's open questions
3. **No args** — ask the user what to research

## Step 1 — Establish the research goal

**If no argument:** Ask the user what they want to research.

**If file reference:** Read the file. Extract open questions, risks, and gaps from `## Open Questions`, `## Risks`, `## Now`, or similar sections. Present them and ask which to research (or research all).

**If topic string:** Use it directly.

Then — regardless of input mode — **probe once to sharpen the goal**:

> "Your research goal is: [stated goal]. To make this more targeted:"
> 1. What's the intended use? (inform a project decision / learning / competitive analysis / exploration)
> 2. Any specific angles you care about most? (technical depth / market landscape / historical context / comparisons)
> 3. What do you already know or assume? (so I don't waste threads on known ground)

If the user gives brief answers, incorporate them. If they say "just go," proceed with the original goal as-is.

**Output:** A refined **research brief** — 2-3 sentences capturing the goal, intended use, and any constraints.

## Step 2 — Identify project & save location

Determine where the report will be saved:

1. If the input was a file reference under `02_Projects/` or `04_Knowledge/`, infer the project from the path.
2. If the topic clearly relates to an active project (check `02_Projects/` folder names), confirm: "This seems related to [[ProjectName]] — should I save the research there?"
3. If no project match, ask: "Which project does this relate to? Or should I create a topic folder (e.g. `04_Knowledge/[Topic]/`)?"

**Save path:** `04_Knowledge/[Project or Topic]/Research/YYYY-MM-DD - [Short Title].md`

Always use a `Research/` subfolder. Create it if it doesn't exist.

## Step 3 — Decompose into research threads

Break the research brief into **3-5 parallel threads**, each targeting a different dimension. Common axes (pick what fits — not all apply to every question):

- **Technical / mechanistic** — how does it work, what are the approaches
- **State of the art** — who's doing it best, latest results, benchmarks
- **Competitive / market** — who are the players, what are the products
- **Historical / evolutionary** — how did we get here, key inflection points
- **Gaps & frontiers** — what's unsolved, where is the field heading
- **Practical / applied** — how to actually use it, implementation considerations

Each thread gets:
- A **thread name** (2-4 words)
- A **specific question** to answer
- **Search strategy hints** (suggested queries, sites, source types to prioritize)

## Step 4 — Execute parallel research

Dispatch one research agent per thread, **all in a single batch** so they run in parallel.

**Platform syntax:**

- **Claude Code:** Use the `Agent` tool, multiple calls in one message, `model: "opus"` for each agent.
- **Codex CLI:** Use `spawn_agent(agent_type="worker", message=...)` for each thread in one message, then `wait` to collect results, then `close_agent` per agent. Requires `[features] multi_agent = true` in `~/.codex/config.toml` — see `using-obsidian-operator/references/codex-tools.md` for full setup and message-framing template. **Fallback:** if `multi_agent` is not enabled (`spawn_agent` errors), execute threads sequentially in the parent agent and emit a one-line note: `"Running threads sequentially — enable [features] multi_agent = true in ~/.codex/config.toml for parallel."`

Each agent's prompt must include:
1. The overall research brief (for context)
2. Its specific thread question and search strategy hints
3. Instructions to use `WebSearch` and `WebFetch` extensively — aim for **5–10 high-quality sources per thread**
4. Instructions to return:
   - **Thread:** [name]
   - **Key findings:** bulleted list of substantive findings with source URLs
   - **Sources:** list of URLs consulted with one-line quality notes
   - **Surprises:** anything that contradicted initial assumptions
   - **Gaps:** what couldn't be answered

If a thread returns thin results (fewer than 3 substantive findings), note it — the synthesis step will flag it as a gap.

## Step 5 — Synthesize and write the report

After all thread agents return, dispatch **one final synthesis agent**.

**Platform syntax:**
- **Claude Code:** `Agent` tool, single call, `model: "opus"`.
- **Codex CLI:** single `spawn_agent(agent_type="worker", message=...)` + `wait` + `close_agent`. (`multi_agent` feature must be enabled, same as Step 4.)

The synthesis agent's prompt must include:
1. The research brief
2. All thread results (full text from each agent)
3. Instructions below

**Synthesis agent instructions:**

Write a deeply detailed research note. The frontmatter is:

```yaml
---
type: research
date: YYYY-MM-DD
project: [Project if applicable, omit if none]
---
```

Title: `# [Research Topic]`

After that — **no rigid template**. Structure the content however best serves the topic. Use whatever headings, sections, depth, and organization makes the research most useful. The only hard requirement is: **be extremely detailed**. Cover every substantive finding from the threads. Include paper references with arXiv/DOI links where available. Include GitHub repos, tools, benchmarks. Quote specific numbers, results, comparisons. Don't summarize when you can explain. Don't hand-wave when you can cite.

If threads revealed contradictions, dedicate space to analyzing them. If there are clear gaps, call them out explicitly. If a finding is surprising or counterintuitive, explain why.

The output should read like a thorough research report that someone could use as their primary reference on the topic — not a surface-level overview.

## Step 6 — Save and report back

Save the synthesis agent's output to the path determined in Step 2.

Report:
- Research note saved to: `[path]`
- One-sentence summary of the headline finding
- Thread coverage: which threads produced strong results, which had gaps

---

**Next steps:**
1. If project-related, run `/project-sync [project]` to include in Knowledge Base
2. Review gaps — run `/deep-research` again on unresolved sub-questions if needed

## Idempotency

Each run creates a new dated file. Running `/deep-research` on the same topic again produces a separate report. This is intentional — research evolves.

## Language

Write in English unless the user explicitly asks otherwise.
