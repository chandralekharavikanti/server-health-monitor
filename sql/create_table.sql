CREATE TABLE IF NOT EXISTS server_metrics (
    id                 SERIAL PRIMARY KEY,
    collected_at       TIMESTAMP NOT NULL,   -- stored in UTC
    host               TEXT NOT NULL,
    cpu_used_pct       NUMERIC(5,1),
    load_1min          NUMERIC(6,2),
    mem_available_pct  NUMERIC(5,1),
    swap_used_mb       INTEGER,
    disk_used_pct      INTEGER,
    UNIQUE (host, collected_at)
);
