package stdlib;

class Unserializer extends haxe.Unserializer
{
	public static function run(v:String, ?r:haxe.Unserializer.TypeResolver) : Dynamic
	{
		var unserializer = new haxe.Unserializer(v);
		if (r != null) unserializer.setResolver(r);
		return unserializer.unserialize();
	}
}
