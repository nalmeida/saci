/**
 * @author igor almeida
 * @version 1
 * */
package redneck.events
{
	import redneck.events.BaseEvent;
	public class DisplayEvent extends BaseEvent
	{
		public static const ON_SHOW:String = "onShowDisplay";
		public static const ON_HIDE:String = "onHideDisplay";
		public static const ON_FINISH_SHOWING:String = "onFinishShowDisplay";
		public static const ON_FINISH_HIDING:String = "onFinishHideDisplay";
		public static const ON_DISPOSE:String = "onDispose";
		/**
		 * 
		 * This event should be used by <code>BaseDisplay</code>
		 * 
		 * @param	type		String
		 * @param	bubbles		Boolean
		 * @param	cancelable	Boolean
		 * 
		 * */
		public function DisplayEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super( type, bubbles, cancelable );
		}
	}
}