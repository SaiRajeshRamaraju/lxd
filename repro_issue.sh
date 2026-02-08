#!/bin/bash
set -e
NETWORK_NAME=testbr0

# Ensure clean state
lxc network delete $NETWORK_NAME 2>/dev/null || true

echo "Starting network creation (simulate interrupt)..."
# Start creation in background and kill it immediately to simulate Ctrl+C
lxc network create $NETWORK_NAME ipv4.address=192.1.2.2/24 ipv4.nat=true &
PID=$!
sleep 0.2
echo "Sending SIGINT to $PID"
kill -INT $PID
wait $PID 2>/dev/null || true

echo "Checking network state..."
if lxc network ls | grep -q "$NETWORK_NAME"; then
    echo "FAIL: Network record still exists."
    lxc network ls | grep "$NETWORK_NAME"
    # Cleanup
    lxc network delete $NETWORK_NAME
    exit 1
else
    echo "PASS: Network record was cleaned up."
fi
