#!/usr/bin/env bash

SCRIPTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
cd "$SCRIPTDIR" || exit 1

cmd="default"
if [[ -n $1 && $1 =~ ^default|all|drawio|plantuml|-h|--help|help$ ]]; then cmd=$1 ; shift ; fi
if [[ $cmd =~ ^-h|--help|help$ ]]; then
  echo "synopsis: ${0##*/} [all|drawio|plantuml|-h|--help|help]"
  exit 0
fi

function main() {
  if [[ $cmd == "default" || $cmd == "all" || $cmd == "drawio" ]]; then
    drawio "."
  fi
  if [[ $cmd == "default" || $cmd == "all" || $cmd == "plantuml" ]]; then
    plantumlFunc "."
  fi
}

#export DRAWIOEXE="/mnt/c/Program Files/draw.io/draw.io.exe"
export DRAWIOEXE="/Applications/draw.io.app/Contents/MacOS/draw.io"

function drawio() {
  local chassisassetsgit="$1"
  mapfile -d $'\0' paths < <(find -L "$chassisassetsgit" -type d \( -name public -o -name tmp -o -name resources -o -name vendor -o -name node_modules -o -name dist \) -prune \
      -o -type f -name '*.drawio' -print0)
  for file in "${paths[@]}"; do
      "$DRAWIOEXE" "$file" --crop --export --format png --embed-diagram --output "${file}.png" | awk '{m=match($0, $2); print "      " substr($0,m)}'
      "$DRAWIOEXE" "$file" --crop --export --format svg --embed-diagram --output "${file}.svg" | awk '{m=match($0, $2); print "      " substr($0,m)}'
  done
}

function plantumlFunc() {
  local chassisassetsgit="$1"
  mapfile -d $'\0' paths < <(find -L "$chassisassetsgit" -type d \( -name public -o -name tmp -o -name resources -o -name vendor -o -name node_modules -o -name dist \) -prune \
      -o -type f -name '*.plantuml' -print0)
  for file in "${paths[@]}"; do
      plantuml -tpng "$file"
      plantuml -tsvg "$file"
  done
}

main "$@"

