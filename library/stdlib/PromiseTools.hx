package stdlib;

class PromiseTools
{
	@:noUsing
	public static function delay(milliseconds:Int) : js.Promise<{}>
	{
		return new js.Promise<{}>(function(resolve:{}->Void, _:Dynamic->Void)
		{
			haxe.Timer.delay(function() resolve(null), milliseconds);
		});
	}
}