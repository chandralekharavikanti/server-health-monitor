#!/bin/bash
# check_alerts.sh - checks the latest reading against thresholds and logs warnings

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
ALERT_LOG="$PROJECT_DIR/logs/alerts.log"
DB_NAME="server_health"

# Thresholds (can be overridden when running the script)
CPU_MAX=${CPU_MAX:-80}       # alert if CPU used % is above this
MEM_MIN=${MEM_MIN:-15}       # alert if memory available % is below this
DISK_MAX=${DISK_MAX:-85}     # alert if disk used % is above this
SWAP_MAX=${SWAP_MAX:-500}    # alert if swap used (MB) is above this

mkdir -p "$(dirname "$ALERT_LOG")"

# Get the most recent reading
row=$(psql "$DB_NAME" -At -F',' -c \
  "SELECT collected_at, cpu_used_pct, mem_available_pct, disk_used_pct, swap_used_mb
   FROM server_metrics ORDER BY collected_at DESC LIMIT 1;")

if [ -z "$row" ]; then
    echo "$(date '+%Y-%m-%d %H:%M:%S') ERROR: no data found" >> "$ALERT_LOG"
    exit 1
fi

IFS=',' read -r ts cpu mem disk swap <<< "$row"

# Helpers: bash can't compare decimals, so awk does it
is_greater() { awk -v a="$1" -v b="$2" 'BEGIN {exit !(a > b)}'; }
alert()      { echo "$ts WARNING: $1" >> "$ALERT_LOG"; }

is_greater "$cpu"     "$CPU_MAX"  && alert "CPU usage ${cpu}% (limit ${CPU_MAX}%)"
is_greater "$MEM_MIN" "$mem"      && alert "Memory available ${mem}% (minimum ${MEM_MIN}%)"
is_greater "$disk"    "$DISK_MAX" && alert "Disk usage ${disk}% (limit ${DISK_MAX}%)"
is_greater "$swap"    "$SWAP_MAX" && alert "Swap used ${swap} MB (limit ${SWAP_MAX} MB)"

exit 0
