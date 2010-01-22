package redneck.events
{
	import flash.events.*;
	public class NavigationEvent extends BaseEvent
	{
		public var session:String;
		public static const SESSION_LOAD_START : String = "loadStart";
		public static const SESSION_LOAD_COMPLETE : String = "loadComplete";
		public static const CHANGED_CURRENT_SESSION : String = "changedCurrentSession";
		public function NavigationEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
	}
}

