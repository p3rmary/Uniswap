{% macro interpret_topic0(topic_0) %}

case when {{topic_0}} = '0x0c396cd989a39f4459b5fa1aed6a9a8dcdbc45908acfd67e028cd568da98982c' then 'Burn'
when {{topic_0}} = '0x596b573906218d3411850b26a6b437d6c4522fdb43d2d2386263f86d50b8b151' then 'Collect protocol'
when {{topic_0}} = '0x70935338e69775456a85ddef226c395fb668b63fa0115f5f20610b388e6ca9c0' then 'Collect'
when {{topic_0}} = '0x7a53080ba414158be7ec69b987b5fb7d07dee101fe85488f0853ae16239d0bde' then 'Mint'
when {{topic_0}} = '0x973d8d92bb299f4af6ce49b52a8adb85ae46b9f214c4c4fc06ac77401237b133' then 'Set fee protocol'
when {{topic_0}} = '0xac49e518f90a358f652e4400164f05a5d8f7e35e7747279bc3a93dbf584e125a' then 'Increase observation'
when {{topic_0}} = '0xbdbdb71d7860376ba52b25a5028beea23581364a40522f6bcfb86bb1f2dca633' then 'Flash'
when {{topic_0}} = '0xc42079f94a6350d7e6235f29174924f928cc2ac818eb64fed8004e115fbcca67' then 'Swap'

else 'Unknown'
end 
{% endmacro %}