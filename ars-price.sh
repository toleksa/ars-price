#!/bin/bash

# SETTINGS
SITE="https://www.eneba.com/steam-steam-wallet-gift-card-1000-ars-key-argentina"

# VARS
PWD="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
FILE_BEST_PRICE="$PWD/ars-price.txt"
FILE_PRICE_LOG="$PWD/ars-price.txt.log"
ALERT_CMD="$HOME/alert.sh"

# check if 'bc' is installed
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

# convert Euro to Cents
PRICE=`echo "($PRICE*100)/1" | bc`

# write current PRICE to log
echo "$PRICE `date +%Y%m%d-%H%M`">> $FILE_PRICE_LOG

# if there is no FILE_BEST_PRICE, create with current PRICE and exit
if [ ! -f "$FILE_BEST_PRICE" ]; then
    echo "$PRICE `date +%Y%m%d-%H%M`"> $FILE_BEST_PRICE
    exit 0
fi

# otherwise read BEST_PRICE and compare to current PRICE
BEST_PRICE=$(tail -n 1 "$FILE_BEST_PRICE" | gawk '{ print $1 }')

# if current PRICE is better, save it and send notification
if [ "$PRICE" -lt "$BEST_PRICE" ]; then
    "$ALERT_CMD" "better ars price: $PRICE"
    echo "$PRICE `date +%Y%m%d-%H%M`"> $FILE_BEST_PRICE
fi


