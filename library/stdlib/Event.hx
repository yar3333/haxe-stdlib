package stdlib;

class Event<SenderType, EventArgsType>
{
	var sender : SenderType;
	var handlers : Array<SenderType->EventArgsType->Void>;
	
	public function new(sender:SenderType) 
	{
		this.sender = sender;
		handlers = [];
	}
	
	public function bind(handler:SenderType->EventArgsType->Void) : Void
	{
		handlers.push(handler);
	}
	
	public function unbind(handler:SenderType->EventArgsType->Void) : Void
	{
		while (handlers.remove(handler)) {};
	}
	
	public function call(args:EventArgsType) : Void
	{
		for (handler in handlers)
		{
			Reflect.callMethod(null, handler, [ sender, args ]);
		}
	}
}