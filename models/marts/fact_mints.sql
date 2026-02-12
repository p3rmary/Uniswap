{{ config(materialized = 'table') }}

select
    block_number,
    to_timestamp(block_timestamp, 'DD/MM/YYYY HH24:MI') as block_timestamp,
    tx_hash,
    owner,
    sender,
    amount0 / power(10, decimals0) as amount_0,
(amount0 / power(10, decimals0)) * p0.price as amount_0_usd,
    symbol0 as symbol_0,
    amount1 / power(10, decimals1) as amount_1,
   (amount1 / power(10, decimals1)) * p1.price as amount_1_usd,
    symbol1 as symbol_1,
    symbol0 || '/' || symbol1 as pool,
    amount,
    tick_lower,
    tick_upper

from {{ ref('decoded_mints') }}

join {{ ref('dim_pools') }}
  on pool_address = contract_address

left join {{ ref('uniswap_pools_token_prices_historical') }} p0
  on p0.token = token0
 and p0.timestamp::timestamp = date_trunc('day', to_timestamp(block_timestamp, 'DD/MM/YYYY HH24:MI'))

left join {{ ref('uniswap_pools_token_prices_historical') }} p1
  on p1.token = token1
 and p1.timestamp::timestamp = date_trunc('day', to_timestamp(block_timestamp, 'DD/MM/YYYY HH24:MI'))