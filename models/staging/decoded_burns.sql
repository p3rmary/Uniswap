select
    base.block_number,
    base.block_timestamp,
    base.tx_hash,
    base.contract_address,
    '0x' || right(base.topic_1, 40) as owner,
    event_name,
    {{ hex_to_int("case when left(base.topic_2, 2) = '0x' then substring(base.topic_2, 3) else base.topic_2 end", 24, true) }} as tick_lower,
    {{ hex_to_int("case when left(base.topic_3, 2) = '0x' then substring(base.topic_3, 3) else base.topic_3 end", 24, true) }} as tick_upper,

    {{ decode_burn('base.data') }}

from {{ ref('pools_event_enriched') }} base
where base.event_name ='Burn'