package stdlib;

class PromiseTools
{
	@:noUsing
	public static function delay(milliseconds:Int) : Promise<{}>
	{
		return new Promise<{}>(function(resolve:{}->Void, _:Dynamic->Void)
		{
			haxe.Timer.delay(function() resolve(null), milliseconds);
		});
	}
}