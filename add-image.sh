#!/bin/bash

# This script adds a new image to the blog

set -e

function usage {
    echo "Usage: $0 <input>"
    echo "  -d    Date of the image (default: $(date +%Y-%m-%d))"
    echo "  -n    Name of the image (default: input filename)"
    echo "  -h    Show this help"
}

ROOT=$(dirname $0)
BASEPATH="/static/img/blog"
BLOG_BASEPATH="/img/blog"
COPY_CLIPBOARD=${COPY_CLIPBOARD:-clip.exe}

OPT=$(getopt -o d:n:h -- "$@")
if [ $? != 0 ] ; then echo "Failed parsing options." >&2 ; usage ; exit 1 ; fi

eval set -- "$OPT"

DATE=$(date +%Y-%m-%d)
NAME=""

while true; do
    case "$1" in
        -d) DATE="$2"; shift 2;;
        -n) NAME="$2"; shift 2;;
        -h) usage; exit 0;;
        --) shift; break;;
        *) shift; break;;
    esac
done

if [ $# -ne 1 ]; then
    usage
    exit 1
fi

INPUT="$1"
INPUT_EXT="${INPUT##*.}"

if [ -z "$NAME" ]; then
    NAME=$(basename "$INPUT")
    NAME="${NAME%.*}.png"
fi

FILENAME="$(date +%Y --date="$DATE")/$(date +%m --date="$DATE")/$NAME"
OUTPUT="$ROOT$BASEPATH/$FILENAME"

WIDTH=$(identify -format "%w" "$INPUT")
CONVERT=0
CONVERT_OPTS=""

if [ $WIDTH -gt 800 ]; then
    CONVERT=1
    CONVERT_OPTS="-resize 800"
fi

if [ $INPUT_EXT != "png" ]; then
    CONVERT=1
    CONVERT_OPTS="$CONVERT_OPTS -format png"
fi

echo "Adding image $INPUT to $OUTPUT"
echo "Width: $WIDTH"

if [ $CONVERT -eq 1 ]; then
    echo "Converting image"
    echo "Convert options: $CONVERT_OPTS"
fi
echo

echo "Press enter to continue"
read

mkdir -p $(dirname $OUTPUT)

if [ $CONVERT -eq 1 ]; then
    convert "$INPUT" $CONVERT_OPTS "$OUTPUT"
else
    cp "$INPUT" "$OUTPUT"
fi

echo "Done."

$COPY_CLIPBOARD < <(echo -n "$BLOG_BASEPATH/$FILENAME")

echo "Path copied to clipboard: $BLOG_BASEPATH/$FILENAME"
