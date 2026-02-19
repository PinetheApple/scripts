#!/bin/bash
# Script to hide unused applications from the application menu

HIDE_LIST=(
    "avahi-discover.desktop" "bssh.desktop" "bvnc.desktop"
    "antigravity-url-handler.desktop" "openjdk-21-java.desktop" "openjdk-21-jconsole.desktop"
    "openjdk-21-jshell.desktop" "qv4l2.desktop" "qvidcap.desktop" "xgps.desktop"
    "xgpsspeed.desktop" "electron37.desktop" "nvim.desktop" "vim.desktop"
    "btop.desktop" "kvantummanager.desktop" "qt5ct.desktop" "qt6ct.desktop"
    "nwg-look.desktop" "rofi-theme-selector.desktop" "nvidia-settings.desktop"
    "google-maps-geo-handler.desktop" "openstreetmap-geo-handler.desktop"
    "wheelmap-geo-handler.desktop" "org.gnome.Zenity.desktop" "org.gnome.seahorse.Application.desktop" "java-java21-openjdk.desktop" "jconsole-java21-openjdk.desktop"
	"jshell-java21-openjdk.desktop" "sh.natty.Wleave.desktop" "rofi.desktop"
	"kitty-open.desktop" "kitty.desktop" "nm-connection-editor.desktop"
)

mkdir -p ~/.local/share/applications

for app in "${HIDE_LIST[@]}"; do
    TARGET="$HOME/.local/share/applications/$app"
    SOURCE="/usr/share/applications/$app"

    if [ ! -f "$TARGET" ] && [ -f "$SOURCE" ]; then
        cp "$SOURCE" "$TARGET"
    fi

    if [ -f "$TARGET" ]; then
        if grep -q "NoDisplay=true" "$TARGET"; then
            echo "Skipping: $app (Already hidden)"
        elif grep -q "NoDisplay=false" "$TARGET"; then
            sed -i 's/NoDisplay=false/NoDisplay=true/' "$TARGET"
            echo "Updated: $app (Set NoDisplay to true)"
        else
            echo "NoDisplay=true" >> "$TARGET"
            echo "Hidden: $app (Added NoDisplay line)"
        fi
    fi
done

rm -f ~/.cache/rofi-*.cache
echo "Done! Refresh your Rofi menu."
