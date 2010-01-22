/**
 * 
 * @author igor almeida
 * @version 0.1
 * 
 * */
package redneck.events
{
	import flash.events.Event;
	import flash.utils.getQualifiedClassName;

	public class BaseEvent extends Event
	{
		/* used to explain extra information */
		public var text: String;
		
		/* should store the name of session when used with a Broadcaster or not BaseSession classes.*/
		public var name: String;
		/**
		 * 
		 * @param	type		String
		 * @param	bubbles		Boolean
		 * @param	cancelable	Boolean
		 * 
		 * */
		public function BaseEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
		/**
		 * 
		 * Return a simple string parsing the main properties.
		 * 
		 * @return String
		 * 
		 * */
		public override function toString( ) : String
		{
			return "( "+getQualifiedClassName(this)+" [ type:'"+type+"' name='"+name+"' text='"+text+"' ])";	
		}
	}
}