package stdlib;

import haxe.CallStack;
import haxe.Log;
import Type;
using stdlib.StringTools;
using Lambda;

class Debug
{
	public static function getDump(v:Dynamic, limit=10, level=0, prefix="") : String
	{
		if (level >= limit) return "...\n";
		
		prefix += "\t";
		
		var s = "?\n";
		switch (Type.typeof(v))
		{
			case ValueType.TBool:
				s = "BOOL(" + (v ? "true" : "false") + ")\n";
			
			case ValueType.TNull:
				s = "NULL\n";
				
			case ValueType.TClass(c):
				if (c == String)
				{
					s = "STRING(" + Std.string(v) + ")\n";
				}
				else
				if (c == Array)
				{
					s = "ARRAY(" + v.length + ")\n";
					for (item in cast(v, Array<Dynamic>))
					{
						s += prefix + getDump(item, limit, level + 1, prefix);
					}
				}
				else
				if (c == List)
				{
					s = "LIST(" + Lambda.count(v) + ")\n";
					for (item in cast(v, List<Dynamic>))
					{
						s += prefix + getDump(item, limit, level + 1, prefix);
					}
				}
				else
				if (c == haxe.ds.StringMap)
				{
					s = "StringMap\n";
					var map = cast(v, haxe.ds.StringMap<Dynamic>);
					for (key in map.keys())
					{
						s += prefix + key + " => " + getDump(map.get(key), limit, level + 1, prefix);
					}
				}
				else
				{
					s = "CLASS(" + Type.getClassName(c) + ")\n" + getObjectDump(v, limit, level + 1, prefix);
				}
			
			case ValueType.TEnum(e):
				s = "ENUM(" + Type.getEnumName(e) + ") = " + Type.enumConstructor(v) + "\n";
			
			case ValueType.TFloat:
				s = "FLOAT(" + Std.string(v) + ")\n";
			
			case ValueType.TInt:
				s = "INT(" + Std.string(v) + ")\n";
			
			case ValueType.TObject:
				s = "OBJECT" + "\n" + getObjectDump(v, limit, level + 1, prefix);
			
			case ValueType.TFunction, ValueType.TUnknown:
				s = "FUNCTION OR UNKNOW\n";
		};
		
		return s;
	}
	
	static function getObjectDump(obj:Dynamic, limit:Int, level:Int, prefix:String) : String
	{
		var s = "";
		for (fieldName in Reflect.fields(obj))
		{
			s += prefix + fieldName + " : " + getDump(Reflect.field(obj, fieldName), limit, level, prefix);
		}
		return s;
	}
	
	#if debug
	/**
	 * Message can be a string or function Void->String.
	 */
	public static function assert(e:Bool, ?message:Dynamic, ?pos:haxe.PosInfos) : Void
	{
		if (!e) 
		{
			if (message == null) message = "error";
			else
			if (Reflect.isFunction(message)) message = message();
			
			var s = "ASSERT " + Std.string(message) + " in " + pos.fileName + " at line " + pos.lineNumber;
			#if (js && xpcom)
			untyped xpcom.Components.utils.reportError(s);
			#end
			var r = new Exception(s);
			r.stack.shift();
			throw r;
		}
	}
	#else
	public static inline function assert(e:Bool, ?message:Dynamic, ?pos:haxe.PosInfos) : Void { }
	#end
	
	#if debug
	public static function traceStack(v:Dynamic, ?pos:haxe.PosInfos) : Void
	{
		var stack = CallStack.toString(CallStack.callStack()).replace("prototype<.", "").trim();
		
		#if js
		var lines = stack.split("\n")
			.filter(function(s) return s != "Called from module")
			.map(function(s) return s.split("@").map(function(ss) return ss.rtrim("</")).join("@"));
		var len = 0; for (line in lines) len = Std.max(len, line.indexOf("@"));
		lines = lines.map(function(line)
		{
			var ss = line.split("@");
			return ss[0] + "".rpad(" ", len - ss[0].length + 1) + ss[1];
		});
		stack = lines.slice(1).join("\n");
		#end
		
		trace("TRACE " + (Std.is(v, String) ? v : getDump(v).trim()) + "\nStack trace:\n" + stack, pos);
	}
	#else
	public static function traceStack(v:Dynamic, ?pos:haxe.PosInfos) : Void
	{
	}
	#end
}