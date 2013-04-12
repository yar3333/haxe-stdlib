package stdlib;

#if (php || neko)

#if php
import php.Web;
#elseif neko
import neko.Web;
#end

using stdlib.StringTools;

class Uuid 
{
	public static function newUuid() : String
	{
		var timeF = Date.now().getTime();
		var time = Std.int(timeF - (1.0 * 0x0FFFFFFF) * Std.int(timeF / 0x0FFFFFFF));
        var uuid = getHexClientIP().substr(0, 8).rpad("0", 8) 
				 + "-" + StringTools.hex(Std.int(timeF / 0x10000), 8)
				 + "-" + StringTools.hex(time % 0x10000, 8)
				 + "-" + StringTools.hex(Std.random(0x10000), 4)
				 + "-" + StringTools.hex(Std.random(0x10000), 4);
		return uuid;
	}
	
	static function getHexClientIP()
    {
		var ip = Web.getClientHeader("X-Real-IP");
		if (ip == null || ip == "")
		{
			ip = Web.getClientIP();
		}
		
        var hex = "";
        for (part in ip.split('.'))
        {
            hex += StringTools.hex(Std.parseInt(part), 2);
        }
        return hex;
    }
}

#end