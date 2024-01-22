package stdlib;

#if !macro

@:build(stdlib.Macro.forwardStaticMethods(haxe.Timer))
class Timer extends haxe.Timer
{
	public static function delayAsync(milliseconds:Int) : js.lib.Promise<{}>
	{
		return new js.lib.Promise<{}>(function(resolve:{}->Void, _:Dynamic->Void)
		{
			haxe.Timer.delay(function() resolve(null), milliseconds);
		});
	}
}

#else

typedef Timer = haxe.Timer;

#end