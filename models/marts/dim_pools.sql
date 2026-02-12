{{config (materialized ='table')}}

select
t.pool_address,
t.token0,
t.token1,
t.fee/1000000 as fee,
m0.symbol as symbol0,
m1.symbol as symbol1, 
m0.decimals as decimals0,
m1.decimals as decimals1
from  {{ref ('uniswap_pools_with_tokens')}} t
 left join {{ref ('uniswap_pools_tokens_metadata')}} m0
on t.token0 = m0.token 
left join {{ref ('uniswap_pools_tokens_metadata' )}} m1
on  t.token1= m1.token