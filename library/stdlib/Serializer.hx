package stdlib;

class Serializer extends haxe.Serializer
{
	public static function run(v:Dynamic, useCache=false) : String
	{
		var serializer = new haxe.Serializer();
		serializer.useCache = useCache;
		serializer.serialize(v);
		return serializer.toString();
	}
}
