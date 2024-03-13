package stdlib;

typedef Lambda = std.Lambda;

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

    public static function filterByType<A:{}, T:{}>(arr:Array<A>, klass:Class<T>) : Array<T>
    {
        return cast arr.filter(x -> Std.isOfType(x, klass));
    }

    public static function distinct<A>(arr:Array<A>, ?equFunc:A->A->Bool)
    {
        var r = new Array<A>();
        if (equFunc == null)
        {
            for (x in arr) if (!r.contains(x)) r.push(x);
        }
        else
        {
            for (x in arr) if (!stdlib.Lambda.exists(r, y -> equFunc(x, y))) r.push(x);
        }
        return r;
    }

    #if js
    overload public extern static inline function toMapMany<A, K>(arr:Array<A>, keySelector:A->K) : js.lib.Map<K, Array<A>>
    {
        return toMapManyInner(arr, keySelector, item -> item);
    }
    overload public extern static inline function toMapMany<A, K, V>(arr:Array<A>, keySelector:A->K, valueSelector:A->V) : js.lib.Map<K, Array<V>>
    {
        return toMapManyInner(arr, keySelector, valueSelector);
    }
    static function toMapManyInner<A, K, V>(arr:Array<A>, keySelector:A->K, valueSelector:A->V) : js.lib.Map<K, Array<V>>
    {
        var r = new js.lib.Map<K, Array<V>>();
        for (item in arr)
        {
            final k = keySelector(item);
            if (r.has(k)) r.get(k).push(valueSelector(item));
            else          r.set(k, cast [ valueSelector(item) ]);
        }
        return r;
    }

    overload public extern static inline function toMapOne<A, K>(arr:Array<A>, keySelector:A->K) : js.lib.Map<K, A>
    {
        return toMapOneInner(arr, keySelector, item -> item);
    }
    overload public extern static inline function toMapOne<A, K, V>(arr:Array<A>, keySelector:A->K, valueSelector:A->V) : js.lib.Map<K, V>
    {
        return toMapOneInner(arr, keySelector, valueSelector);
    }
    static function toMapOneInner<A, K, V>(arr:Array<A>, keySelector:A->K, valueSelector:A->V) : js.lib.Map<K, V>
    {
        var r = new js.lib.Map<K, V>();
        for (item in arr)
        {
            r.set(keySelector(item), valueSelector(item));
        }
        return r;
    }
    #end
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
	
	public static function reversed<A>(it:Iterable<A>) : Array<A>
	{
		var r = Lambda.array(it);
        r.reverse();
		return r;
	}

    public static function filterByType<A:{}, T:{}>(it:Iterable<A>, klass:Class<T>) : Array<T>
    {
        var r = [];
		for (x in it)
		{
			if (Std.isOfType(x, klass)) r.push((cast x : T));
		}
        return r;
    }

    public static function skipWhile<A>(it:Iterable<A>, f:A->Bool) : Array<A>
    {
        final iterator = it.iterator();
        while (iterator.hasNext() && f(iterator.next())) {}
        
        final r = [];
        while (iterator.hasNext()) r.push(iterator.next());
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
	
	public static function join<A>(it:Iterator<A>, sep:String) : String
	{
		var r = new StringBuf();
		
		var isFirst = true;
		for (x in it)
		{
			if (!isFirst) r.add(sep);
			else          isFirst = false;
			r.add(Std.string(x));
		}
		
		return r.toString();
	}
}
