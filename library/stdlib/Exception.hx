package stdlib;

import haxe.CallStack;
using StringTools;

class Exception 
{
	public var message(default, null) : String;
	public var stack(default, null) : Array<StackItem>;

	public function new(?message:String)
	{
		this.message = message == null ? "" : message;
		stack = CallStack.callStack();
		stack.shift();
		stack.shift();
	}

	public function toString() : String
	{
		#if (!js || xpcom)
		return message + "\nStack trace:\n\t" + StringTools.ltrim(CallStack.toString(stack)).replace("\n", "\n\t");
		#else
		return message;
		#end
	}
	
	public static function string(e:Dynamic) : String
	{
		#if (!js || xpcom)
		var r = Std.string(e);
		if (!Std.is(e, Exception))
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
	
	static function wrap(exception:Dynamic) : Exception
	{
		if (!Std.is(exception, Exception))
		{
			var r = new Exception(Std.string(exception));
			r.stack = CallStack.exceptionStack();
			return r;
		}
		return exception;
	}
}