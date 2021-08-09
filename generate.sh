#!/bin/bash

ARG=""
ARG="$ARG set title 'ARS SteamCode price - generated `date '+%Y-%m-%d %H:%M:%S'`' ;"
ARG="$ARG set ylabel 'EuroCents' ;"
#ARG="$ARG set xlabel 'Timeline' ;"
ARG="$ARG set xdata time ;"
ARG="$ARG set timefmt '%Y%m%d-%H%M';"
ARG="$ARG set format x '%Y-%m-%d';"
ARG="$ARG set autoscale ;"
#ARG="$ARG set yrange [500:] ;"
ARG="$ARG set datafile sep ' ';"
ARG="$ARG set key top right autotitle columnheader ;"
ARG="$ARG set grid;"
ARG="$ARG set term png size 1200,800;"
ARG="$ARG plot '/dev/stdin' using 1:2 with lines lt 1 lw 2 linecolor rgb 'blue' title 'Price in Eurocents'"

# using https://hub.docker.com/r/jess/gnuplot
gawk '{ if ($1 == 0) next; print $2" "$1 }' price-log.txt | docker run -i --name gnuplot jess/gnuplot -p -e "$ARG" > /www/files/out.png
docker rm gnuplot

