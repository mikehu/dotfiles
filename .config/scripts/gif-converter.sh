#!/bin/bash

SIZE=""
MAX_COLORS=256

while [ $# -gt 0 ]; do
    case "$1" in
        --size)
            SIZE="$2"
            shift 2
            ;;
        --max-colors)
            MAX_COLORS="$2"
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
    echo "Usage: ./gif_convert.sh [--size WIDTH] [--max-colors N] <input.mp4>"
    exit 1
fi

BASENAME="${INPUT%.*}"
OUTPUT="${BASENAME}-converted.gif"
PALETTE="/tmp/palette_$$.png"

if [ -n "$SIZE" ]; then
    SCALE="scale=${SIZE}:-1:flags=lanczos,"
else
    SCALE=""
fi

echo "Generating palette..."
ffmpeg -i "$INPUT" -vf "fps=10,${SCALE}palettegen=max_colors=${MAX_COLORS}:stats_mode=diff" "$PALETTE"

echo "Converting to GIF..."
ffmpeg -i "$INPUT" -i "$PALETTE" -filter_complex "fps=10,${SCALE}null[x];[x][1:v]paletteuse=dither=bayer:bayer_scale=5:diff_mode=rectangle" "$OUTPUT"

rm "$PALETTE"

if command -v gifsicle > /dev/null 2>&1; then
    echo "Optimizing with gifsicle..."
    gifsicle -O3 "$OUTPUT" -o "$OUTPUT"
fi

echo "Done! Output: $OUTPUT"
