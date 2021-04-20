#!/bin/sh
# Nika Chkhikvishvili
# Georgian Names - Dictionary Generator
# This Script fetches names in Georgian, urlencodes, and converts them in latin, using publicly available services.


# disable perl warnings:
export LANGUAGE=en_US.UTF-8
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8


# how many names
for name in {1..1000}; do

encoded_name=$(curl -s "http://kids.ge/baby-name?id=$name" |grep -Po "(?<=\<title\>).*(?=\ \-)" | awk '{print $1}')

curl -s 'https://fonts.ge/ka/converter/' -H 'Connection: keep-alive' -H 'Cache-Control: max-age=0' -H 'Origin: https://fonts.ge' -H 'Upgrade-Insecure-Requests: 1' -H 'Content-Type: application/x-www-form-urlencoded' -H 'User-Agent: Mozilla/5.0' --data "convert=convert&in=utf8&out=lat1&text=$encoded_name" --compressed | grep "<td class=box4row1>" | grep -Po "nDblClick\=this\.select\(\)\>.*" |sed -e "s/\/textarea.*//g" |cut -d \< -f1 | cut -d \> -f2; done

