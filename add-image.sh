#!/bin/bash

# This script adds a new image to the blog

set -e

ROOT=$(dirname $0)
BASEPATH="/static/img/blog"
BLOG_BASEPATH="/img/blog"
COPY_CLIPBOARD=${COPY_CLIPBOARD:-clip.exe}

OPT=$(getopt -o dn: --long date,name: -- "$@")
if [ $? != 0 ] ; then echo "Failed parsing options." >&2 ; exit 1 ; fi

eval set -- "$OPT"

DATE=$(date +%Y-%m-%d)
NAME=""

while true; do
    case "$1" in
        -d | --date ) DATE="$2"; shift 3 ;;
        -n | --name ) NAME="$2"; shift 3 ;;
        -- ) shift; break ;;
        * ) break ;;
    esac
done

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
