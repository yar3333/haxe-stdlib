package stdlib;

using StringTools;

/**
 * Full-form regex support like /search/replacement/flags. Substitutions $0-$9 in replacement is also supported. Example:
 * 
 * var re = new Regex("/a(.)/$1z/g");
 * trace(re.apply("3ab4")); // output is: 3bz4
 * 
 * Note 1: flag "g" is always exists, so you can omit it.
 * 
 * Note 2: you can use nonestandard flag "r" to repeat search&replace while string changed.
 * 
 * Note 3: you can specify additional "except" part at the end:
 * /a.c/123/g/a([xy])c - will replace "abc" to "123", but not "axc" or "ayc".
 * 
 * Note 4: change characters case is also supported (use $vN and $^N):
 * /(.)b/$^1b/g - will replace "ab" to "Ab".
 * 
 * Note 5: you can use other delimiter than "/":
 * new Regex("#abc#def#g")
 */
class Regex
{
	public var search : String;
	public var replacement : String;
	public var flags : String;
	public var excepts : String;
	public var repeat : Bool;
	
	public function new(re:String)
	{
		re = re.trim();
		
		if (re.length > 0)
		{
			var delimiter = re.substr(0, 1);
			
			search = "";
			var i = 1; while (i < re.length)
			{
				var c = re.substr(i, 1);
				if (c == delimiter && getBackSlashAtEndCount(re.substr(1, i - 1)) % 2 == 0)
				{
					i++;
					break;
				}
				else
				{
					search += c;
				}
				i++;
			}
			
			replacement = "";
			while (i < re.length)
			{
				var c = re.substr(i, 1);
				if (c == delimiter)
				{
					i++;
					break;
				}
				else
				if (c == "\\") 
				{
					i++;
					c = re.substr(i, 1);
					if (c == "r") replacement += "\r";
					else
					if (c == "n") replacement += "\n";
					else
					if (c == "t") replacement += "\t";
					else
					if (c == "\\") replacement += "\\";
					else
					replacement += c;
				}
				else
				{
					replacement += c;
				}
				i++;
			}
			
			var tail = re.substr(i);
			var n = tail.indexOf(delimiter);
			if (n < 0)
			{
				flags = tail;
			}
			else
			{
				flags = tail.substr(0, n).trim();
				excepts = unescape(tail.substr(n + 1).trim());
				if (excepts == "") excepts = null;
			}
			
			if (replacement == "$-") replacement = "";
			
			repeat = flags.indexOf("r") >= 0;
			flags = flags.replace("r", "").replace("g", "");
		}
		else
		{
			search = "";
			replacement = "";
			flags  = "";
		}
	}
	
	function getBackSlashAtEndCount(s:String)
	{
		var r = 0;
		while (r < s.length && s.charAt(s.length - 1 - r) == "\\") r++;
		return r;
	}
	
	public function replace(text:String, ?log:String->Void) : String
	{
		if (!repeat)
		{
			return replaceInner(text, log);
		}
		else
		{
			while (true)
			{
				var old = text;
				text = replaceInner(text, log);
				if (old == text) break;
			}
			return text;
		}
	}
	
	public function matchAll(text:String) : Array<{ pos:Int, len:Int, replacement:String }>
	{
		var r = [];
		var re = new EReg(search, "g" + flags);
		var i = 0; while (i < text.length && re.matchSub(text, i))
		{
			var p = re.matchedPos();
			if (excepts == null || !new EReg(excepts, "g").match(re.matched(0)))
			{
				r.push({ pos:p.pos, len:p.len, replacement:getActualReplacement(re) });
			}
			i = p.pos + p.len;
		}
		return r;
	}
	
	function replaceInner(text:String, ?log:String->Void) : String
	{
		return new EReg(search, "g" + flags).map(text, function(re)
		{
			if (excepts != null && new EReg(excepts, "g").match(re.matched(0))) return re.matched(0);
			var s = getActualReplacement(re);
			if (log != null) log(re.matched(0).replace("\r", "").replace("\n", "\\n") + " => " + s);
			return s;
		});
	}
	
	function getActualReplacement(re:EReg) : String
	{
		var s = "";
		var i = 0;
		while (i < replacement.length)
		{
			var c = replacement.charAt(i++);
			if (c != "$")
			{
				s += c;
			}
			else
			{
				c = replacement.charAt(i++);
				if (c == "$")
				{
					s += "$";
				}
				else
				{
					var command = "";
					if ("d0123456789".indexOf(c) < 0)
					{
						command = c;
						c = replacement.charAt(i++);
					}
					if (c == "d") { c = replacement.substr(i, 2); i += 2; }
					var number = Std.parseInt(c);
					var t = try re.matched(number) catch (_:Dynamic) "";
					if (t == null) t = "";
					switch(command)
					{
						case "^": t = t.toUpperCase();
						case "v": t = t.toLowerCase();
					}
					s += t;
				}
			}
		}
		return s;
	}
	
	function unescape(s:String) : String
	{
		var r = "";
		var i = 0; while (i < s.length)
		{
			var c = s.substr(i, 1);
			if (c == "\\") 
			{
				i++;
				c = s.substr(i, 1);
				if (c == "r") r += "\r";
				else
				if (c == "n") r += "\n";
				else
				if (c == "t") r += "\t";
				else
				r += "\\" + c;
			}
			else
			{
				r += c;
			}
			i++;
		}
		return r;
	}
}