# stdlib haxe library #

Light library with a basic stuff: events, dumps, regexps, exceptions, uuids.

### Std class extends std.Std ###
```
#!haxe
Std.parseInt(s, defaultValue)
Std.parseFloat(s, defaultValue)
Std.bool(v)           // return *true* except *v* is: false, null, 0, "", "0", "false", "off", "null"
Std.parseValue(s)     // return Bool, Int, Float or String
Std.hash(obj)         // make a map from object fields
Std.min(n)            // min for Int
Std.max(n)            // max for Int
Std.sign(f)           // return -1 / 0 / +1
Std.array(it)         // return array from iterator: Std.array(map.keys())
Std.ifnull(a, b)      // return a != null ? a : b
```

### StringTools class extends std.StringTools ###
```
#!haxe
StringTools.ltrim(s, chars)
StringTools.rtrim(s, chars)
StringTools.trim(s, chars)
StringTools.regexEscape(s)
StringTools.jsonEscape(s)
StringTools.addcslashes(s) // like addcslashes in php
```
