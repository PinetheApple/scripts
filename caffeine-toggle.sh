#!/usr/bin/env bash
# Toggle a systemd sleep inhibitor. Blocks suspend from every source
# (hypridle timer, logind, manual) until toggled off.
PID=/tmp/caffeine.pid

if [[ -f $PID ]] && kill -0 "$(cat "$PID")" 2>/dev/null; then
    kill "$(cat "$PID")"
    rm -f "$PID"
    notify-send -i preferences-desktop-screensaver "Caffeine off" "Sleep enabled"
else
    systemd-inhibit --what=sleep --who=caffeine --why=manual --mode=block \
        sleep infinity &
    echo $! > "$PID"
    notify-send -i preferences-desktop-screensaver "Caffeine on" "Sleep blocked"
fi
