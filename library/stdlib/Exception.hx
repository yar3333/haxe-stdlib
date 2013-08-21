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
	}

	public function toString() : String
	{
		return message + "\nStack trace:\n" + CallStack.toString(stack).replace("\n", "\n\t");
	}
	
	public static function string(e:Dynamic) : String
	{
		return Std.string(e) + (Std.is(e, Exception) ? "" : "\nStack trace:\n" + CallStack.toString(CallStack.exceptionStack()).replace("\n", "\n\t"));
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