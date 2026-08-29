#!/usr/bin/env bash
# Emit the number of open Hyprland windows as JSON for the wayle custom module,
# so occupancy is visible without switching workspaces. The tooltip breaks the
# count down per workspace.

clients=$(hyprctl clients -j 2>/dev/null) || clients='[]'

count=$(jq 'length' <<<"$clients")
tooltip=$(jq -r '
    if length == 0 then "No open windows"
    else
        group_by(.workspace.id)
        | map("Workspace \(.[0].workspace.id): " + (map(.class) | join(", ")))
        | join("\n")
    end' <<<"$clients")

if [[ $count -gt 0 ]]; then
    alt=open
else
    alt=none
fi

jq -nc --arg text "$count" --arg alt "$alt" --arg tooltip "$tooltip" \
    '{text: $text, alt: $alt, tooltip: $tooltip}'
