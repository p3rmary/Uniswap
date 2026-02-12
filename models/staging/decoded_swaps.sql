select
    base.block_number,
    base.block_timestamp,
    base.tx_hash,
    base.contract_address,
'0x' || right(base.topic_1, 40) as sender,
'0x' || right(base.topic_2, 40) as recipient,

    {{ decode_swap('base.data') }}

from {{ ref('pools_event_enriched') }} base
where base.event_name = 'Swap'
