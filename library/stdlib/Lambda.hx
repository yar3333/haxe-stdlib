package stdlib;

#if !macro

@:build(stdlib.Macro.forwardStaticMethods(std.Lambda))
class Lambda
{
	public static function findIndex<A>(it:Iterable<A>, f:A->Bool) : Int
	{
		var n = 0;
		for (x in it)
		{
			if (f(x)) return n;
			n++;
		}
		return -1;
	}
   
	public static function insertRange<A>(arr:Array<A>, pos:Int, range:Array<A>) : Void
	{
		for (e in range)
		{
			arr.insert(pos++, e);
		}
	}
}

#else

typedef Lambda = std.Lambda;

#end