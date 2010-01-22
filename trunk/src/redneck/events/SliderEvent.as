package redneck.events
{
	import redneck.events.BaseEvent;
	public class SliderEvent extends BaseEvent
	{
		public static const ON_CHANGE:String = "sliderOnChange";
		public static const ON_PRESS:String = "sliderOnPress";
		public static const ON_RELEASE:String = "sliderOnRelease";
		/**
		 * 
		 * This event should be used by Slider
		 * 
		 * @param	type		String
		 * @param	bubbles		Boolean
		 * @param	cancelable	Boolean
		 * 
		 * */
		public function SliderEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
		
	}
}