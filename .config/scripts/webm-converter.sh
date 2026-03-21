#!/bin/bash

SIZE=""
KEY_FILTER=""
KEY_VALUE=""

while [ $# -gt 0 ]; do
    case "$1" in
    --size)
        SIZE="$2"
        shift 2
        ;;
    --chromakey)
        KEY_FILTER="chromakey"
        KEY_VALUE="$2"
        shift 2
        ;;
    --colorkey)
        KEY_FILTER="colorkey"
        KEY_VALUE="$2"
        shift 2
        ;;
    -*)
        echo "Unknown option: $1"
        exit 1
        ;;
    *)
        INPUT="$1"
        shift
        ;;
    esac
done

if [ -z "$INPUT" ]; then
    echo "Usage: ./webm-converter.sh [--size WIDTH] [--chromakey | --colorkey COLOR:SIMILARITY:BLEND] <input.mp4>"
    echo ""
    echo "Options:"
    echo "  --chromakey  Chroma key (green/blue screens) as COLOR:SIMILARITY:BLEND (e.g. 0x00FF00:0.3:0.1)"
    echo "  --colorkey   Color key (white/black/any RGB) as COLOR:SIMILARITY:BLEND (e.g. 0xFFFFFF:0.3:0.1)"
    exit 1
fi

BASENAME="${INPUT%.*}"
OUTPUT="${BASENAME}-converted.webm"

if [ -n "$SIZE" ]; then
    SCALE="scale=${SIZE}:-1:flags=lanczos,"
else
    SCALE=""
fi

if [ -n "$KEY_FILTER" ]; then
    echo "Converting to WebM with ${KEY_FILTER} ($KEY_VALUE)..."
    ffmpeg -i "$INPUT" \
        -vf "${SCALE}${KEY_FILTER}=${KEY_VALUE},format=yuva420p" \
        -c:v libvpx-vp9 -crf 30 -b:v 0 -auto-alt-ref 0 \
        -an "$OUTPUT"
else
    echo "Converting to WebM..."
    ffmpeg -i "$INPUT" \
        -vf "${SCALE}format=yuv420p" \
        -c:v libvpx-vp9 -crf 30 -b:v 0 \
        -c:a libopus \
        "$OUTPUT"
fi

echo "Done! Output: $OUTPUT"
