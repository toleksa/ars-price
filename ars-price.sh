#!/bin/bash

FILE=$HOME/ars-price/ars-price.txt

PRICE=$(curl --silent https://www.eneba.com/steam-steam-wallet-gift-card-1000-ars-key-argentina | grep 'itemProp="price"' | sed -e 's/meta itemProp="price" content="/\n/g' | gawk -F"\"" '{ print $1 }' | grep -Ev '^$' | head -n 2 | tail -n 1 )

PRICE=`echo "($PRICE*100)/1" | bc`

echo "$PRICE `date +%Y%m%d-%H%M`">> $FILE.log

if [ ! -f "$FILE" ]; then
    echo "$PRICE `date +%Y%m%d-%H%M`"> $FILE
    exit 0
fi

BEST_PRICE=$(tail -n 1 $FILE | gawk '{ print $1 }')

if [ $PRICE -lt $BEST_PRICE ]; then
    /root/alert.sh "better ars price: $PRICE"
    echo "$PRICE `date +%Y%m%d-%H%M`"> $FILE
fi


