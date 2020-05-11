#!/usr/bin/env bash

base="$(dirname $(realpath $0))"
. "$base/script/helper.sh"

weatherTag="\#{weather}"
weatherScript="#($base/script/weather.sh)"

replace_tmux_option() {
    local option="$1"
    local value="$(get_tmux_option $option)"
    local replacedValue="${value/$weatherTag/$weatherScript}"
    set_tmux_option "$option" "$replacedValue"
}

main() {
    replace_tmux_option "status-left"
    replace_tmux_option "status-right"
}

main
