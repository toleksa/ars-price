#!/bin/bash

_checkInstalled(){
  which $1 > /dev/null 2>&1; RC=$?
  if [ "$RC" -ne 0 ]; then
    echo "ERR: no '$1' found in \$PATH"
    exit 1
  fi
}

_checkInstalled gnuplot
_checkInstalled rsvg-convert

ARG=""
ARG="$ARG set style line 1 lt 1 lw 3 pt 3 linecolor rgb 'blue' ;"
ARG="$ARG set title 'ARS SteamCode price - `date +%Y%m%d-%H:%M:%S`' ;"
ARG="$ARG set ylabel 'EuroCents' ;"
ARG="$ARG set term svg; set output '|rsvg-convert -f png -o out.png /dev/stdin';"
ARG="$ARG plot '/dev/stdin' with lines"

cat price-log.txt \
  | gawk '{ print $1 }' \
  | gnuplot -p -e "$ARG" \
  && chcon -t httpd_sys_content_t out.png \
  && mv out.png /var/www/html/ 

