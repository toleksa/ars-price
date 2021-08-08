#!/bin/bash

ARG=""
ARG="$ARG set style line 1 lt 1 lw 3 pt 3 linecolor rgb 'blue' ;"
ARG="$ARG set title 'ARS SteamCode price - `date +%Y%m%d-%H:%M:%S`' ;"
ARG="$ARG set ylabel 'EuroCents' ;"
ARG="$ARG set term png size 1200,800;"
ARG="$ARG plot '/dev/stdin' with lines"

gawk '{ print $1 }' price-log.txt | docker run -i --name gnuplot jess/gnuplot -p -e "$ARG" > /www/files/out.png
docker rm gnuplot

