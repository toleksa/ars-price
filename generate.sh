#!/bin/bash

# check if 'gnuplot' is installed
which gnuplot > /dev/null 2>&1; RC=$?
if [ "$RC" -ne 0 ]; then
    echo "ERR: no 'gnuplot' found in \$PATH"
    exit 1
fi

# check if 'rsvg-convert' is installed
which rsvg-convert > /dev/null 2>&1; RC=$?
if [ "$RC" -ne 0 ]; then
    echo "ERR: no 'rsvg-convert' found in \$PATH"
    exit 1
fi

cat price-log.txt | gawk '{ print $1 }' | gnuplot -p -e 'set style line 1 lt 1 lw 3 pt 3 linecolor rgb "blue" ; set title "ARS SteamCode price" ; set ylabel "EuroCents" ; set term svg; set output "|rsvg-convert -f png -o out.png /dev/stdin"; plot "/dev/stdin" with lines' && chcon -t httpd_sys_content_t out.png && mv out.png /var/www/html/ 

