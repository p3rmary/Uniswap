{% macro hex_to_int(hex_expr, bit_size, is_signed=false) %}
    {% if bit_size == 32 %}
        case 
            when {{ hex_expr }} is null or length({{ hex_expr }}) < 2 then 0
            else 
                (('x' || right({{ hex_expr }}, 8))::bit(32)::bigint)
                {% if is_signed %}
                    - (case when (('x' || right({{ hex_expr }}, 8))::bit(32)::bigint) >= 2147483648 then 4294967296 else 0 end)
                {% endif %}
        end

    {% elif bit_size == 64 %}
        case 
            when {{ hex_expr }} is null or length({{ hex_expr }}) < 2 then 0
            else 
            (
                (('x' || substring(lpad(right({{ hex_expr }}, 16), 16, '0'), 1, 8))::bit(32)::bigint)::numeric * 4294967296 + 
                (('x' || substring(lpad(right({{ hex_expr }}, 16), 16, '0'), 9, 8))::bit(32)::bigint)::numeric
            )
            {% if is_signed %}
                - (case when substring(lpad(right({{ hex_expr }}, 16), 16, '0'), 1, 1) ~ '[89aAbBcCdDeEfF]' 
                   then 18446744073709551616::numeric else 0::numeric end)
            {% endif %}
        end
        
    {% elif bit_size == 128 %}
        case 
            when {{ hex_expr }} is null or length({{ hex_expr }}) < 2 then 0
            else 
            (
                (('x' || substring(lpad(right({{ hex_expr }}, 32), 32, '0'), 1, 8))::bit(32)::bigint)::numeric * 79228162514264337593543950336 + 
                (('x' || substring(lpad(right({{ hex_expr }}, 32), 32, '0'), 9, 8))::bit(32)::bigint)::numeric * 18446744073709551616 + 
                (('x' || substring(lpad(right({{ hex_expr }}, 32), 32, '0'), 17, 8))::bit(32)::bigint)::numeric * 4294967296 + 
                (('x' || substring(lpad(right({{ hex_expr }}, 32), 32, '0'), 25, 8))::bit(32)::bigint)::numeric
            )
            {% if is_signed %}
                - (case when substring(lpad(right({{ hex_expr }}, 32), 32, '0'), 1, 1) ~ '[89aAbBcCdDeEfF]' 
                   then 340282366920938463463374607431768211456::numeric else 0::numeric end)
            {% endif %}
        end

    {% elif bit_size == 160 %}
        case 
            when {{ hex_expr }} is null or length({{ hex_expr }}) < 2 then 0
            else 
            (
                (('x' || substring(lpad(right({{ hex_expr }}, 40), 40, '0'), 1, 8))::bit(32)::bigint)::numeric * 340282366920938463463374607431768211456 +
                (('x' || substring(lpad(right({{ hex_expr }}, 40), 40, '0'), 9, 8))::bit(32)::bigint)::numeric * 79228162514264337593543950336 + 
                (('x' || substring(lpad(right({{ hex_expr }}, 40), 40, '0'), 17, 8))::bit(32)::bigint)::numeric * 18446744073709551616 + 
                (('x' || substring(lpad(right({{ hex_expr }}, 40), 40, '0'), 25, 8))::bit(32)::bigint)::numeric * 4294967296 + 
                (('x' || substring(lpad(right({{ hex_expr }}, 40), 40, '0'), 33, 8))::bit(32)::bigint)::numeric
            )
        end

    {% elif bit_size == 256 %}
        case 
            when {{ hex_expr }} is null or length({{ hex_expr }}) < 2 then 0
            else 
            (
                (('x' || substring(lpad(right({{ hex_expr }}, 64), 64, '0'), 1, 8))::bit(32)::bigint)::numeric * 
                    26959946667150639794667015087019630673637144422540572481103610249216::numeric +
                (('x' || substring(lpad(right({{ hex_expr }}, 64), 64, '0'), 9, 8))::bit(32)::bigint)::numeric * 
                    6277101735386680763835789423207666416102355444464034512896::numeric +
                (('x' || substring(lpad(right({{ hex_expr }}, 64), 64, '0'), 17, 8))::bit(32)::bigint)::numeric * 
                    1461501637330902918203684832716283019655932542976::numeric +
                (('x' || substring(lpad(right({{ hex_expr }}, 64), 64, '0'), 25, 8))::bit(32)::bigint)::numeric * 
                    340282366920938463463374607431768211456::numeric +
                (('x' || substring(lpad(right({{ hex_expr }}, 64), 64, '0'), 33, 8))::bit(32)::bigint)::numeric * 
                    79228162514264337593543950336::numeric +
                (('x' || substring(lpad(right({{ hex_expr }}, 64), 64, '0'), 41, 8))::bit(32)::bigint)::numeric * 
                    18446744073709551616::numeric +
                (('x' || substring(lpad(right({{ hex_expr }}, 64), 64, '0'), 49, 8))::bit(32)::bigint)::numeric * 
                    4294967296::numeric +
                (('x' || substring(lpad(right({{ hex_expr }}, 64), 64, '0'), 57, 8))::bit(32)::bigint)::numeric
            )
            {% if is_signed %}
                - (case when substring(lpad(right({{ hex_expr }}, 64), 64, '0'), 1, 1) ~ '[89aAbBcCdDeEfF]' 
                   then power(2::numeric, 256) 
                   else 0::numeric end)
            {% endif %}
        end
        
    {% elif bit_size == 24 %}
         case 
            when {{ hex_expr }} is null or length({{ hex_expr }}) < 2 then 0
            else 
                (('x' || right({{ hex_expr }}, 6))::bit(24)::int)
                {% if is_signed %}
                    - (case when (('x' || right({{ hex_expr }}, 6))::bit(24)::int) >= 8388608 then 16777216 else 0 end)
                {% endif %}
        end
    {% endif %}
{% endmacro %}