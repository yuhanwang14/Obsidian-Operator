#!/bin/bash
set -euo pipefail

AUDIO="$1"
LANG="${2:-Chinese and English mixed}"
CHUNK_SECS=1200  # 20 minutes per chunk

# Load API key from secrets (configurable via SECRETS_FILE env var)
SECRETS_FILE="${SECRETS_FILE:-$HOME/.secrets}"
[ -f "$SECRETS_FILE" ] && source "$SECRETS_FILE"

if [ -z "${GEMINI_API_KEY:-}" ]; then
  echo "Error: GEMINI_API_KEY not set" >&2
  exit 1
fi

MODEL="${GEMINI_MODEL:-gemini-3.1-pro-preview}"
API_URL="https://generativelanguage.googleapis.com/v1beta/models/${MODEL}:generateContent?key=$GEMINI_API_KEY"
MIME="audio/mp4"
PROMPT="Transcribe this audio recording verbatim. The language is $LANG. You MUST output in Simplified Chinese (简体中文), not Traditional Chinese. Format: use **Speaker N:** labels for different speakers. Insert timestamps like (M:SS) every 3 minutes. Output only the transcript, starting with **Transcript**. Preserve the original language exactly as spoken — do not translate English words to Chinese or vice versa."

# Get duration
DURATION=$(ffprobe -v error -show_entries format=duration -of csv=p=0 "$AUDIO" 2>/dev/null | cut -d. -f1)
if [ -z "$DURATION" ]; then
  echo "Error: Cannot read audio duration" >&2
  exit 1
fi

transcribe_chunk() {
  local chunk_file="$1"
  local chunk_idx="$2"
  local offset_secs="$3"

  local b64
  b64=$(base64 -i "$chunk_file")

  local offset_min=$((offset_secs / 60))
  local ts_prompt="$PROMPT Timestamps should start from approximately ${offset_min}:00 (this chunk starts at minute $offset_min of the full recording)."

  local response
  response=$(python3 -c "
import json, sys
payload = {
    'contents': [{
        'parts': [
            {'inline_data': {'mime_type': '$MIME', 'data': open('/dev/stdin').read().strip()}},
            {'text': '''$ts_prompt'''}
        ]
    }],
    'generationConfig': {'temperature': 0.1}
}
print(json.dumps(payload))
" <<< "$b64" | curl -s "$API_URL" \
    -H "Content-Type: application/json" \
    -d @-)

  echo "$response" | python3 -c "
import json, sys
r = json.load(sys.stdin)
try:
    text = r['candidates'][0]['content']['parts'][0]['text']
    # Strip leading **Transcript** header from non-first chunks
    if int('$chunk_idx') > 0:
        import re
        text = re.sub(r'^\*\*Transcript\*\*\s*\n*', '', text)
    print(text)
except (KeyError, IndexError):
    print('Error: Chunk $chunk_idx failed', file=sys.stderr)
    print(json.dumps(r, indent=2), file=sys.stderr)
    sys.exit(1)
"
}

if [ "$DURATION" -le "$CHUNK_SECS" ]; then
  # Short audio — single call
  transcribe_chunk "$AUDIO" 0 0
else
  # Split into chunks and transcribe sequentially
  TMPDIR=$(mktemp -d)
  trap "rm -rf $TMPDIR" EXIT

  NUM_CHUNKS=$(( (DURATION + CHUNK_SECS - 1) / CHUNK_SECS ))
  echo "Splitting into $NUM_CHUNKS chunks (~20 min each)..." >&2

  echo "**Transcript**"
  echo ""

  for ((i=0; i<NUM_CHUNKS; i++)); do
    OFFSET=$((i * CHUNK_SECS))
    CHUNK_FILE="$TMPDIR/chunk_${i}.m4a"

    ffmpeg -v error -i "$AUDIO" -ss "$OFFSET" -t "$CHUNK_SECS" -c copy "$CHUNK_FILE"

    echo "Transcribing chunk $((i+1))/$NUM_CHUNKS (offset ${OFFSET}s)..." >&2
    transcribe_chunk "$CHUNK_FILE" "$i" "$OFFSET"
    echo ""
  done
fi
