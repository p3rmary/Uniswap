{% macro decode_burn(data) %}

    {{ hex_to_int("substring(" ~ data ~ ", case when left(" ~ data ~ ", 2) = '0x' then 3 else 1 end, 64)",128,false) }} as amount,

    {{ hex_to_int("substring(" ~ data ~ ", case when left(" ~ data ~ ", 2) = '0x' then 67 else 65 end, 64)",256,false) }} as amount0,

    {{ hex_to_int("substring(" ~ data ~ ", case when left(" ~ data ~ ", 2) = '0x' then 131 else 129 end, 64)",256,false) }} as amount1

{% endmacro %}
