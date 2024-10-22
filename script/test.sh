#!/usr/bin/env bash

base="$(dirname $(realpath $0))"
# import helper functions
. "$base/helper.sh"

# customizabale options
intervalOption="@tmux-weather-interval"
locationOption="@tmux-weather-location"
unitsOption="@tmux-weather-units"

# inner options
weatherValueOption="@tmux-weather-value"
prevUpdateOption="@tmux-weather-prev-update"

if [ "$IPINFO_TOKEN" == "" ] || [ "$OWM_TOKEN" == "" ]; then
    printf "🎃 lack-of-token"
else
    # if there is no internet connection
    if $(! InternetConnected); then
        printf "🌊 no-internet"
        exit 0
    fi

    location=$(get_tmux_option "$locationOption")
    units=$(get_tmux_option "$unitsOption")
    weather=$(getWeather "$location" "$units")
    echo $location, $units, "$weather"
fi
