package stdlib;

using StringTools;

@:build(stdlib.Macro.forwardStaticMethods(haxe.Utf8))
class Utf8 extends haxe.Utf8
{
	public static function replace(s:String, from:String, to:String) : String
	{
		var codes = []; haxe.Utf8.iter(s, function(c) codes.push(c));
		var r = new Utf8();
		var len = haxe.Utf8.length(from);
		if (codes.length < len) return s;
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
			r.addChar(codes[i]);
		}
		return r.toString();
	}
	
	public function addString(s:String) haxe.Utf8.iter(s, function(c) addChar(c));
	
	public static function compactSpaces(s:String) : String
	{
		var r = new Utf8();
		var prevSpace = false;
		Utf8.iter(s, function(c:Int)
		{
			if (c == " ".code || c == "\r".code || c == "\n".code || c == "\t".code)
			{
				if (!prevSpace)
				{
					r.addChar(" ".code);
					prevSpace = true;
				}
			}
			else
			{
				r.addChar(c);
				prevSpace = false;
			}
		});
		return r.toString();
	}
	
	public static function htmlUnescape(s:String) : String
	{
		var r = new Utf8();
		
		// TODO: CDATA suppport
		
		var escape : String = null;
		
		Utf8.iter(s, function(c:Int)
		{
			if (escape != null)
			{
				if (c == ";".code)
				{
					var chr = htmlUnescapeChar(escape);
					if (chr != null) r.addChar(chr);
					escape = null;
				}
				else
				{
					escape += String.fromCharCode(c);
				}
			}
			else
			if (c == "&".code)
			{
				escape = "";
			}
			else
			{
				r.addChar(c);
			}
		});
		
		return r.toString();
	}
	
	public static function htmlEscape(utf8Str:String, chars="") : String
	{
		chars = "&<>" + chars;
		
		var r = new Utf8();
		
		Utf8.iter(utf8Str, function(c:Int)
		{
			var s = htmlEscapeMap.get(c);
			if (s != null && c >= 0 && c <= 255 && chars.indexOf(String.fromCharCode(c)) >= 0)
			{
				r.addString(s);
			}
			else
			{
				r.addChar(c);
			}
		});
		
		return r.toString();
	}
	
	static function htmlUnescapeChar(escape:String) : Null<Int>
	{
		if (escape.startsWith("#x")) return Std.parseInt("0x" + escape.substr(2));
		else
		if (escape.startsWith("#")) return Std.parseInt(escape.substr(1));
		else
		{
			var r = htmlUnescapeMap.get(escape);
			if (r != null) return r;
		}
		
		trace("Unknow escape sequence: " + escape);
		return null;
	}

	@:isVar static var htmlEscapeMap(get, null) : Map<Int, String>;
	static function get_htmlEscapeMap()
	{
		if (htmlEscapeMap == null)
		{
			htmlEscapeMap =
			[
				" ".code => "&nbsp;",
				"&".code => "&amp;",
				"<".code => "&lt;",
				">".code => "&gt;",
				"\"".code => "&quot;",
				"'".code => "&apos;",
				"\r".code => "&#xD;",
				"\n".code => "&#xA;"
			];
		}
		return htmlEscapeMap;
	}
	
	@:isVar static var htmlUnescapeMap(get, null) : Map<String, Int>;
	static function get_htmlUnescapeMap()
	{
		if (htmlUnescapeMap == null)
		{
			htmlUnescapeMap =
			[
				"nbsp" => " ".code,
				"amp" => "&".code,
				"lt" => "<".code,
				"gt" => ">".code,
				"quot" => "\"".code,
				"apos" => "'".code,
				"euro" => "€".code,
				"iexcl" => "¡".code,
				"cent" => "¢".code,
				"pound" => "£".code,
				"curren" => "¤".code,
				"yen" => "¥".code,
				"brvbar" => "¦".code,
				"sect" => "§".code,
				"uml" => "¨".code,
				"copy" => "©".code,
				"ordf" => "ª".code,
				"not" => "¬".code,
				"shy" => "­".code,
				"reg" => "®".code,
				"macr" => "¯".code,
				"deg" => "°".code,
				"plusmn" => "±".code,
				"sup2" => "²".code,
				"sup3" => "³".code,
				"acute" => "´".code,
				"micro" => "µ".code,
				"para" => "¶".code,
				"middot" => "·".code,
				"cedil" => "¸".code,
				"sup1" => "¹".code,
				"ordm" => "º".code,
				"raquo" => "»".code,
				"frac14" => "¼".code,
				"frac12" => "½".code,
				"frac34" => "¾".code,
				"iquest" => "¿".code,
				"Agrave" => "À".code,
				"Aacute" => "Á".code,
				"Acirc" => "Â".code,
				"Atilde" => "Ã".code,
				"Auml" => "Ä".code,
				"Aring" => "Å".code,
				"AElig" => "Æ".code,
				"Ccedil" => "Ç".code,
				"Egrave" => "È".code,
				"Eacute" => "É".code,
				"Ecirc" => "Ê".code,
				"Euml" => "Ë".code,
				"Igrave" => "Ì".code,
				"Iacute" => "Í".code,
				"Icirc" => "Î".code,
				"Iuml" => "Ï".code,
				"ETH" => "Ð".code,
				"Ntilde" => "Ñ".code,
				"Ograve" => "Ò".code,
				"Oacute" => "Ó".code,
				"Ocirc" => "Ô".code,
				"Otilde" => "Õ".code,
				"Ouml" => "Ö".code,
				"times" => "×".code,
				"Oslash" => "Ø".code,
				"Ugrave" => "Ù".code,
				"Uacute" => "Ú".code,
				"Ucirc" => "Û".code,
				"Uuml" => "Ü".code,
				"Yacute" => "Ý".code,
				"THORN" => "Þ".code,
				"szlig" => "ß".code,
				"agrave" => "à".code,
				"aacute" => "á".code,
				"acirc" => "â".code,
				"atilde" => "ã".code,
				"auml" => "ä".code,
				"aring" => "å".code,
				"aelig" => "æ".code,
				"ccedil" => "ç".code,
				"egrave" => "è".code,
				"eacute" => "é".code,
				"ecirc" => "ê".code,
				"euml" => "ë".code,
				"igrave" => "ì".code,
				"iacute" => "í".code,
				"icirc" => "î".code,
				"iuml" => "ï".code,
				"eth" => "ð".code,
				"ntilde" => "ñ".code,
				"ograve" => "ò".code,
				"oacute" => "ó".code,
				"ocirc" => "ô".code,
				"otilde" => "õ".code,
				"ouml" => "ö".code,
				"divide" => "÷".code,
				"oslash" => "ø".code,
				"ugrave" => "ù".code,
				"uacute" => "ú".code,
				"ucirc" => "û".code,
				"uuml" => "ü".code,
				"yacute" => "ý".code,
				"thorn" => "þ".code,
			];
		}
		return htmlUnescapeMap;
	}
}