#!/bin/bash

SIZE=""
KEY_FILTER=""
KEY_VALUE=""
FORMAT="both"

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
    --format)
        FORMAT="$2"
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
    echo "Usage: transparent-video-converter.sh [options] <input>"
    echo ""
    echo "Options:"
    echo "  --size WIDTH        Scale video to WIDTH (preserves aspect ratio)"
    echo "  --chromakey C:S:B   Chroma key (green/blue screens) e.g. 0x00FF00:0.3:0.1"
    echo "  --colorkey C:S:B    Color key (white/black/any RGB) e.g. 0xFFFFFF:0.3:0.1"
    echo "  --format FORMAT     Output format: webm, mov, or both (default: both)"
    exit 1
fi

BASENAME="${INPUT%.*}"
OUTPUT_WEBM="${BASENAME}-converted.webm"
OUTPUT_MOV="${BASENAME}-converted.mov"

if [ -n "$SIZE" ]; then
    SCALE="scale=${SIZE}:-1:flags=lanczos,"
else
    SCALE=""
fi

# Build filter chains (applied separately to each output from source)
if [ -n "$KEY_FILTER" ]; then
    VF_ALPHA="${SCALE}${KEY_FILTER}=${KEY_VALUE}"
    HAS_ALPHA=true
else
    HAS_ALPHA=false
fi

# WebM with VP9 (Chrome/Firefox)
if [ "$FORMAT" = "webm" ] || [ "$FORMAT" = "both" ]; then
    if [ "$HAS_ALPHA" = true ]; then
        echo "Converting to WebM with ${KEY_FILTER} ($KEY_VALUE)..."
        ffmpeg -y -i "$INPUT" \
            -vf "${VF_ALPHA},format=yuva420p" \
            -c:v libvpx-vp9 -crf 30 -b:v 0 -auto-alt-ref 0 \
            -an "$OUTPUT_WEBM"
    else
        echo "Converting to WebM..."
        ffmpeg -y -i "$INPUT" \
            -vf "${SCALE}format=yuv420p" \
            -c:v libvpx-vp9 -crf 30 -b:v 0 \
            -c:a libopus \
            "$OUTPUT_WEBM"
    fi

    if [ $? -ne 0 ]; then
        echo "ERROR: WebM conversion failed"
        rm -f "$OUTPUT_WEBM"
        [ "$FORMAT" = "webm" ] && exit 1
    else
        echo "WebM output: $OUTPUT_WEBM"
    fi
fi

# MOV with HEVC alpha (Safari/Apple) — encoded directly from source
if [ "$FORMAT" = "mov" ] || [ "$FORMAT" = "both" ]; then
    if [ "$HAS_ALPHA" = true ]; then
        echo "Converting to MOV with ${KEY_FILTER} ($KEY_VALUE)..."
        ffmpeg -y -i "$INPUT" \
            -vf "${VF_ALPHA},format=bgra" \
            -c:v hevc_videotoolbox -allow_sw 1 -alpha_quality 0.75 -tag:v hvc1 \
            -an "$OUTPUT_MOV"
    else
        echo "Converting to MOV..."
        ffmpeg -y -i "$INPUT" \
            -vf "${SCALE}format=yuv420p" \
            -c:v hevc_videotoolbox -tag:v hvc1 \
            -c:a aac \
            "$OUTPUT_MOV"
    fi

    if [ $? -ne 0 ]; then
        echo "ERROR: MOV conversion failed"
        rm -f "$OUTPUT_MOV"
        [ "$FORMAT" = "mov" ] && exit 1
    else
        echo "MOV output: $OUTPUT_MOV"
    fi
fi

echo "Done!"
