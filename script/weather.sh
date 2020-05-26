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

# if ipinfo token or openweathermap token is not set
if [ "$IPINFO_TOKEN" = "" ] || [ "$OWM_TOKEN" = "" ]; then
    printf "🎃 lack-of-token"
else
    # get previous update time, the default value is 0
    prevUpdate=$(get_tmux_option "$prevUpdateOption" 0)
    now=$(date -u +%s)
    delta=$(("$now" - "$prevUpdate"))
    # get update interval, the default value is 15
    interval=$(get_tmux_option "$intervalOption" 15)
    expiration=$(("$interval" * 60))

    if [ "$delta" -ge "$expiration" ]; then
        units=$(get_tmux_option "$unitsOption")
        location=$(get_tmux_option "$locationOption")
        
        # if there is no internet connection
        if $(! InternetConnected); then
            printf "🌊 no-internet"
            exit 0
        fi

        weather=$(getWeather "$location" "$units")
        set_tmux_option "$weatherValueOption" "$weather"
        set_tmux_option "$prevUpdateOption" "$now"
    fi

    printf "$(get_tmux_option "$weatherValueOption")"
fi
