#!/bin/bash
# collect_metrics.sh - collects basic server health metrics and appends them to a CSV file

# Locate the project folder (works no matter where the script is run from)
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
DATA_DIR="$PROJECT_DIR/data"
CSV_FILE="$DATA_DIR/metrics.csv"

mkdir -p "$DATA_DIR"

# Write the header once, only if the file doesn't exist yet
if [ ! -f "$CSV_FILE" ]; then
    echo "timestamp,host,cpu_used_pct,load_1min,mem_available_pct,swap_used_mb,disk_used_pct" > "$CSV_FILE"
fi

timestamp=$(date '+%Y-%m-%d %H:%M:%S')
host=$(hostname)
cpu_used_pct=$(vmstat 1 2 | tail -1 | awk '{print 100 - $15}')
load_1min=$(awk '{print $1}' /proc/loadavg)
mem_available_pct=$(free -m | awk '/^Mem:/ {printf "%.1f", $7/$2*100}')
swap_used_mb=$(free -m | awk '/^Swap:/ {print $3}')
disk_used_pct=$(df / --output=pcent | tail -1 | tr -d ' %')

echo "$timestamp,$host,$cpu_used_pct,$load_1min,$mem_available_pct,$swap_used_mb,$disk_used_pct" >> "$CSV_FILE"
