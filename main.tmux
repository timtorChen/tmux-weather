#!/usr/bin/env bash

base="$(dirname $(realpath $0))"

weatherTag="\#{weather}"
weatherScript="$base/script/weather.sh"

replace_tmux_option() {
    local option="$1"
    local value="$(tmux show -gqv $option)"
    local replacedValue="${value/$weatherTag/"#($weatherScript)"}"
    tmux set -gq "$option" "$replacedValue"
}

main() {
    replace_tmux_option "status-left"
    replace_tmux_option "status-right"
}

main
