#!/bin/bash

SITE="https://www.eneba.com/steam-steam-wallet-gift-card-1000-ars-key-argentina"

PWD="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
FILE_BEST_PRICE="$PWD/ars-price.txt"
FILE_PRICE_LOG="$PWD/ars-price.txt.log"
ALERT_CMD="$HOME/alert.sh"

which bc > /dev/null 2>&1; RC=$?
if [ "$RC" -ne 0 ]; then
    echo "ERR: no 'bc' found in \$PATH"
    exit 1
fi

# get price
#PRICE=$(curl --silent "$SITE" | grep 'itemProp="price"' | sed -e 's/meta itemProp="price" content="/\n/g' | gawk -F"\"" '{ print $1 }' | grep -Ev '^$' | head -n 2 | tail -n 1 )
PRICE=$(curl --silent "$SITE" \
        | grep 'itemProp="price"' \
        | gawk -F"meta itemProp=\"price\" content=\"" ' { print $2 }' \
        | gawk -F"\"" '{ print $1 }')

PRICE=`echo "($PRICE*100)/1" | bc`

echo "$PRICE `date +%Y%m%d-%H%M`">> $FILE_PRICE_LOG

if [ ! -f "$FILE_BEST_PRICE" ]; then
    echo "$PRICE `date +%Y%m%d-%H%M`"> $FILE_BEST_PRICE
    exit 0
fi

BEST_PRICE=$(tail -n 1 "$FILE_BEST_PRICE" | gawk '{ print $1 }')

if [ "$PRICE" -lt "$BEST_PRICE" ]; then
    "$ALERT_CMD" "better ars price: $PRICE"
    echo "$PRICE `date +%Y%m%d-%H%M`"> $FILE_BEST_PRICE
fi


