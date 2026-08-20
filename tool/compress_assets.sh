#!/usr/bin/env bash
#
# Brings every bundled image down to the size the app actually draws it at.
#
# Run from the project root after dropping new artwork into assets/. It
# rewrites the files in place and is safe to run twice: an image already at
# or below its cap is only re-encoded, never upscaled.
#
# A portrait is drawn at 180 logical pixels at most (GuideDialoguePanel),
# so 512 covers a 3x screen. A city card is drawn full-bleed behind a
# scrim, so 1280 covers the projector this is played on. Anything larger
# is pixels nobody sees.
#
# Alpha decides the format, not habit: a portrait with transparency shows
# the frame's fill through it, so it stays a quantised PNG. Everything
# else is a photograph or a painting and belongs in JPEG.

set -euo pipefail

command -v magick >/dev/null || {
  echo 'ImageMagick is required: brew install imagemagick' >&2
  exit 1
}

readonly PORTRAIT_CAP=512
readonly CARD_CAP=1280
readonly QUALITY=85

compress() {
  local file=$1 cap=$2 quality=$3 tmp format target

  if [[ $(magick identify -format '%A' "$file") == 'Blend' ]]; then
    format=png
  else
    format=jpg
  fi
  target="${file%.*}.$format"
  tmp=$(mktemp -t compress_assets)

  if [[ $format == png ]]; then
    magick "$file" -resize "${cap}x${cap}>" -strip \
      -colors 128 -define png:compression-level=9 "png:$tmp"
  else
    magick "$file" -resize "${cap}x${cap}>" -strip \
      -interlace Plane -quality "$quality" "jpeg:$tmp"
  fi

  local before after
  before=$(wc -c <"$file")
  after=$(wc -c <"$tmp")
  if ((after >= before)) && [[ $target == "$file" ]]; then
    rm -f "$tmp"
    echo "$file: already at $before bytes"

    return
  fi

  mv "$tmp" "$target"
  # mktemp is 0600; assets are read by everyone who checks the repo out.
  chmod 644 "$target"
  if [[ $target != "$file" ]]; then
    rm -f "$file"
    echo "$file -> $target: $before -> $after bytes (update the reference)"
  else
    echo "$file: $before -> $after bytes"
  fi
}

for portrait in assets/characters/*.{png,jpg,jpeg}; do
  [[ -e $portrait ]] || continue
  compress "$portrait" "$PORTRAIT_CAP" "$QUALITY"
done

for card in assets/levels/*.{png,jpg,jpeg}; do
  [[ -e $card ]] || continue
  compress "$card" "$CARD_CAP" 80
done
