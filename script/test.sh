#!/usr/bin/env bash

base="$(dirname $(realpath $0))"
# import helper functions
. "$base/helper.sh"

if [ "$IPINFO_TOKEN" == "" ] || [ "$OWM_TOKEN" == "" ]; then
    printf "🎃 lack-of-token"
# if there is no internet connection
elif $(! nc -dzw1 8.8.8.8 443); then
    printf "🌊 no-internet"

else
    getWeather
fi
