select
block_timestamp,
    block_number,
    tx_hash,
    contract_address,
    topic_0,
    topic_1,
    topic_2,
    topic_3,
    data,
    {{ interpret_topic0('topic_0') }} as event_name

from {{ ref('pools_with_timestamp') }}

