# stdlib haxe library #

Light library with a basic stuff: events, dumps, regexps, exceptions, uuids.

### stdlib.Std class extends std.Std ###
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

### stdlib.StringTools class extends std.StringTools ###
```
#!haxe
StringTools.ltrim(s, chars)
StringTools.rtrim(s, chars)
StringTools.trim(s, chars)
StringTools.regexEscape(s)
StringTools.jsonEscape(s)
StringTools.addcslashes(s) // like addcslashes in php
```

### stdlib.Event class ###
```
#!haxe
// define event with args a and b
var click = new Event<{ a:Int, b:String }>(this); // target = this

// attach handler
click.bind(function(target:Dynamic, e:{ a:Int, b:String })
{
    // handler code
});

// fire event
click.call({ a:10, b:"xyz" });
```

### stdlib.Regex class ###
Full-form regex support like /search/replacement/flags. Substitutions $0-$9 in replacement is also supported.
```
#!haxe
var re = new Regex("/a(.)/$1z/g");
trace(re.apply("3ab4")); // output is: 3bz4
```
 * Note 1: flag "g" is always exists, so you can omit it.
 * Note 2: you can specify additional "except" part at the end: /a.c/123/g/a([xy])c - will replace "abc" to "123", but not "axc" or "ayc".
 * Note 3: change characters case is also supported (use $vN and $^N): /(.)b/$^1b/g - will replace "ab" to "Ab".
 * Note 4: you can use other delimiter than "/": new Regex("#abc#def#g")

### stdlib.Utf8 class extends haxe.Utf8 ###
```
#!haxe
Utf8.replace(text, from, to)

var buf = new Utf8();
buf.addString("эюя");
```

### stdlib.Uuid class ###
```
#!haxe
var s = Uuid.newUuid();
```

### stdlib.Debug class ###
```
#!haxe
Debug.assert(condition, message); // throw exception if condition is false

var s = Debug.getDump(obj);
```