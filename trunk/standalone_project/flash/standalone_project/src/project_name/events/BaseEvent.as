package project_name.events 
{
	/**
	@author Marcos Roque (mroque@fbiz.com.br)
	*/
	import flash.events.Event;
	/**
	 * ...
	 * @author Marcos Roque (mroque@fbiz.com.br)
	 */
	public class BaseEvent extends Event
	{
		/**
		Animation
		*/
		public static const COMPLETE_START_TRANSITION:String = "completeStartTransition";
		public static const COMPLETE_END_TRANSITION:String = "completeEndTransition";
		
		/**
		Communication
		*/
		public static const COMMUNICATION_COMPLETE:String = "communicationComplete";
		
		public var params:Object;
		
		public function BaseEvent(p_type:String, p_params:Object = null, p_bubbles:Boolean = false, p_cancelable:Boolean = false) {
			super(p_type, p_bubbles, p_cancelable);
			this.params = p_params;
		}
		
		public override function toString():String {
			return formatToString("BaseEvent", "params", "type", "bubbles", "cancelable");
		}
		
		override public function clone():Event
		{
			return new BaseEvent(type, params, bubbles, cancelable);
		}
		
	}
	
}
