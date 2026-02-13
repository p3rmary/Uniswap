# Uniswap  Analytics Pipeline

## Overview
This project implements a fully automated analytics pipeline that extracts, transforms, and visualizes Uniswap pool swap activity. The pipeline tracks major liquidity pools (TVL > $1M) and provides actionable insights through real-time dashboards.

Analysis Period: December 25, 2025 - January 27, 2026

### Key Features
- Fully Automated: No manual CSV uploads or data wrangling
- Real-time Analytics: Data updates via Supabase REST API
- USD-Denominated Metrics: Standardized financial reporting across all pools
-  Performance Optimized: Materialized views handle Dune's 4MB query limits

### Architecture
```
┌─────────────────┐      ┌──────────────┐      ┌─────────────────┐
│  Ethereum Node  │─────▶│ Raw Events   │─────▶│ dbt Transform   │
│  (Public RPC)   │      │ (Swap Logs)  │      │ Layer           │
└─────────────────┘      └──────────────┘      └─────────────────┘
                                                         │
                                                         ▼
┌─────────────────┐      ┌──────────────┐      ┌─────────────────┐
│ Dune Analytics  │◀─────│  Supabase    │◀─────│  Materialized   │
│  Dashboard      │      │  REST API    │      │  Views          │
└─────────────────┘      └──────────────┘      └─────────────────┘
```
### Data Pipeline
1. Extraction
Raw swap events are extracted from Uniswap v3 pool contracts using:

Event Signature: ``Swap(address indexed sender, address indexed recipient, int256 amount0, int256 amount1, uint160 sqrtPriceX96, uint128 liquidity, int24 tick)``

Method: Direct contract ABI calls via Ethereum public RPC

Metadata Retrieved:

``Pool address``

``Token0``/``Token1`` addresses and symbols

``Fee`` tier

``Block timestamp and number``


2. Transformation (dbt)
The dbt layer applies a series of modular transformations:
```
staging/
├── pools_with_timestamp.sql       # pool events along with their timestamp
├── pools_event_enriched.sql    
├── decoded_swaps.sql              # decoded pool swaps
├──decoded_pools.sql               # Standardize pool information
├── decoded_mints.sql              # decoded mint event
└──  decoded_burns.sql             # decoded burn event

marts/
├── dim_pools.sql                  # final pool details
├── fact_swaps.sql                 # final swap table
├──fact_mints.sql                  # final mint table ( liquidity added)
└──fact_burns.sql                  # final burn table (liquidity removed)

```
Key Transformations:
- Token amount normalization (accounting for decimals)
- USD value calculation using price oracles
- Fee computation (in both token terms and USD)
- Transaction deduplication
- Date/time standardization (UTC)

3. Aggregation
Materialized views pre-compute daily metrics to ensure Dune LiveQuery responses stay under 4MB:
Metrics Computed:

- Total volume (USD)
- Total fees collected (USD)
- Total liquidity added (USD)
- Total liquidity removed (USD)

4. Visualization
Dune Analytics dashboard queries Supabase via LiveQuery, displaying:

- Daily volume trends
- Pool-by-pool performance comparison
- Fee generation analytics
- Liquidity depth over time

