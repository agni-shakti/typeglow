#!/bin/bash
#
# typeglow - Reactive keyboard backlight daemon
# For Samsung Galaxy Book laptops on Linux
#
# Sets keyboard backlight to MAX while typing,
# then fades back to the previous brightness.
#
# Requires: evtest, systemd
# Must be run as root.
DEVICE="/dev/input/event3"
LED="/sys/class/leds/samsung-galaxybook::kbd_backlight/brightness"

MAX=3
STEP_DELAY=0.08
TRIGGER_DELAY=0.15

FADE_PID=""
REST_LEVEL=$(cat "$LED")

fade_to() {
    local from=$1
    local to=$2

    if [ "$from" -gt "$to" ]; then
        for ((i=from-1; i>=to; i--)); do
            echo "$i" > "$LED"
            sleep "$STEP_DELAY"
        done
    elif [ "$from" -lt "$to" ]; then
        for ((i=from+1; i<=to; i++)); do
            echo "$i" > "$LED"
            sleep "$STEP_DELAY"
        done
    fi
}

start_fade() {
    if [ -n "$FADE_PID" ] && kill -0 "$FADE_PID" 2>/dev/null; then
        kill "$FADE_PID"
        wait "$FADE_PID" 2>/dev/null
    fi

    (
        sleep "$TRIGGER_DELAY"
        CURRENT=$(cat "$LED")
        fade_to "$CURRENT" "$REST_LEVEL"
    ) &

    FADE_PID=$!
}

/usr/bin/evtest "$DEVICE" | while read -r line; do
    if echo "$line" | grep -q "EV_KEY.*value 1"; then

        # If fading, cancel it but DO NOT resample brightness
        if [ -n "$FADE_PID" ] && kill -0 "$FADE_PID" 2>/dev/null; then
            kill "$FADE_PID"
            wait "$FADE_PID" 2>/dev/null
        else
            REST_LEVEL=$(cat "$LED")
        fi

        echo "$MAX" > "$LED"
        start_fade
    fi
done
