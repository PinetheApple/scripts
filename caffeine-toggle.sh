#!/usr/bin/env bash
# Toggle a systemd sleep inhibitor. Blocks suspend from every source
# (hypridle timer, logind, manual) until toggled off.
# The registered inhibitor is the source of truth; the pid file is only a
# breadcrumb, so a cleared /tmp cannot strand a second inhibitor.
PID=/tmp/caffeine.pid

held_by() {
    systemd-inhibit --list --no-legend 2>/dev/null \
        | awk '$1 == "caffeine" && $NF == "block" { print $4; exit }'
}

RUNNING=$(held_by)

if [[ -n $RUNNING ]]; then
    kill "$RUNNING"
    rm -f "$PID"
    notify-send -i preferences-desktop-screensaver "Caffeine off" "Sleep enabled"
else
    systemd-inhibit --what=sleep --who=caffeine --why=manual --mode=block \
        sleep infinity &
    echo $! > "$PID"
    notify-send -i preferences-desktop-screensaver "Caffeine on" "Sleep blocked"
fi
