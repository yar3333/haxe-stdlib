package stdlib;

class StringTools 
{
	public static inline function urlEncode( s : String ) : String return std.StringTools.urlEncode(s);
	
	public static inline function urlDecode( s : String ) : String return std.StringTools.urlDecode(s);

	public static inline function htmlEscape( s : String ) : String return std.StringTools.htmlEscape(s);

	public static inline function htmlUnescape( s : String ) : String return std.StringTools.htmlUnescape(s);

	public static inline function startsWith( s : String, start : String ) return std.StringTools.startsWith(s, start);

	public static inline function endsWith( s : String, end : String ) return std.StringTools.endsWith(s, end);

	public static inline function isSpace( s : String, pos : Int ) : Bool return std.StringTools.isSpace(s, pos);

	public static function ltrim( s : String, chars : String = null ) : String
    {
        #if php
		return chars == null ? untyped __call__("ltrim", s) : untyped __call__("ltrim", s, chars);
        #else
        if (chars == null)
		{
			return std.StringTools.ltrim(s);
		}
		while (s.length > 0 && chars.indexOf(s.substr(0, 1)) >= 0)
		{
			s = s.substr(1);
		}
		return s;
        #end
    }

	public static function rtrim( s : String, chars : String = null ) : String
    {
        #if php
		return chars == null ? untyped __call__("rtrim", s) : untyped __call__("rtrim", s, chars);
        #else
        if (chars == null)
		{
			return std.StringTools.rtrim(s);
		}
		while (s.length > 0 && chars.indexOf(s.substr(s.length - 1, 1)) >= 0)
		{
			s = s.substr(0, s.length - 1);
		}
		return s;
        #end
    }

	public static function trim( s : String, chars : String = null ) : String
    { 
        #if php
		return chars == null ? untyped __call__("trim", s) : untyped __call__("trim", s, chars);
        #else
        if (chars == null)
		{
			return std.StringTools.trim(s);
		}
		return rtrim(ltrim(s, chars), chars);
        #end
    }

	public static inline function rpad( s : String, c : String, l : Int ) : String return std.StringTools.rpad(s, c, l);

	public static inline function lpad( s : String, c : String, l : Int ) : String return std.StringTools.lpad(s, c, l);

	public static inline function replace( s : String, sub : String, by : String ) : String return std.StringTools.replace(s, sub, by);

	public static inline function hex( n : Int, ?digits : Int ) return std.StringTools.hex(n, digits);

	public static inline function fastCodeAt( s : String, index : Int ) : Int return std.StringTools.fastCodeAt(s, index);

	public static inline function isEOF( c : Int ) : Bool return std.StringTools.isEof(c);
    
	public static inline function hexdec(s : String) : Int
	{
		#if php
		return untyped __call__('hexdec', s);
		#else
		return Std.parseInt("0x" + s);
		#end
	}
	
	public static function addcslashes(s:String) : String
    {
		#if php
        return untyped __call__('addcslashes', s, "\'\"\t\r\n\\");
		#else
		return new EReg("[\'\"\t\r\n\\\\]", "g").map(s, function(re) return "\\" + re.matched(0));
		#end
    }
	
	/**
	 * allowedTags example: "<a><p>".
	 */
	public static inline function stripTags(str:String, allowedTags="") : String
	{
		#if php
		
		return untyped __call__('strip_tags', str, allowedTags);
		
		#else
		
		var allowedTagsArray = [];
		if (allowedTags != "")
		{
			var re = ~/[a-zA-Z0-9]+/i;
			var pos = 0;
			while (re.matchSub(allowedTags, pos))
			{
				allowedTagsArray.push(re.matched(0));
				pos = re.matchedPos().pos + re.matchedPos().len;
			}
		}
		
		var matches = [];
		var re = ~/<\/?[\S][^>]*>/g;
		str = re.map(str, function(_)
		{
			var html = re.matched(0);
			var allowed = false;
			if (allowedTagsArray.length > 0)
			{
				var htmlLC = html.toLowerCase();
				for (allowedTag in allowedTagsArray)
				{
					if (StringTools.startsWith(htmlLC, '<' + allowedTag + '>')
					 || StringTools.startsWith(htmlLC, '<' + allowedTag + ' ')
					 || StringTools.startsWith(htmlLC, '</' + allowedTag)
					) {
						allowed = true;
						break;
					}
				}
			}
			return allowed ? html : "";
		});
		
		return str;
		
		#end
	}
	
	#if php
	public static inline function format(template:String, value:Dynamic) : String
	{
		return untyped __call__('sprintf', template, value);
	}
	#end
	
	public static function regexEscape(s:String) : String
	{
		return ~/([\-\[\]\/\{\}\(\)\*\+\?\.\\\^\$\|])/g.replace(s, "\\$1");
	}
	
	public static function jsonEscape(s:String) : String
	{
        if (s == null) return "null";
		
        var r = new Utf8(s.length + Std.int(s.length/5));
		
        r.addChar('"'.code);
		
		Utf8.iter(s, function(c)
		{
            switch (c)
			{
				case "\\".code:
					r.addChar("\\".code);
					r.addChar("\\".code);
					
				case '"'.code:
					r.addChar("\\".code);
					r.addChar('"'.code);
					
				case "\t".code:
					r.addChar("\\".code);
					r.addChar("t".code);
				
				case "\n".code:
					r.addChar("\\".code);
					r.addChar("n".code);
					
				case "\r".code:
					r.addChar("\\".code);
					r.addChar("r".code);
					
				default:
					if (c < 32)
					{
						r.addChar("\\".code);
						r.addChar("u".code);
						var t = StringTools.hex(c, 4);
						r.addChar(StringTools.fastCodeAt(t, 0));
						r.addChar(StringTools.fastCodeAt(t, 1));
						r.addChar(StringTools.fastCodeAt(t, 2));
						r.addChar(StringTools.fastCodeAt(t, 3));
					}
					else
					{
						r.addChar(c);
					}
            }
        });
		
		r.addChar('"'.code);
		
		return r.toString();
	}
	
	public static function isEmpty(s:String) : Bool return s == null || s == "";
	
	public static function capitalize(s:String) : String return isEmpty(s) ? s : s.substr(0, 1).toUpperCase() + s.substr(1);
}