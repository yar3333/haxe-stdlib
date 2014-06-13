package stdlib;

typedef StdLambda = std.Lambda;

class Lambda
{
   public static inline function findIndex<A>(it:Iterable<A>, f:A->Bool) : Int
   {
		var n = 0;
		for (x in it)
		{
			if (f(x)) return n;
			n++;
		}
		return -1;
   }
}
