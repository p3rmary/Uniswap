select 
    tx_hash,
    block_number,
    '0x' || right(base.topic_1, 40) as token0,
    '0x' || right(base.topic_2, 40) as token1,
    ('x' || right(base.topic_3, 16))::bit(64)::bigint/ 1000000.0 as fee,
    {{ decode_pools('base.data') }}
from {{ source('public', 'uniswap_pools_event_logs') }} base