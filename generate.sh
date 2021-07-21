#!/bin/bash

cat price-log.txt | gawk '{ print $1 }' | gnuplot -p -e 'set style line 1 lt 1 lw 3 pt 3 linecolor rgb "blue" ; set title "ARS SteamCode price" ; set ylabel "EuroCents" ; set term svg; set output "|rsvg-convert -f png -o out.png /dev/stdin"; plot "/dev/stdin" with lines' && mv out.png /var/www/html/ 

