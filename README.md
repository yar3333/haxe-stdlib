# stdlib haxe library #

Light library with a basic stuff: events, dumps, regexps, exceptions, uuids.

### stdlib.Std class ###
This class extends standard `Std`.
```haxe
Std.parseInt(s, defaultValue)
Std.parseFloat(s, defaultValue)
Std.bool(v)           // return *true* except *v* is: false, null, 0, "", "0", "false", "off", "null"
Std.parseValue(s)     // return Bool, Int, Float or String
Std.hash(obj)         // make a map from object fields
Std.min(a, b)         // min for Int
Std.max(a, b)         // max for Int
Std.sign(f)           // return -1.0 / 0.0 / +1.0
```

### stdlib.StringTools class ###
This class extends standard `StringTools`.
```haxe
StringTools.ltrim(s, chars)
StringTools.rtrim(s, chars)
StringTools.trim(s, chars)
StringTools.regexEscape(s)
StringTools.jsonEscape(s)
StringTools.addcslashes(s) // like addcslashes in php
```

### stdlib.Exception class ###
```haxe
try
{
   if (isBad1) throw new Exception("smart exception"); // guarantees you to have a call stack in the catch
   if (isBad2) throw "native exception";
}
catch (e:Dynamic)
{
	trace(Exception.string(e));
	trace(Exception.wrap(e).message);
	Exception.rethrow(e);
}
```

### stdlib.Event class ###
```haxe
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
Full-form regex support like /search/replacement/flags. Substitutions $0-$9 in replacement are also supported.
```haxe
var re = new Regex("/a(.)/$1z/g");
trace(re.replace("3ab4")); // output is: 3bz4
```
 * Note 1: flag "g" is always exists, so you can omit it.
 * Note 2: you can use nonestandard flag "r" to repeat search&replace while string changed.
 * Note 3: you can specify additional "except" part at the end: /a.c/123/g/a([xy])c - will replace "abc" to "123", but not "axc" or "ayc".
 * Note 4: change characters case is also supported (use $vN and $^N): /(.)b/$^1b/g - will replace "ab" to "Ab".
 * Note 5: you can use other delimiter than "/": new Regex("#abc#def#g").

### stdlib.Utf8 class ###
This class extends standard `haxe.Utf8`.
```haxe
Utf8.replace(text, from, to)
Utf8.htmlEscape(s, chars)
Utf8.htmlUnescape(s)

var buf = new Utf8();
buf.addString("эюя");
```

### stdlib.Uuid class ###
Safe generation of the unique IDs. On sys platforms IP+time+random is used. On the none-sys: counter+time+random.
```haxe
var s = Uuid.newUuid();
```

### stdlib.Debug class ###
```haxe
Debug.assert(condition, message); // throw exception if condition is false

trace(Debug.getDump(obj)); // dump obj
```

### stdlib.Lambda module ###
Use this module through "using" to get all bonuses: standard Lambda and additional methods:
```haxe
using stdlib.Lambda;

arr.insertRange(pos, arr2)      // insert many items into specified position
arr.extract(item->Bool)         // remove items from array by predicate and return them

iterable.findIndex(item->Bool)  // find item index by predicate (from start)
iterable.sorted(?cmpFunc)       // return sorted array by the iterable (if `cmpFunc` is not specified then `Reflect.compare()` will be used)

iterator.array()
iterator.map(item->item2)
iterator.filter(item->Bool)
iterator.count(?pred)
iterator.findIndex(item->Bool)
iterator.sorted(?cmpFunc)
```
