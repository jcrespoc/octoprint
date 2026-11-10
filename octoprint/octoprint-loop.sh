#!/bin/bash

PID_FILE="/tmp/octoprint.pid"

# Handle container termination signals from Docker (SIGTERM / SIGINT)
shutdown() {
    echo "[octoprint-loop] Received Docker shutdown signal. Stopping OctoPrint..."
    if [ -n "$OCTO_PID" ]; then
        kill -TERM "$OCTO_PID" 2>/dev/null
        wait "$OCTO_PID" 2>/dev/null
    fi
    rm -f "$PID_FILE"
    exit 0
}

trap shutdown SIGTERM SIGINT

echo "[octoprint-loop] Starting OctoPrint supervisor loop..."
while true; do
    octoprint serve --basedir /octoprint/octoprint --host 0.0.0.0 --port 5000 &
    OCTO_PID=$!
    echo "$OCTO_PID" > "$PID_FILE"
    wait "$OCTO_PID"
    EXIT_CODE=$?
    rm -f "$PID_FILE"
    echo "[octoprint-loop] OctoPrint exited with code $EXIT_CODE. Restarting in 1s..."
    sleep 1
done
