#!/bin/bash
awk '/MemTotal/ {total=$2} /MemAvailable/ {avail=$2} END {printf "💾 %.2f GiB\n", (total - avail)/1048576}' /proc/meminfo