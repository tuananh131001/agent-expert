#!/usr/bin/env bash
# Download (if a URL) and transcribe podcast audio locally with faster-whisper.
# Usage: transcribe.sh <audio-url-or-file> <work-dir> [model]
# Writes <work-dir>/transcript.txt with "[h:mm:ss] text" lines.
# Model defaults to base.en (fast on CPU); use small.en / medium.en for better accuracy if time allows.
set -euo pipefail
SRC="$1"; WORK="$2"; MODEL="${3:-base.en}"
HERE="$(cd "$(dirname "$0")" && pwd)"
VENV="${PODCAST_TO_ARTICLE_VENV:-$HOME/.cache/podcast-to-article/venv}"
mkdir -p "$WORK/audio"

if [[ ! -x "$VENV/bin/python" ]]; then
  python3 -m venv "$VENV"
  "$VENV/bin/pip" -q install faster-whisper
fi

if [[ "$SRC" =~ ^https?:// ]]; then
  curl -sSL "$SRC" -o "$WORK/audio/episode.mp3"
  SRC="$WORK/audio/episode.mp3"
fi

# Decode with ffmpeg to raw 16 kHz mono PCM. This sidesteps PyAV version incompatibilities in faster-whisper.
ffmpeg -v error -y -i "$SRC" -ac 1 -ar 16000 -f s16le "$WORK/audio/episode.pcm"
DUR=$(ffprobe -v error -show_entries format=duration -of csv=p=0 "$SRC" | cut -d. -f1)
echo "Audio duration: $((DUR / 60)) min. Transcribing with $MODEL on $(nproc) CPU threads..."

cd "$HERE" && "$VENV/bin/python" -I "$HERE/whisper_pcm.py" "$WORK/audio/episode.pcm" "$WORK/transcript.txt" "$MODEL"
echo "Done: $WORK/transcript.txt ($(wc -l < "$WORK/transcript.txt") lines)"
