package stdlib;

class Utf8 extends haxe.Utf8
{
	static var lower = [ "а","б","в","г","д","е","ё","ж","з","и","й","к","л","м","н","о","п","р","с","т","у","ф","х","ц","ч","ш","щ","ь","ы","ъ","э","ю","я" ];
	static var upper = [ "А","Б","В","Г","Д","Е","Ё","Ж","З","И","Й","К","Л","М","Н","О","П","Р","С","Т","У","Ф","Х","Ц","Ч","Ш","Щ","Ь","Ы","Ъ","Э","Ю","Я" ];
	
	public static inline function iter( s : String, chars : Int -> Void ) haxe.Utf8.iter(s, chars)

	public static inline function encode( s : String ) : String return haxe.Utf8.encode(s)

	public static inline function decode( s : String ) : String return haxe.Utf8.decode(s)

	public static inline function charCodeAt( s : String, index : Int ) : Int return haxe.Utf8.charCodeAt(s, index)

	public static inline function validate( s : String ) : Bool return haxe.Utf8.validate(s)

	public static inline function length( s : String ) : Int
	{
		#if php
		return untyped __call__('mb_strlen', s, 'UTF-8');
		#else
		return haxe.Utf8.length(s);
		#end
	}

	public static inline function compare( a : String, b : String ) : Int return haxe.Utf8.compare(a, b)

	public static function sub( s : String, pos : Int, ?len : Int ) : String
	{
        #if php
        return len != null 
            ? untyped __call__('mb_substr', s, pos, len, 'UTF-8')
            : untyped __call__('mb_substr', s, pos, length(s) - pos, 'UTF-8');
		#else
        return len != null 
            ? haxe.Utf8.sub(s, pos, len)
            : haxe.Utf8.sub(s, pos, length(s) - pos);
		#end
	}
	
    public static inline function toUpperCase(s : String) : String
    {
		#if php
		return untyped __call__('mb_strtoupper', s, 'UTF-8');
		#else
		return substitute(s, lower, upper);
		#end
    }
    
    public static inline function toLowerCase(s : String) : String
    {
        #if php
		return untyped __call__('mb_strtolower', s, 'UTF-8');
		#else
		return substitute(s, upper, lower);
		#end
    }
    
	static function substitute(s : String, from : Array<String>, to : Array<String>)
	{
		var r = "";
		for (i in 0...length(s))
		{
			var isAdded = false;
			var c = haxe.Utf8.sub(s, i, 1);
			for (j in 0...from.length)
			{
				if (c == from[j])
				{
					r += to[j];
					isAdded = true;
					break;
				}
			}
			if (!isAdded)
			{
				r += c;
			}
		}
		return r;
	}
	
	#if php
	public static function split(s : String, pattern : String) : Array<String>
	{
        untyped __call__('mb_regex_encoding', 'UTF-8');
        return untyped __php__("new _hx_array(mb_split($pattern, $s, $this->hglobal ? -1 : 2))");
	}
	#end
}