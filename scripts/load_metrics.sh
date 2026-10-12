#!/bin/bash
# load_metrics.sh - loads rows from metrics.csv into PostgreSQL, skipping duplicates

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
CSV_FILE="$PROJECT_DIR/data/metrics.csv"
DB_NAME="server_health"

# Stop early if there's no data file
if [ ! -f "$CSV_FILE" ]; then
    echo "$(date '+%Y-%m-%d %H:%M:%S') ERROR: $CSV_FILE not found"
    exit 1
fi

psql "$DB_NAME" -v ON_ERROR_STOP=1 <<EOF
CREATE TEMP TABLE staging (
    collected_at       TIMESTAMP,
    host               TEXT,
    cpu_used_pct       NUMERIC,
    load_1min          NUMERIC,
    mem_available_pct  NUMERIC,
    swap_used_mb       INTEGER,
    disk_used_pct      INTEGER
);

\copy staging FROM '$CSV_FILE' WITH (FORMAT csv, HEADER true)

INSERT INTO server_metrics
    (collected_at, host, cpu_used_pct, load_1min, mem_available_pct, swap_used_mb, disk_used_pct)
SELECT * FROM staging
ON CONFLICT (host, collected_at) DO NOTHING;
EOF
