package stdlib;

#if !macro

@:build(stdlib.Macro.forwardStaticMethods(haxe.Timer))
class Timer extends haxe.Timer
{
	public static function delayAsync(milliseconds:Int) : js.Promise<{}>
	{
		return new js.Promise<{}>(function(resolve:{}->Void, _:Dynamic->Void)
		{
			haxe.Timer.delay(function() resolve(null), milliseconds);
		});
	}
}

#else

typedef Timer = haxe.Timer;

#end