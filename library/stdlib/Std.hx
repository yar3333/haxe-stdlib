package stdlib;

class Std 
{
	public static inline function is( v : Dynamic, t : Dynamic ) : Bool return std.Std.is(v, t);
	
	public static inline function string( s : Dynamic ) : String return std.Std.string(s);
	
	public static inline function int( x : Float ) : Int return std.Std.int(x);
	
	public static function parseInt( x : String, ?defaultValue:Int ) : Null<Int>
	{
		return x != null
			? (~/^\s*[+-]?\s*((?:0x[0-9a-fA-F]{1,7})|(?:\d{1,9}))\s*$/.match(x) ? std.Std.parseInt(x) : defaultValue)
			: defaultValue;
	}
	
	public static function parseFloat( x : String, ?defaultValue:Float ) : Null<Float>
	{
		return x != null
			? (~/^\s*[+-]?\s*\d{1,9}(?:[.]\d+)?(?:e[+-]?\d{1,9})?\s*$/.match(x) ? std.Std.parseFloat(x) : defaultValue)
			: defaultValue;
	}
	
	public static inline function random( x : Int ) : Int { return std.Std.random(x);  }
	
    public static function bool(v:Dynamic) : Bool
    {
		return v != false 
		    && v != null 
			&& v != 0 
			&& v != "" 
			&& v != "0" 
			&& (!Std.is(v, String) || cast(v, String).toLowerCase() != "false" && cast(v, String).toLowerCase() != "off" && cast(v, String).toLowerCase() != "null");
    }
	
	public static function parseValue( x:String ) : Dynamic
	{
		var value : Dynamic = x;
		var valueLC = value != null ? value.toLowerCase() : null;
		var parsedValue : Dynamic;
		
		if (valueLC == "true") value = true;
		else
		if (valueLC == "false") value = false;
		else
		if (valueLC == "null") value = null;
		else
		if ((parsedValue = Std.parseInt(value)) != null) value = parsedValue;
		else
		if ((parsedValue = Std.parseFloat(value)) != null) value = parsedValue;
		
		return value;
	}
	
    /**
     * Make hash from object's fields.
     */
	public static function hash(obj:Dynamic) : Map<String,Dynamic>
    {
       var r = new Map<String,Dynamic>();
       for (key in Reflect.fields(obj))
       {
          r.set(key, Reflect.field(obj, key));
       }
       return r;
    }
    
    
   public static inline function min(a:Int, b:Int) : Int return a < b ? a : b;
   
   public static inline function max(a:Int, b:Int) : Int return a > b ? a : b;
   
   public static inline function sign(n:Float) : Int return n > 0.0 ? 1 : (n < 0.0 ? -1 : 0);
}
