{{ config(materialized = 'table') }}

with swap_calculations as (
    select
        s.block_number,
        to_timestamp(s.block_timestamp, 'DD/MM/YYYY HH24:MI') as block_timestamp,
        s.tx_hash,
        s.amount0,
        s.amount1,

        case 
            when s.amount0 > 0 then s.amount0 / power(10, p.decimals0)
            when s.amount1 > 0 then s.amount1 / power(10, p.decimals1)
        end as amount_in,

        case 
            when s.amount0 < 0 then abs(s.amount0) / power(10, p.decimals0)
            when s.amount1 < 0 then abs(s.amount1) / power(10, p.decimals1)
        end as amount_out,

        p.fee * (
            case 
                when s.amount0 > 0 then s.amount0 / power(10, p.decimals0)
                when s.amount1 > 0 then s.amount1 / power(10, p.decimals1)
            end
        ) as fee_amount,

        case 
            when s.amount0 > 0 then p.symbol0
            when s.amount1 > 0 then p.symbol1
        end as symbol_in,

        case 
            when s.amount0 < 0 then p.symbol0
            when s.amount1 < 0 then p.symbol1
        end as symbol_out,

        p.symbol0 || '/' || p.symbol1 as pool,
        
        p0.price as price0,
        p1.price as price1

    from {{ ref('decoded_swaps') }} s

    join {{ ref('dim_pools') }} p
      on s.contract_address = p.pool_address

    left join {{ ref('uniswap_pools_token_prices_historical') }} p0
      on p0.token = p.token0
     and p0.timestamp::timestamp = date_trunc('day', to_timestamp(s.block_timestamp, 'DD/MM/YYYY HH24:MI'))

    left join {{ ref('uniswap_pools_token_prices_historical') }} p1
      on p1.token = p.token1
     and p1.timestamp::timestamp = date_trunc('day', to_timestamp(s.block_timestamp, 'DD/MM/YYYY HH24:MI'))
)

select
    block_number,
    block_timestamp,
    tx_hash,
    amount_in,
    amount_out,
    fee_amount,
    symbol_in,
    symbol_out,
    pool,
    
    case
        when amount0 > 0 then amount_in * price0
        when amount1 > 0 then amount_in * price1
    end as amount_in_usd,

    case
        when amount0 < 0 then amount_out * price0
        when amount1 < 0 then amount_out * price1
    end as amount_out_usd,

    case
        when amount0 > 0 then fee_amount * price0
        when amount1 > 0 then fee_amount * price1
    end as fee_amount_usd

from swap_calculations