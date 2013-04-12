package stdlib;

class Utf8 extends haxe.Utf8
{
	static var lower = [ 
		// russian
		"а", "б", "в", "г", "д", "е", "ё", "ж", "з", "и", "й", "к", "л", "м", "н", "о", "п", "р", "с", "т", "у", "ф", "х", "ц", "ч", "ш", "щ", "ь", "ы", "ъ", "э", "ю", "я" 
	];
	static var upper = [
		// russian
		"А", "Б", "В", "Г", "Д", "Е", "Ё", "Ж", "З", "И", "Й", "К", "Л", "М", "Н", "О", "П", "Р", "С", "Т", "У", "Ф", "Х", "Ц", "Ч", "Ш", "Щ", "Ь", "Ы", "Ъ", "Э", "Ю", "Я"
	];
	
	/**
	 * Unicode char codes for original 0x80-0xFF codes.
	 */
	static var unicodeWindows1251 =
	[
		  0x0402, 0x0403, 0x201A, 0x0453, 0x201E, 0x2026, 0x2020, 0x2021, 0x20AC, 0x2030, 0x0409, 0x2039, 0x040A, 0x040C, 0x040B, 0x040F
		, 0x0452, 0x2018, 0x2019, 0x201C, 0x201D, 0x2022, 0x2013, 0x2014, 0x0000, 0x2122, 0x0459, 0x203A, 0x045A, 0x045C, 0x045B, 0x045F
		, 0x00A0, 0x040E, 0x045E, 0x0408, 0x00A4, 0x0490, 0x00A6, 0x00A7, 0x0401, 0x00A9, 0x0404, 0x00AB, 0x00AC, 0x00AD, 0x00AE, 0x0407
		, 0x00B0, 0x00B1, 0x0406, 0x0456, 0x0491, 0x00B5, 0x00B6, 0x00B7, 0x0451, 0x2116, 0x0454, 0x00BB, 0x0458, 0x0405, 0x0455, 0x0457
		, 0x0410, 0x0411, 0x0412, 0x0413, 0x0414, 0x0415, 0x0416, 0x0417, 0x0418, 0x0419, 0x041A, 0x041B, 0x041C, 0x041D, 0x041E, 0x041F
		, 0x0420, 0x0421, 0x0422, 0x0423, 0x0424, 0x0425, 0x0426, 0x0427, 0x0428, 0x0429, 0x042A, 0x042B, 0x042C, 0x042D, 0x042E, 0x042F
		, 0x0430, 0x0431, 0x0432, 0x0433, 0x0434, 0x0435, 0x0436, 0x0437, 0x0438, 0x0439, 0x043A, 0x043B, 0x043C, 0x043D, 0x043E, 0x043F
		, 0x0440, 0x0441, 0x0442, 0x0443, 0x0444, 0x0445, 0x0446, 0x0447, 0x0448, 0x0449, 0x044A, 0x044B, 0x044C, 0x044D, 0x044E, 0x044F
	];
	
	public static inline function iter( s : String, chars : Int -> Void ) haxe.Utf8.iter(s, chars)

	public static function encode( s : String, ?codepage:String ) : String
	{
		if (codepage == null) return haxe.Utf8.encode(s)
		if (codepage == "windows-1251") return encodeHalfTable(s, unicodeWindows1251);
		throw "Codepage '" + codepage + "' is not supported.");
	}
	
	static function encodeHalfTable( s:String, unicodeTable:Array<Int> ) : String
	{
		var r = new StringBuf();
		for (i in 0...s.length)
		{
			var c = s.charCodeAt(i);
			if ((c & 0x7F) == c) r.addChar(c);
			else
			{
				var u = unicodeTable[c - 0x80];
				if ((u >> 11) != 0) r.addChar(0xE0 | (u >> 12));
				r.addChar(0xC0 | (u >> 6));
				r.addChar(0x80 | (u & 0x3F));
			}
		}
		return r.toString();		
	}

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