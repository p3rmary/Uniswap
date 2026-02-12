{% macro decode_tick(topic_expr) %}
    {{ hex_to_int("case when left(" ~ topic_expr ~ ", 2) = '0x' then substring(" ~ topic_expr ~ ", 3) else " ~ topic_expr ~ " end", 24, true) }}
{% endmacro %}