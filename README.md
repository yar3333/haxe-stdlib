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
Std.min(a, b)         // min for Int
Std.max(a, b)         // max for Int
Std.sign(f)           // return -1.0 / 0.0 / +1.0
Std.array(it)         // return array from iterator: Std.array(map.keys())
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
trace(re.replace("3ab4")); // output is: 3bz4
```
 * Note 1: flag "g" is always exists, so you can omit it.
 * Note 2: you can use nonestandard flag "r" to repeat search&replace while string changed.
 * Note 3: you can specify additional "except" part at the end: /a.c/123/g/a([xy])c - will replace "abc" to "123", but not "axc" or "ayc".
 * Note 4: change characters case is also supported (use $vN and $^N): /(.)b/$^1b/g - will replace "ab" to "Ab".
 * Note 5: you can use other delimiter than "/": new Regex("#abc#def#g").

### stdlib.Utf8 class extends haxe.Utf8 ###
```
#!haxe
Utf8.replace(text, from, to)
Utf8.htmlEscape(s, chars)
Utf8.htmlUnescape(s)

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

trace(Debug.getDump(obj)); // dump obj
```

### stdlib.Profiler class ###
#### Manual collect data ####
```
#!haxe
var profiler = new Profiler(5); // 5 = collect data deep level

profiler.measure("myCodeA", function()
{
    // code to measure duration
});

var result = profiler.measureResult("myCodeB", function()
{
    // code to measure duration
    return "abc"; // result
});
```

#### Collect data by macro ####
Use **@:build(stdlib.Profiler.build(full_path_to_static_profiler_var))** to enable profiling for classes and **@ profile** (without space) before class/method to specify profiling all/specified class methods:
```
#!haxe
class Main
{
    public static var profiler = new stdlib.Profiler();
    
    static function main()
    {
        var obj = new MyClassToProfile();
        obj.f();
    }
}

@:build(stdlib.Profiler.build(Main.profiler))
class MyClassToProfile
{
    @profile public function f() {  trace("f() called"); }
}
```

#### Getting collected data ####
```
#!haxe
// trace summary
profiler.traceResults();

// get all calls as linear array
var results = profiler.getCallStackResults();

// get all calls as tree
var callTree = profiler.getCallStack();
//it is very useful to generate human-readable json from this
trace(Json.stringify({ name:"myApp", stack:callTree }));
```