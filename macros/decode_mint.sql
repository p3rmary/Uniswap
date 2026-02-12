{% macro decode_mint(data) %}

    '0x' || substring({{ data }}, case when left({{ data }}, 2) = '0x' then 27 else 25 end, 40) AS sender,

    {{ hex_to_int("substring(" ~ data ~ ", case when left(" ~ data ~ ", 2) = '0x' then 67 else 65 end, 64)", 128, false) }} AS amount,

    {{ hex_to_int("substring(" ~ data ~ ", case when left(" ~ data ~ ", 2) = '0x' then 131 else 129 end, 64)", 256, false) }} AS amount0,

    {{ hex_to_int("substring(" ~ data ~ ", case when left(" ~ data ~ ", 2) = '0x' then 195 else 193 end, 64)", 256, false) }} AS amount1

{% endmacro %}