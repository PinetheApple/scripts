#!/usr/bin/env bash
# Emit caffeine (sleep-inhibitor) state as JSON for the wayle custom module.
# State is read back from logind rather than a pid file, so the icon cannot
# claim protection that is not actually registered.
# Icons via Nerd Font codepoints: coffee (U+F0F4)=blocked, moon (U+F186)=allowed.

if systemd-inhibit --list --no-legend 2>/dev/null \
    | awk '$1 == "caffeine" && $NF == "block" { found = 1 } END { exit !found }'; then
    printf '{"text":"","alt":"on"}\n'
else
    printf '{"text":"","alt":"off"}\n'
fi
