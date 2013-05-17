package stdlib;

import haxe.Stack;
using StringTools;

class Exception 
{
	public var message(default, null) : String;
	public var stackTrace(default, null) : Array<StackItem>;
	public var innerException(default, null) : Exception;
	public var baseException(get_baseException, null) : Exception;

	public function new(?message:String, ?innerException:Dynamic)
	{
		this.message = message == null ? "" : message;
		
		if (innerException != null)
		{
			if (Std.is(innerException, Exception))
			{
				this.innerException = innerException;
			}
			else
			{
				this.innerException = new Exception(Std.string(innerException), null);
				this.innerException.stackTrace = Stack.exceptionStack();
			}
		}
		
		stackTrace = Stack.callStack();
		stackTrace.shift();
	}

	function get_baseException() 
	{
		var inner = this;
		while (inner.innerException != null)
		{
			inner = inner.innerException;
		}
		return inner;
	}
	
	public function toString() : String
	{
		var innerString = innerException != null ? innerException.toString() : "";
		return message 
			+ "\n\tStack trace:" + Stack.toString(stackTrace).replace("\n", "\n\t\t") 
			+ (innerString != "" ? "\nINNER EXCEPTION: " + innerString : "");
	}
	
	public static function toText(exception:Dynamic) : String
	{
		var text = "EXCEPTION: ";
		if (Std.is(exception, Exception))
		{
			text += exception.toString();
		}
		else
		{
			text += Std.string(exception) + "\n\tStack trace:" + Stack.toString(Stack.exceptionStack()).replace("\n", "\n\t\t");
		}
		return text;
	}
	
	public static function rethrow(exception:Dynamic) : Void
	{
		#if neko
		neko.Lib.rethrow(exception);
		#else
		throw wrap(exception);
		#end
	}
	
	public static function wrap(exception:Dynamic) : Exception
	{
		if (!Std.is(exception, Exception))
		{
			var r = new Exception(Std.string(exception));
			r.stackTrace = haxe.Stack.exceptionStack();
			return r;
		}
		return exception;
	}
}