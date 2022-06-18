#!/bin/bash

# SETTINGS
SITE="https://www.eneba.com/steam-steam-wallet-gift-card-1000-ars-key-argentina"

# VARS
PWD="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
FILE_BEST_PRICE="$PWD/best-price.txt"
FILE_PRICE_LOG="$PWD/price-log.txt"
ALERT_CMD="/root/alert.sh"

# check if 'bc' is installed
which bc > /dev/null 2>&1; RC=$?
if [ "$RC" -ne 0 ]; then
    echo "ERR: no 'bc' found in \$PATH"
    exit 1
fi

EURARS_TEMP=$(curl --silent -A 'Mozilla/5.0 (MSIE; Windows 10)' -L "https://www.google.com/search?q=1000+ars+to+eur" | gawk -F"data-value" '{ print $2 }' | gawk -F"</span>" '{ print $1 }' | gawk -F">" '{ print $2 }' | sed -e 's/\.//g' | xargs)
EURARS=$EURARS_TEMP
if [ "$EURARS" == '' ]; then
    PRICE=0
fi

PRICE=$(curl --silent -A 'Mozilla/5.0 (MSIE; Windows 10)' -L "$SITE" | sed -e 's/div/\n/g' | grep -i "lowest price" | grep "€" | gawk -F"€" '{ print $2 }' | gawk -F"<" '{ print $1 }')
#PRICE=$(curl --silent "$SITE" | sed -e 's/>/\n/g' | grep -e "^€" | gawk -F"<" '{ print $1 }' | gawk -F"€" '{ print $2 }' | sort -n | head -n 1)
# 20220302 - below stopped working
#PRICE=$(curl --silent "$SITE" | grep 'itemProp="price"' | sed -e 's/meta itemProp="price" content="/\n/g' | gawk -F"\"" '{ print $1 }' | grep -Ev '^$' | head -n 2 | tail -n 1 )
# get price #20210808 - second method seems to generate sometimes two numbers, failback to first method
#PRICE=$(curl --silent "$SITE" \
#        | grep 'itemProp="price"' \
#        | gawk -F"meta itemProp=\"price\" content=\"" ' { print $2 }' \
#        | gawk -F"\"" '{ print $1 }')

# change empty to 0, because empty/no value breaks chart generator
if [ "$PRICE" == '' ]; then
    PRICE=$(curl --silent -A 'Mozilla/5.0 (MSIE; Windows 10)' -L "$SITE" | sed -e 's/div/\n/g' | grep -i "lowest price" | grep "€" | gawk -F"€" '{ print $2 }' | gawk -F"<" '{ print $1 }')
    if [ "$PRICE" == '' ]; then
        PRICE=0
    fi
fi 

# convert Euro to Cents
PRICE=`echo "($PRICE*100)/1" | bc`

# write current PRICE to log
echo "$PRICE `date +%Y%m%d-%H%M` $EURARS">> $FILE_PRICE_LOG

if [ -x "$PWD/generate.sh" ]; then
    cd "$PWD" && ./generate.sh
    cd -
fi

# 0 means bad reading, so don't update best-price
if [ "$PRICE" -eq 0 ]; then
    exit 0
fi

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

