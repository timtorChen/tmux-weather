#!/usr/bin/env bash

pluginFolder="$(realpath ~/.tmux/plugins/tmux-weather)"
cacheFile="$pluginFolder/cache"

getWeather() {
    city=$(curl -s "https://ipinfo.io?token=$IPINFO_TOKEN" | jq -r ".city")
    weatherJSON=$(curl -s "https://api.openweathermap.org/data/2.5/weather?units=metric&q=$city&appid=$OWM_TOKEN")
    weatherCode=$(printf "$weatherJSON" | jq -r ".weather | .[0] | .id")
    temperature=$(printf "$weatherJSON" | jq -r ".main.temp")
    sunrise=$(printf "$weatherJSON" | jq -r ".sys.sunrise")
    sunset=$(printf "$weatherJSON" | jq -r ".sys.sunset")
    now=$(date -u +%s)
    echo $now

    # openWeatherMap weather code: https://openweathermap.org/weather-conditions
    awkScript='
        function getMoonEmoji(){
            moonCycle = 2551392           # moon period: 29.53 days, in seconds
            historicalNewMoon = 592500    # 1970-01-07T20:35 
            deltaPhase= now - historicalNewMoon
            currentIntPhase= int((deltaPhase % moonCycle) / moonCycle * 100)
            
            if ( currentIntPhase==0 )
                return "🌑"     # new Moon

            else if ( currentIntPhase>0 && currentIntPhase<25 )
                return "🌒"     # waxing cresent 

            else if ( currentIntPhase==25 )
                return "🌓"     # first quator 

            else if ( currentIntPhase>25 && currentIntPhase<50 )
                return "🌔"     # waxing gibbous     

            else if ( currentIntPhase==50 )
                return "🌕"     # full moon

            else if ( currentIntPhase>50 && currentIntPhase<75 )
                return "🌖"     # waning moon

            else if ( currentIntPhase==75 )
                return "🌗"     # last quator

            else if ( currentIntPhase>75 && currentIntPhase<100 )
                return "🌘"     # waning moon
        }

        function getWeatherEmoji() {
            if (code >= 210 && code <=221)
            # thunderstorm
                return "🌩"        
            
            else if ( (code >= 200 && code <= 202) \
              || (code >= 230 && code <= 232))
            # thunderstorm with rain
                return "⛈"        
            
            else if (code >= 300 && code <= 321)
            # drizzle 
                return "🌧"
            
            else if (code >= 500 && code <= 531)
            # rain
                return "🌧"
            
            else if (code >= 600 && code<=622)
            # snow
                return "❄️"

            else if (code == 701 || code == 711 || code == 721 || code == 741)
            # mist, smoke, fog, haze ...
                return "🌫"

            else if (code == 781)
            # typhoon
                return "🌀"

            else if (code == 800)
            # clear sky
                return "☀"
            
            else if (code == 801)
            # clouds: 11%-25%
                return "🌤"

            else if (code == 802 || code == 803)
            # clouds: 25%-50% 
            # clouds: 51%-84%
                return "🌥"
            
            else if ( code == 804)
            # clouds: 85%-100%
                return "☁"

        }

        BEGIN {
            emoji=getWeatherEmoji()
            if ( emoji == "☀" || emoji == "🌤" || emoji == "🌥" )
                emoji=getMoonEmoji()

            print emoji
        }
    '
    emoji=$(awk -v code="$weatherCode" \
        -v sunrise="$sunrise" -v sunset="$sunset" -v now="$now" \
        "$awkScript")

    width=$(wc -L <<< $emoji)
    prefix=$((3 - $width))
    printf "%s" $emoji
    printf "%*s" $prefix ""
    printf "%.0f°C" $temperature
}

if [ "$IPINFO_TOKEN" ] && [ "$OWM_TOKEN" ]; then
    exptime="900" # 900 second, 15 minutes
    now=$(date -u +%s)

    # if there is such file, and if cache is expired, make a request and update the cache
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

else
    printf "🎃 lack-of-token"
fi
