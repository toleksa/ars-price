#!/bin/bash

FILE="price-log.txt"

CURRENT_PRICE=$(gawk 'END{ print $1 }' $FILE)
LOWEST_PRICE=$(sort -n price-log.txt | grep -Ev '^0' | head -n 1 | gawk '{ print $1" at "$2 }')
ERR_RATE=$(TOTAL_LINES=$(wc -l < $FILE) ; ERR_LINES=$(grep -E '^0' $FILE | wc -l) ; echo "scale=2 ; $ERR_LINES*100 / $TOTAL_LINES" | bc)


ARG=""
ARG="$ARG set title 'ARS SteamCode price - generated `date '+%Y-%m-%d %H:%M:%S'`' ;"
ARG="$ARG set ylabel 'EuroCents' ;"
ARG="$ARG set xlabel 'Current price: $CURRENT_PRICE Lowest price: $LOWEST_PRICE Read error rate: ${ERR_RATE}%' ;"
ARG="$ARG set xdata time ;"
ARG="$ARG set timefmt '%Y%m%d-%H%M';"
ARG="$ARG set format x '%Y-%m-%d';"
#ARG="$ARG set autoscale ;"
#ARG="$ARG set yrange [500:] ;"
ARG="$ARG set yrange [0:] ;"
ARG="$ARG set datafile sep ' ';"
ARG="$ARG set key top right autotitle columnheader ;"
ARG="$ARG set grid;"
ARG="$ARG set datafile separator whitespace;"
ARG="$ARG set term png medium size 1200,800;"
ARG="$ARG plot '-' using 1:2 with lines lt 1 lw 2 linecolor rgb 'blue' title 'Price in Eurocents', '-' using 1:3 with lines lt 1 lw 2 linecolor rgb 'red' title 'EUR/ARS'"

CMD="gawk '{ if (\$1 == 0) next; print \$2\" \"\$1\" \"\$3 }' price-log.txt"
(eval $CMD ; echo 'e'; eval $CMD) | cat | docker run --rm -i --name gnuplot toleksa/gnuplot -p -e "$ARG" > /www/files/out.png

