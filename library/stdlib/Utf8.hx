package stdlib;

class Utf8 extends haxe.Utf8
{
	public static inline function iter(s:String, chars:Int->Void) haxe.Utf8.iter(s, chars);

	public static inline function encode(s:String) return haxe.Utf8.encode(s);
	
	public static inline function decode(s:String) return haxe.Utf8.decode(s);

	public static inline function charCodeAt(s:String, index:Int) return haxe.Utf8.charCodeAt(s, index);

	public static inline function validate(s:String) return return haxe.Utf8.validate(s);

	public static inline function length(s:String) return return haxe.Utf8.length(s);

	public static inline function compare(a:String, b:String) return haxe.Utf8.compare(a, b);

	public static inline function sub(s:String, pos:Int, len:Int) return haxe.Utf8.sub(s, pos, len);
	
	public static function replace(s:String, from:String, to:String) : String
	{
		var codes = []; haxe.Utf8.iter(s, function(c) codes.push(c));
		var r = new Utf8();
		var len = haxe.Utf8.length(from);
		for (i in 0...codes.length - len + 1)
		{
			var found = true;
			var j = 0;
			Utf8.iter(from, function(cc)
			{
				if (found)
				{
					if (codes[i + j] != cc) found = false;
					j++;
				}
			});
			if (found) r.addString(to);
			else	   r.addChar(codes[i]);
		}
		for (i in codes.length - len + 1...codes.length)
		{
			r.addChar(codes[i);
		}
		return r.toString();
	}
	
	public function addString(s:String) haxe.Utf8.iter(s, function(c) addChar(c));
}