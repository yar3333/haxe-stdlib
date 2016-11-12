package stdlib;

typedef Lambda = std.Lambda;

#if slambda
typedef Slambda = std.Slambda;
#end

class LambdaArray
{
	public static function addRange<A>(arr:Array<A>, range:Array<A>) : Void
	{
		for (e in range)
		{
			arr.push(e);
		}
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
	
	public static function spliceEx<A>(arr:Array<A>, pos:Int, ?len:Int, ?replacement:Array<A>) : Array<A>
	{
		var r = arr.splice(pos, len != null ? len : arr.length - pos);
		if (replacement != null) insertRange(arr, pos, replacement);
		return r;
	}
}

class LambdaIterable
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
	
	public static function findLastIndex<A>(it:Iterable<A>, f:A->Bool) : Int
	{
		var r = -1;
		
		var n = 0;
		for (x in it)
		{
			if (f(x)) r = n;
			n++;
		}
		
		return r;
	}
	
	public static function sorted<A>(it:Iterable<A>, ?cmp:A->A->Int) : Array<A>
	{
		var r = Lambda.array(it);
		r.sort(cmp != null ? cmp : Reflect.compare);
		return r;
	}
}

class LambdaIterator
{
	public static function array<A>(it:Iterator<A>) : Array<A>
	{
		var r = new Array<A>();
		for (e in it) r.push(e);
		return r;
	}
	
	public static function indexOf<A>(it:Iterator<A>, elem:A) : Int
	{
		var r = 0;
		while (it.hasNext())
		{
			if (it.next() == elem) return r;
			r++;
		}
		return -1;
	}
	
	public static function map<A,R>(it:Iterator<A>, conv:A->R) : Array<R>
	{
		var r = new Array<R>();
		for (e in it) r.push(conv(e));
		return r;
	}
	
	public static function filter<A>(it:Iterator<A>, pred:A->Bool) : Array<A>
	{
		var r = new Array<A>();
		for (e in it) if (pred(e)) r.push(e);
		return r;
	}
	
	public static function exists<A>(it:Iterator<A>, pred:A->Bool) : Bool
	{
		for (e in it) if (pred(e)) return true;
		return false;
	}
	
	public static function count<A>(it:Iterator<A>, ?pred:A->Bool)
	{
		var n = 0;
		if(pred == null) for (_ in it) n++;
		else             for (x in it) if (pred(x)) n++;
		return n;
	}
	
	public static function findIndex<A>(it:Iterator<A>, f:A->Bool) : Int
	{
		var n = 0;
		for (x in it)
		{
			if (f(x)) return n;
			n++;
		}
		return -1;
	}
	
	public static function findLastIndex<A>(it:Iterator<A>, f:A->Bool) : Int
	{
		var r = -1;
		
		var n = 0;
		for (x in it)
		{
			if (f(x)) r = n;
			n++;
		}
		
		return r;
	}
	
	public static function sorted<A>(it:Iterator<A>, ?cmp:A->A->Int) : Array<A>
	{
		var r = array(it);
		r.sort(cmp != null ? cmp : Reflect.compare);
		return r;
	}
}
