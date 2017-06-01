package stdlib;

typedef Promise<T> = js.Promise<T>;

class PromiseTools
{
	public static function thenPromise<S, D>(p:Promise<S>, f:S->(D->Void)->(Dynamic->Void)->Void) : Promise<D>
	{
		return p.then(function(r:S) : Promise<D> return new Promise<D>(f.bind(r)));
	}
}