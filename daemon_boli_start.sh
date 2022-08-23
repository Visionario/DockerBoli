#!/bin/sh
set -e
echo "Starting bolivarcoind forcing -daemon=0"
exec bolivarcoind -daemon=0
