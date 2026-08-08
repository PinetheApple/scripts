#!/usr/bin/env bash
# Capture keyboard-input state when Enter misbehaves in rofi/wofi.
# Run it WHILE the bug is happening; it tells you which layer is broken.
set -uo pipefail

out="${1:-$HOME/kbd-diag-$(date +%Y%m%d-%H%M%S).log}"
exec > >(tee "$out") 2>&1

echo "=== $(date -Is) | boot $(cat /proc/sys/kernel/random/boot_id) ==="

echo; echo "=== makima ==="
systemctl status makima.service --no-pager | head -12
journalctl -b -u makima --no-pager | tail -20

echo; echo "=== hyprland keyboards ==="
hyprctl devices | sed -n '/^Keyboards:/,/^Tablets:/p'
for o in input:kb_layout input:kb_variant input:kb_options; do
    printf '%s = ' "$o"; hyprctl getoption "$o" | head -1
done

echo; echo "=== virtual keyboard clients (can hijack the seat keymap) ==="
pgrep -af 'ydotoold|wtype|makima|openwhispr|wl-kbptr' || echo none

echo; echo "=== STEP 1: raw scancode from the hardware ==="
for dev in "AT Translated Set 2 keyboard" "ITE Tech. Inc. ITE Device(8258) Keyboard"; do
    node=$(grep -A5 "Name=\"$dev\"" /proc/bus/input/devices | grep -o 'event[0-9]*' | head -1)
    [ -n "$node" ] || continue
    echo "--- $dev (/dev/input/$node) ---"
    echo "Press ENTER three times, then wait (5s)."
    sudo timeout 5 evtest "/dev/input/$node" 2>/dev/null | grep -E 'EV_KEY.*(ENTER|SPACE)' || echo "(no events - device is grabbed or not the one you type on)"
done

echo; echo "=== STEP 2: keysym the compositor sends to clients ==="
echo "A wev window opens. Press ENTER three times, then close it."
timeout 15 wev 2>/dev/null | grep -A2 -E 'key (pressed|released)' | grep -E 'sym|utf8'

echo; echo "=== Hyprland log tail ==="
tail -40 /run/user/"$(id -u)"/hypr/*/hyprland.log 2>/dev/null

echo; echo "=== DONE -> $out ==="
echo "Reading it:"
echo "  STEP 1 shows KEY_ENTER but STEP 2 shows 'space' -> seat keymap is corrupted."
echo "     Fix without rebooting:  hyprctl reload"
echo "     If that fails:          systemctl restart makima"
echo "  STEP 1 shows KEY_SPACE -> something upstream injects the wrong scancode (makima/ydotool)."
echo "  Both show Return but rofi still types a space -> rofi 2.0 bug, file upstream."
