/**
 * 
 * @author igor almeida.
 * 
 * */
package redneck.events
{
	import redneck.events.BaseEvent;
	public class LogEvent extends BaseEvent
	{ 
		public static const VERBOSE : String = "##logVerbose##";
		public static const ERROR : String = "##logError##";
		public function LogEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super( type , bubbles, cancelable);
		}
	}
}