package stdlib;

typedef Lambda = std.Lambda;

class LambdaEx
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
	
	public static function extract<A>(arr:Array<A>, f:A->Bool) : Array<A>
	{
		var r = [];
		var i = 0; while (i < arr.length)
		{
			if (f(arr[i]))
			{
				r.push(arr[i]);
				arr.splice(i, 1);
			}
			else
			{
				i++;
			}
		}
		return r;
	}
}
