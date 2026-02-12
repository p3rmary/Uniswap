{% macro decode_pools(data) %}
('x' || right(substr({{ data }}, 3, 64), 16))::bit(64)::bigint as tick_spacing,
'0x' || substr({{ data }}, 91, 40) as pool
{% endmacro %}