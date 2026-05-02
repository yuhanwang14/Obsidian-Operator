#!/bin/bash
# obsidian-operator/hooks/preflight-enforce.sh
# Hook event: UserPromptSubmit (auto-registered via hooks/hooks.json on plugin install)
#
# When the user invokes /daily-init (or natural-language equivalents), this script checks
# the vault for missing pre-flight artifacts (last week's review, last week's AI digest,
# last month's pulse, last quarter's review, current quarter's plan) and emits a
# <system-reminder>-tagged additionalContext that forces Claude to run the missing
# skill(s) before any other daily-init work.
#
# This is harness-level enforcement — it does NOT depend on Claude reading the daily-init
# SKILL.md and choosing to obey it. The hook fires deterministically + the system-reminder
# carries strong authority weight.
#
# Regression history: 2026-05-01 + 2026-05-02. April Monthly Pulse was missed for 2
# consecutive days because Claude flagged-and-skipped the auto-trigger inside daily-init's
# Pre-Flight Step 1c (the downstream /quarterly-plan pulse skill had interactive sub-steps
# that Claude rationalized as "too heavy"). Fixed in v1.7.9 with this hook + auto-mode-skip
# clauses inside the downstream skills.

set -uo pipefail

# Read hook input from stdin (Claude Code passes JSON)
input="$(cat 2>/dev/null || echo '{}')"

# Extract event name + user message (defensive — exit clean on any parse failure)
event=$(printf '%s' "$input" | jq -r '.hook_event_name // empty' 2>/dev/null || echo "")
user_msg=$(printf '%s' "$input" | jq -r '.prompt // .user_input // .user_message // empty' 2>/dev/null || echo "")

# Only act on UserPromptSubmit
[ "$event" = "UserPromptSubmit" ] || exit 0

# Filter: only fire on /daily-init or close natural-language equivalents
if ! printf '%s' "$user_msg" | grep -qiE '/daily-init|start my day|morning briefing|set up today|begin today|initialize today'; then
  exit 0
fi

# Resolve vault root (in priority order)
VAULT=""
if [ -n "${OBSIDIAN_OPERATOR_VAULT:-}" ] && [ -d "${OBSIDIAN_OPERATOR_VAULT}/00_Strategy" ]; then
  VAULT="$OBSIDIAN_OPERATOR_VAULT"
elif [ -d "$(pwd)/00_Strategy" ]; then
  VAULT="$(pwd)"
elif [ -d "$HOME/Obsidian/Operator/00_Strategy" ]; then
  VAULT="$HOME/Obsidian/Operator"
elif [ -n "${CODEX_HOME:-}" ] && [ -d "${CODEX_HOME}/worktrees" ]; then
  for w in "${CODEX_HOME}"/worktrees/*/; do
    [ -d "${w}00_Strategy" ] && VAULT="${w%/}" && break
  done
  [ -z "$VAULT" ] && exit 0
else
  # Can't locate vault — exit silently rather than block
  exit 0
fi

# Compute date components (BSD date syntax — macOS)
today_year=$(date +%Y)
today_month=$(date +%m)
today_quarter=$(( (10#$today_month - 1) / 3 + 1 ))
today_iso_year=$(date +%G)
today_iso_week=$(date +%V)

# Last calendar month
last_month=$(date -v-1m +%m)
last_month_year=$(date -v-1m +%Y)
last_month_quarter=$(( (10#$last_month - 1) / 3 + 1 ))

# Last ISO week (7 days ago — handles year boundaries via %G)
last_iso_year=$(date -v-7d +%G)
last_iso_week=$(date -v-7d +%V)

# Last quarter
last_quarter_year=$today_year
last_quarter=$(( today_quarter - 1 ))
if [ "$last_quarter" -lt 1 ]; then
  last_quarter=4
  last_quarter_year=$(( today_year - 1 ))
fi

# Accumulate missing artifacts + the slash command to fix each
missing=()
fix_commands=()

# Steps 1 + 1b — Weekly Review + AI Weekly Digest (only if crossed week boundary)
if [ "$today_iso_year" != "$last_iso_year" ] || [ "$today_iso_week" != "$last_iso_week" ]; then
  weekly_review="$VAULT/01_Execution/${last_iso_year}-W${last_iso_week}/Weekly Review.md"
  if [ ! -f "$weekly_review" ]; then
    missing+=("Weekly Review for ${last_iso_year}-W${last_iso_week}")
    fix_commands+=("/weekly-review ${last_iso_year}-W${last_iso_week}")
  fi

  ai_digest="$VAULT/04_Knowledge/AI-Weekly/${last_iso_year}-W${last_iso_week} - AI Weekly Digest.md"
  if [ ! -f "$ai_digest" ]; then
    missing+=("AI Weekly Digest for ${last_iso_year}-W${last_iso_week}")
    fix_commands+=("/ai-weekly-digest")
  fi
fi

# Step 1c — Monthly Pulse (only if crossed month boundary)
if [ "$today_year" != "$last_month_year" ] || [ "$today_month" != "$last_month" ]; then
  monthly_pulse="$VAULT/00_Strategy/${last_month_year}-Q${last_month_quarter}/Monthly Pulse - ${last_month}.md"
  if [ ! -f "$monthly_pulse" ]; then
    missing+=("Monthly Pulse for ${last_month_year}-${last_month}")
    fix_commands+=("/quarterly-plan pulse ${last_month_year}-${last_month}")
  fi
fi

# Steps 1d + 1e — Quarterly Review + Quarterly Plan (only if crossed quarter boundary)
if [ "$today_quarter" != "$last_quarter" ] || [ "$today_year" != "$last_quarter_year" ]; then
  quarterly_review="$VAULT/00_Strategy/${last_quarter_year}-Q${last_quarter}/Quarterly Review.md"
  if [ ! -f "$quarterly_review" ]; then
    missing+=("Quarterly Review for ${last_quarter_year}-Q${last_quarter}")
    fix_commands+=("/quarterly-plan review ${last_quarter_year}-Q${last_quarter}")
  fi
  quarterly_plan="$VAULT/00_Strategy/${today_year}-Q${today_quarter}/Quarterly Plan.md"
  if [ ! -f "$quarterly_plan" ]; then
    missing+=("Quarterly Plan for ${today_year}-Q${today_quarter}")
    fix_commands+=("/quarterly-plan init")
  fi
fi

# If nothing missing, exit silently — daily-init proceeds normally
if [ ${#missing[@]} -eq 0 ]; then
  exit 0
fi

# Build the system-reminder string
build_reminder() {
  cat <<EOF
<system-reminder>
DAILY-INIT PRE-FLIGHT REQUIREMENTS DETECTED — these MUST be completed before any other daily-init work, in this exact order:

EOF
  i=0
  while [ $i -lt ${#missing[@]} ]; do
    printf '%d. Run \`%s\` (%s missing)\n' $((i+1)) "${fix_commands[$i]}" "${missing[$i]}"
    i=$((i+1))
  done
  cat <<EOF

These are NON-NEGOTIABLE pre-flight checks (enforced by obsidian-operator hooks/preflight-enforce.sh, plugin v1.7.9+). Auto-mode skip clauses are active in the downstream skills, so each runs without interactive prompts. Do not flag-and-defer; do not "just generate the briefing first" — run the missing skill(s) FIRST, then resume /daily-init.
</system-reminder>
EOF
}

reminder=$(build_reminder)

# Emit JSON via jq (handles escaping of newlines + special chars cleanly)
jq -n --arg ctx "$reminder" '{
  hookSpecificOutput: {
    hookEventName: "UserPromptSubmit",
    additionalContext: $ctx
  }
}'

exit 0
