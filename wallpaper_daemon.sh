#!/bin/bash

DESKTOP="PATH to desktop image"
LOCK="PATH to lockscreen image"
LOG="$HOME/wallpaper_daemon.log"

echo "====================" >> "$LOG"
echo "[START] $(date)" >> "$LOG"

set_wallpaper() {
    local img="$1"

    echo "[CALL] set_wallpaper -> $img" >> "$LOG"

    /usr/bin/osascript <<EOF >> "$LOG" 2>&1
tell application "System Events"
    set picture of every desktop to "$img"
end tell
EOF

    echo "[DONE] osascript executed for $img" >> "$LOG"
}

LAST_STATE="unknown"

echo "[INIT] daemon started" >> "$LOG"

while true; do

    RAW=$(ioreg -n Root -d1 2>/dev/null)

    if echo "$RAW" | grep -q "CGSSessionScreenIsLocked.*Yes"; then
        STATE="locked"
    else
        STATE="unlocked"
    fi

    if [ "$STATE" != "$LAST_STATE" ]; then
        echo "[EVENT] $STATE at $(date)" >> "$LOG"

        if [ "$STATE" = "locked" ]; then
            set_wallpaper "$LOCK"
        else
            set_wallpaper "$DESKTOP"
        fi

        LAST_STATE="$STATE"
    fi

    sleep 1
done
