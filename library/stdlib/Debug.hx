package stdlib;

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
				if (c == Map)
				{
					s = "Map\n";
					for (key in cast(v, Map<String,Dynamic>).keys())
					{
						s += prefix + key + " => " + getDump(v.get(key), limit, level + 1, prefix);
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
	public static function assert(e:Bool, message:String=null, ?pos:haxe.PosInfos) : Void
	{
		if (!e) 
		{
			if (message == null) message = "";
			throw "ASSERT " + message + " in " + pos.fileName + " at line " + pos.lineNumber;
		}
	}
	#else
	public static inline function assert(e:Bool, message:String=null, ?pos:haxe.PosInfos) : Void
	{
	}
	#end   
}