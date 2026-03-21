#!/bin/bash

MODEL="isnet-general-use"
SIZE=""

while [ $# -gt 0 ]; do
    case "$1" in
    --model)
        MODEL="$2"
        shift 2
        ;;
    --size)
        SIZE="$2"
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
    echo "Usage: ./remove-bg.sh [--model MODEL] [--size WIDTH] <input.png>"
    echo ""
    echo "Models: u2net (default: isnet-general-use), birefnet-general, etc."
    exit 1
fi

BASENAME="$(basename "${INPUT%.*}")"
EXT="${INPUT##*.}"
OUTPUT="${BASENAME}-removebg.png"
TMP_IN="/tmp/${BASENAME}_$$.${EXT}"
TMP_OUT="/tmp/${BASENAME}_$$-removebg.png"

cp "$INPUT" "$TMP_IN"

echo "Removing background (model: $MODEL)..."
rembg i -m "$MODEL" "$TMP_IN" "$TMP_OUT"

if [ $? -eq 0 ]; then
    if [ -n "$SIZE" ]; then
        echo "Resizing to ${SIZE}px wide..."
        magick "$TMP_OUT" -resize "${SIZE}x" "$TMP_OUT"
    fi
    cp "$TMP_OUT" "$OUTPUT"
    rm "$TMP_IN" "$TMP_OUT"
    echo "Done! Output: $OUTPUT"
else
    rm -f "$TMP_IN" "$TMP_OUT"
    echo "Error: rembg failed"
    exit 1
fi
