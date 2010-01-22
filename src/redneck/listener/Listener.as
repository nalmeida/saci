package redneck.listener
{
	import flash.events.Event;
	
	public class Listener
	{
		public var method : Function
		public var type : String
		public var useCapture : Boolean
		public var priority : int
		public var weakReference : Boolean;
		public function Listener( p_type : String , p_method : Function, p_useCapture : Boolean = false, p_priority : int = 0 , p_weakReference : Boolean = false)
		{
			this.type = p_type;
			this.method = p_method;
			this.weakReference = p_weakReference;
			this.priority = p_priority;
			this.useCapture = p_useCapture;
		}
		public function toString():String
		{
			return "[Listener] type: " + this.type ;
		}
	}
}