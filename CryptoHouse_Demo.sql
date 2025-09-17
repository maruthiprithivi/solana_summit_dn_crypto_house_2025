-- ClickHouse Demo Queries for Solana Summit
-- Author: Maruthi
-- Date: June 2025
-- Description: Optimized queries demonstrating ClickHouse capabilities for Solana blockchain analytics

-- ============================================================================
-- QUERY 1: Data Scale Overview
-- Purpose: Show the scale of data we're analyzing
-- ============================================================================
SELECT 
    formatReadableQuantity(count()) as estimated_total_transactions,
    max(block_timestamp) as latest_data,
    min(block_timestamp) as earliest_data,
    dateDiff('day', min(block_timestamp), max(block_timestamp)) as days_of_data
FROM solana.transactions;

-- ============================================================================
-- QUERY 1.1: Data Size Overview
-- Purpose: Show the size and compression ratio of data we're analyzing
-- ============================================================================

SELECT
    database,
    name AS table,
    formatReadableSize(total_bytes) AS compressed_bytes,
    formatReadableSize(total_bytes_uncompressed) AS uncompressed_bytes
FROM system.tables
WHERE database = 'solana' AND name = 'transactions';


-- ============================================================================
-- QUERY 2: Network Health Monitoring
-- Purpose: Real-time network health metrics for validators and dApp developers
-- Optimization: PREWHERE for efficient filtering
-- ============================================================================
SELECT 
    toStartOfHour(block_timestamp) as hour,
    countIf(status = '1') as successful_txns,
    countIf(status != '1') as failed_txns,
    round(countIf(status = '1') * 100.0 / count(), 2) as success_rate
FROM solana.transactions
PREWHERE block_timestamp >= '2025-05-20 00:00:00'  -- PREWHERE filters before reading all columns
WHERE block_timestamp <= '2025-05-20 20:00:51'
GROUP BY hour
ORDER BY hour DESC
LIMIT 24;

-- ============================================================================
-- QUERY 3: Top Programs by Usage
-- Purpose: Identify most active programs and their resource consumption
-- Optimization: CTE with limited data scan
-- ============================================================================
WITH recent_txns AS (
    SELECT 
        accounts[1].1 as program_id,
        fee,
        compute_units_consumed
    FROM solana.transactions
    PREWHERE block_timestamp >= '2025-05-20 12:00:00'  -- Last 8 hours
    WHERE block_timestamp <= '2025-05-20 20:00:51'
        AND length(accounts) > 0
    LIMIT 1000000  -- Cap for demo performance
)
SELECT 
    program_id,
    count() as tx_count,
    avg(fee / 1e9) as avg_fee_sol,
    sum(fee / 1e9) as total_fees_sol,
    avg(compute_units_consumed) as avg_compute_units
FROM recent_txns
GROUP BY program_id
ORDER BY tx_count DESC
LIMIT 10;

-- ============================================================================
-- QUERY 4: Token Transfer Analytics
-- Purpose: Analyze token velocity and distribution
-- Optimization: Pre-filtered JOINs
-- ============================================================================
WITH active_tokens AS (
    SELECT DISTINCT mint
    FROM solana.token_transfers
    PREWHERE block_timestamp >= '2025-05-20 00:00:00'
    LIMIT 10000
),
token_info AS (
    SELECT 
        mint,
        any(symbol) as symbol,
        any(name) as name
    FROM solana.tokens
    WHERE mint IN (SELECT mint FROM active_tokens)
    GROUP BY mint
)
SELECT 
    ti.symbol,
    ti.name,
    count() as transfer_count,
    uniq(tt.source) as unique_senders,
    sum(tt.value / pow(10, toFloat64(tt.decimals))) as total_volume
FROM solana.token_transfers tt
INNER JOIN token_info ti ON tt.mint = ti.mint
PREWHERE tt.block_timestamp >= '2025-05-20 00:00:00'
WHERE tt.block_timestamp <= '2025-05-20 20:00:51'
GROUP BY ti.symbol, ti.name
HAVING transfer_count > 10
ORDER BY transfer_count DESC
LIMIT 20;

-- ============================================================================
-- QUERY 5: Whale Movement Detection
-- Purpose: Track large value transfers in real-time
-- Optimization: PREWHERE with value threshold
-- ============================================================================
SELECT 
    block_timestamp,
    source,
    destination,
    value / pow(10, toFloat64(decimals)) as amount_tokens,
    mint,
    substring(tx_signature, 1, 16) as tx_sig_short  -- Reduce data transfer
FROM solana.token_transfers
PREWHERE value > 100000000000  -- High value filter
    AND block_timestamp >= '2025-05-20 18:00:00'  -- Last 2 hours
WHERE block_timestamp <= '2025-05-20 20:00:51'
ORDER BY value DESC
LIMIT 10;

-- Running the query with indexes=1 to see the query plan and undestand why ClickHouse is Fast while being cost efficiecnt 
EXPLAIN indexes=1 SELECT 
    block_timestamp,
    source,
    destination,
    value / pow(10, toFloat64(decimals)) as amount_tokens,
    mint,
    substring(tx_signature, 1, 16) as tx_sig_short  -- Reduce data transfer
FROM solana.token_transfers
PREWHERE value > 100000000000  -- High value filter
    AND block_timestamp >= '2025-05-20 00:00:00'  -- Last 10 hours
WHERE block_timestamp <= '2025-05-20 20:00:51'
ORDER BY value DESC
LIMIT 10;

-- ============================================================================
-- QUERY 6: Account Balance Flow Analysis
-- Purpose: Track SOL flow through the network
-- ============================================================================
WITH sampled_changes AS (
    SELECT 
        arrayJoin(balance_changes) as balance_change
    FROM solana.transactions
    PREWHERE block_timestamp >= '2025-05-20 10:00:00'
    WHERE block_timestamp <= '2025-05-20 20:00:51'
        AND length(balance_changes) > 0
)
SELECT 
    balance_change.1 as account,
    sum(balance_change.3 - balance_change.2) / 1e9 as net_change_sol,
    count() * 100 as estimated_tx_count  -- Adjust for sampling
FROM sampled_changes
GROUP BY account
HAVING abs(net_change_sol) > 10
ORDER BY abs(net_change_sol) DESC
LIMIT 20;

-- ============================================================================
-- QUERY 7: Pre-aggregated Daily Statistics
-- Purpose: Demonstrate MaterializedView performance
-- Optimization: Instant results from pre-computed aggregates
-- ============================================================================
SELECT 
    day,
    formatReadableQuantity(sum(finalizeAggregation(block_count))) as unique_blocks,
    formatReadableQuantity(sum(finalizeAggregation(txn_count))) as total_transactions
FROM solana.block_txn_counts_by_day_mv
WHERE day IN ('2025-05-19', '2025-05-20')
GROUP BY day
ORDER BY day DESC;

-- ============================================================================
-- QUERY 8: Program Performance Profiling
-- Purpose: Help developers optimize compute usage
-- Optimization: Focused time window with compute filtering
-- ============================================================================
WITH program_stats AS (
    SELECT 
        accounts[1].1 as program_id,
        compute_units_consumed,
        fee
    FROM solana.transactions
    PREWHERE block_timestamp >= '2025-05-20 19:00:00'  -- Last hour
        AND compute_units_consumed > 0
    WHERE block_timestamp <= '2025-05-20 20:00:51'
        AND length(accounts) > 0
        AND status = '1'
    LIMIT 100000
)
SELECT 
    program_id,
    count() as calls,
    avg(compute_units_consumed) as avg_compute,
    quantile(0.95)(compute_units_consumed) as p95_compute,
    sum(fee) / 1e9 as total_fees_sol
FROM program_stats
GROUP BY program_id
HAVING calls > 10
ORDER BY calls DESC
LIMIT 10;

-- ============================================================================
-- QUERY 9: Network Congestion Analysis
-- Purpose: Identify network congestion patterns
-- Optimization: Minute-level aggregation for recent data
-- ============================================================================
SELECT 
    toStartOfMinute(block_timestamp) as minute,
    count() as tx_count,
    avg(compute_units_consumed) as avg_compute,
    countIf(status != '1') as failed_count
FROM solana.transactions
PREWHERE block_timestamp >= '2025-05-20 19:30:00'  -- Last 30 minutes
WHERE block_timestamp <= '2025-05-20 20:00:51'
GROUP BY minute
ORDER BY minute DESC
LIMIT 30;


-- ============================================================================
-- BONUS QUERIES FOR Q&A
-- ============================================================================

-- Find transaction patterns by time of day
SELECT
    hour_of_day,
    avg(txn_count) AS avg_transactions,
    max(txn_count) AS peak_transactions
FROM
(
    SELECT
        toHour(block_timestamp) AS hour_of_day,
        toDate(block_timestamp) AS day,
        count()                   AS txn_count
    FROM solana.transactions
    WHERE block_timestamp >= '2025-05-01'
      AND block_timestamp <= '2025-05-20'
    GROUP BY
        hour_of_day,
        day
) AS per_hour_day
GROUP BY
    hour_of_day
ORDER BY
    hour_of_day;

-- Network fees analysis
SELECT
    toStartOfDay(block_timestamp)   AS day,
    sum(fee) / 1e9                  AS daily_fees_sol,
    avg(fee) / 1e9                  AS avg_fee_sol,
    count()                         AS transaction_count,
    (sum(fee) / count()) / 1e9      AS avg_fee_per_tx_sol
FROM solana.transactions
WHERE block_timestamp >= '2025-05-01'
  AND block_timestamp <= '2025-05-20'
GROUP BY day
ORDER BY day DESC
LIMIT 20;
