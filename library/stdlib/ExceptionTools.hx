package stdlib;

import haxe.Exception;
import haxe.CallStack;
using StringTools;

class ExceptionTools
{
	public static function string(e:Dynamic) : String
	{
		if (Std.isOfType(e, haxe.Exception)) return (cast e : haxe.Exception).details();
	
        #if (!js || xpcom)
        var r = Std.string(e);
        if (!Std.isOfType(e, Exception))
        {
            #if js
            var stack = Std.is(e, js.Error) ? e.stack : "";
            #else
            var stack = CallStack.toString(CallStack.exceptionStack());
            #end
            if (stack != "") r += "\nStack trace:\n\t" + StringTools.ltrim(stack).replace("\n", "\n\t");
        }
        return r;
        #else
        return Std.string(e);
        #end	
	}
	
    public static function rethrow(exception:Dynamic) : Void
    {
        #if neko
        neko.Lib.rethrow(exception);
        #else
        throw wrap(exception);
        #end
    }
    
    public static function wrap(e:Dynamic) : haxe.Exception
    {
        if (!Std.isOfType(e, haxe.Exception))
        {
            return new haxe.Exception(Std.string(e));
        }
        return e;
    }    
}