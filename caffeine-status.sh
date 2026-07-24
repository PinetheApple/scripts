#!/usr/bin/env bash
# Emit caffeine (sleep-inhibitor) state as JSON for the wayle custom module.
# Icons via Nerd Font codepoints: coffee (U+F0F4)=blocked, moon (U+F186)=allowed.
PID=/tmp/caffeine.pid

if [[ -f $PID ]] && kill -0 "$(cat "$PID")" 2>/dev/null; then
    printf '{"text":"","alt":"on"}\n'
else
    printf '{"text":"","alt":"off"}\n'
fi
