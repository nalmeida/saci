/**
 * 
 * Simple wrapper to store visted sessions.
 * 
 * */
package redneck.project.control
{
	import redneck.project.view.*;
	internal class HistorySession
	{
		public var name : String;
		public var transition : ATransition
		public function HistorySession( p_name:String, p_transition:ATransition):void
		{
			super();
			name = p_name;
			transition = p_transition ? p_transition.clone() : new ATransition() ;
		}
		
		public function toString():String{
			return "HistorySession: " + name + " transition: " + transition;
		}
	}
}