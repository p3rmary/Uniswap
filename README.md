# Uniswap
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
This project bridges the gap between raw on-chain events and high-level financial intelligence, specifically targeting high-liquidity pools (TVL > $1M) during the period of Dec 25, 2025, to Jan 27, 2026.

## Architecture & Data Flow
The pipeline is designed for modularity and scalability, moving away from static CSV uploads toward a dynamic "LiveQuery" architecture.

Extraction: Raw swap events and pool metadata (token decimals, fees, symbols) are pulled from Ethereum Public RPC nodes.

Loading: Raw JSON/logs are ingested into a Supabase (PostgreSQL) instance.

Transformation (dbt): * Normalizes hex data into readable integers.

Joins swap logs with metadata to compute USD-denominated volumes.

Aggregates data into daily snapshots.

Serving: Data is exposed via Supabase REST API.

Visualization: Dune Analytics fetches the transformed data via LiveQuery for real-time dashboarding.

