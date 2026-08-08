#!/usr/bin/env bash
# Start makima from the Hyprland session so it inherits WAYLAND_DISPLAY directly,
# instead of the system unit restart-looping until a session happens to exist.
# Idempotent: does nothing if the system unit is still enabled and running.
set -uo pipefail

pgrep -x makima >/dev/null && exit 0

export MAKIMA_CONFIG="$HOME/.config/makima"
exec /usr/bin/makima
