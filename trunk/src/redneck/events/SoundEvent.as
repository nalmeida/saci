/**
*	@author igor almeida
*	@version 0.2
*/
package redneck.events
{
	import redneck.events.BaseEvent;
	public class SoundEvent extends BaseEvent
	{
		public static const LIST_PUSH:String = "listPush";
		public static const LIST_REMOVE:String = "listRemove";
		public static const LIST_EMPTY:String = "listEmpty";
		public static const STATUS_CHANGE:String = "statusChange";
		public static const SOUND_COMPLETE:String = "soundComplete";
		public static const SOUND_LOOP:String = "soundLoop";
		public static const SOUND_PLAY:String = "soundPlay";
		public static const SOUND_STOP:String = "soundStop";
		public static const SOUND_PAUSE:String = "soundPause";
		/**
		 * 
		 * This event should be used by SoundController
		 * 
		 * @param	type		String
		 * @param	bubbles		Boolean
		 * @param	cancelable	Boolean
		 * 
		 * */
		public function SoundEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
		
	}
}