#!/bin/sh
PID_FILE="/tmp/octoprint.pid"

if [ -f "$PID_FILE" ]; then
    PID="$(cat "$PID_FILE" 2>/dev/null)"
    if [ -n "$PID" ]; then
        echo "[restart-octoprint] Restarting OctoPrint (PID: $PID)..."
        kill -TERM "$PID" 2>/dev/null || true
    fi
else
    echo "[restart-octoprint] PID file not found, searching process..."
    kill -TERM "$(pgrep -f "octoprint.*serve" 2>/dev/null)" 2>/dev/null || true
fi
