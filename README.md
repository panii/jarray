# jarray
My utility for serializing and deserializing JavaScript arrays and Erlang lists, written in March 2013! I developed this for my personal needs as Erlang does not have built-in support for JSON format.

```javascript
// javascript

usage: JArray.stringify(["AAA", "BBB", ["CCC", "DDD"]]) // result: "2#AAA||BBB||1#CCC|DDD"
usage: JArray.parse("2#AAA||BBB||1#CCC|DDD") // result: ["AAA", "BBB", ["CCC", "DDD"]]

> j_stringify_test()
case A - pass
case B - pass
case C - pass
case D - pass
case E - pass
case F - pass
case G - pass
case H - pass
case I - pass
case J - pass
case K - pass
case L - pass
case M - pass
case N - pass

> j_parse_test()
case A - pass
case B - pass
case C - pass
case D - pass
case E - pass
case F - pass
case G - pass
case H - pass
case I - pass
case J - pass
case K - pass
case L - pass
case M - pass
case N - pass
```


```erlang
// erlang

[work with string]
usage: jarray:stringify(["AAA", "BBB", ["CCC", "DDD"]]). // result: "2#AAA||BBB||1#CCC|DDD"
usage: jarray:parse("2#AAA||BBB||1#CCC|DDD"). // result: ["AAA","BBB",["CCC","DDD"]]

[work with binary]
usage: jarray:stringify_binary([<<"AAA">>, <<"BBB">>, [<<"CCC">>, <<"DDD">>]]). // result: <<"2#AAA||BBB||1#CCC|DDD">>
usage: jarray:parse_binary(<<"2#AAA||BBB||1#CCC|DDD">>). // result: [<<"AAA">>,<<"BBB">>,[<<"CCC">>,<<"DDD">>]]

> jarray:test_all().
[Work with string] 
Test test_get_max_deep() 
"case A" - "pass"
"case B" - "pass"
"case C" - "pass"
"case D" - "pass"
"case E" - "pass"
"case F" - "pass"
"case G" - "pass"
"case H" - "pass"
"case I" - "pass"
"case J" - "pass"
"case K" - "pass"
"case L" - "pass"
"case M" - "pass"
"case N" - "pass"

Test stringify() 
"case A" - "pass"
"case B" - "pass"
"case C" - "pass"
"case D" - "pass"
"case E" - "pass"
"case F" - "pass"
"case G" - "pass"
"case H" - "pass"
"case I" - "pass"
"case J" - "pass"
"case K" - "pass"
"case L" - "pass"
"case M" - "pass"
"case N" - "pass"

Test parse() 
"case A" - "pass"
"case B" - "pass"
"case C" - "pass"
"case D" - "pass"
"case E" - "pass"
"case F" - "pass"
"case G" - "pass"
"case H" - "pass"
"case I" - "pass"
"case J" - "pass"
"case K" - "pass"
"case L" - "pass"
"case M" - "pass"
"case N" - "pass"


[Work with binary] 
Test test_get_max_deep_binary() 
"case A" - "pass"
"case B" - "pass"
"case C" - "pass"
"case D" - "pass"
"case E" - "pass"
"case F" - "pass"
"case G" - "pass"
"case H" - "pass"
"case I" - "pass"
"case J" - "pass"
"case K" - "pass"
"case L" - "pass"
"case M" - "pass"
"case N" - "pass"

Test stringify_binary() 
"case A" - "pass"
"case B" - "pass"
"case C" - "pass"
"case D" - "pass"
"case E" - "pass"
"case F" - "pass"
"case G" - "pass"
"case H" - "pass"
"case I" - "pass"
"case J" - "pass"
"case K" - "pass"
"case L" - "pass"
"case M" - "pass"
"case N" - "pass"

Test parse_binary() 
"case A" - "pass"
"case B" - "pass"
"case C" - "pass"
"case D" - "pass"
"case E" - "pass"
"case F" - "pass"
"case G" - "pass"
"case H" - "pass"
"case I" - "pass"
"case J" - "pass"
"case K" - "pass"
"case L" - "pass"
"case M" - "pass"
"case N" - "pass"

```
