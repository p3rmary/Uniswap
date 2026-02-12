{% macro decode_swap(data) %}

    {{ hex_to_int("substring(" ~ data ~ ", case when left(" ~ data ~ ", 2) = '0x' then 3 else 1 end, 64)", 256, true) }} AS amount0,

    {{ hex_to_int("substring(" ~ data ~ ", case when left(" ~ data ~ ", 2) = '0x' then 67 else 65 end, 64)", 256, true) }} AS amount1,

    {{ hex_to_int("substring(" ~ data ~ ", case when left(" ~ data ~ ", 2) = '0x' then 131 else 129 end, 64)", 160, false) }} AS sqrt_price_x96,

    {{ hex_to_int("substring(" ~ data ~ ", case when left(" ~ data ~ ", 2) = '0x' then 195 else 193 end, 64)", 128, false) }} AS liquidity,

    {{ hex_to_int("substring(" ~ data ~ ", case when left(" ~ data ~ ", 2) = '0x' then 259 else 257 end, 64)", 24, true) }} AS tick

{% endmacro %}
