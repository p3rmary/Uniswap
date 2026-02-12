select 
p.*,
t.datetime_utc as block_timestamp
--t.block_number
from {{source ('public', 'uniswap_pools')}} p 
left join {{source('public', 'uniswap_pools_timestamp')}} t
on p.block_number =t.block_number