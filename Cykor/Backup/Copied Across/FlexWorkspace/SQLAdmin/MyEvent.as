package
{
	import flash.events.Event;

	public class MyEvent extends Event
	{
		public var data:Object;
		
		public function MyEvent(eventName:String, data:Object)
		{
			super(eventName);
			this.data = data;
		}

	}
}