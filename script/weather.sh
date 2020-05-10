#!/usr/bin/env bash

base="$(dirname $(realpath $0))"
# import helper functions
. "$base/helper.sh"

pluginFolder="$(realpath ~/.tmux/plugins/tmux-weather)"
cacheFile="$pluginFolder/cache"

# if ipinfo token or openweathermap token is not set
if [ "$IPINFO_TOKEN" == "" ] || [ "$OWM_TOKEN" == "" ]; then
    printf "🎃 lack-of-token"
# if there is no internet connection
elif $( ! nc -dzw1 8.8.8.8 443); then
    printf "🌊 no-internet"
else
    exptime="900" # 900 second, 15 minutes
    now=$(date -u +%s)

    #  if there is such file, and if cache is expired, make a request and update the cache
    if [ -f "$cacheFile" ]; then
        lastmod=$(date -r $cacheFile +%s)
        delta=$(($now - $lastmod))
        if [ $delta -gt $exptime ]; then
            weather=$(getWeather)
            echo "$weather" >"$cacheFile"
        fi
    # if there is no such file, make a request and create the cache
    else
        weather=$(getWeather)
        echo "$weather" >"$cacheFile"
    fi

    # simply show the weather in cache
    cat "$cacheFile"
fi
