#!/usr/bin/env bash
# Route wayle notification popups to the focused Hyprland monitor.
# Listens to Hyprland's focusedmon events and updates popup-monitor live
# (wayle hot-reloads the config setting).
set -euo pipefail

SOCK="$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock"

set_mon() {
    [[ -n $1 ]] && wayle config set modules.notifications.popup-monitor "$1" >/dev/null 2>&1
}

# Initial sync to whichever monitor is focused now.
set_mon "$(hyprctl monitors -j | jq -r '.[] | select(.focused) | .name')"

socat -U - "UNIX-CONNECT:$SOCK" | while IFS= read -r line; do
    case $line in
        focusedmon\>\>*)
            mon=${line#focusedmon>>}
            set_mon "${mon%%,*}"
            ;;
    esac
done
