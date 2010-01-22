package redneck.project.log 
{
	import redneck.events.LogEvent;
	import flash.events.Event;
	import flash.system.Capabilities;
	import flash.events.EventDispatcher;
	public class LogHistory extends EventDispatcher
	{
		private var event :  LogEvent;
		private var dt : Date;
		private var type: *
		private var message : *
		public function add( ...rest ):void
		{
			message = rest is Array ? rest.join("") : rest;
			if( rest.length==0 ){
				return;
			}
			else if( rest.indexOf(LogEvent.ERROR)>-1 ){
				event = new LogEvent( LogEvent.ERROR );	
			}
			else if( message.indexOf( LogEvent.VERBOSE ) >- 1 ) {
				event = new LogEvent( LogEvent.VERBOSE );
			}
			else{
				event = new LogEvent( LogEvent.VERBOSE );	
			}
			message = message.replace(LogEvent.ERROR,"").replace(LogEvent.VERBOSE,"");
			event.text = getTimeStamp() + ": " + getStack() + " - " + message ;
			dispatchEvent( event );
		}
		/**
		 * 
		 * override to dispatch event only if have somebody listening
		 * 
		 * @param event	Event
		 * @return Boolean
		 * 
		 * */
		public override function dispatchEvent(event:Event):Boolean
		{
			if ( event!=null ){
				return super.dispatchEvent( event );
			}
			return false;
		}
		/**
		*	
		**/
		public function getTimeStamp():String
		{
			dt = new Date();
			return "["+dt.getHours() + ":" + dt.getMinutes() + ":"+dt.getSeconds()+"]";
		}
		/**
		*	
		**/
		public function getStack():String
		{
			var result : String = ""
			if ( Capabilities.isDebugger){
				var stack : Array = new Error().getStackTrace().split( /\n/ )
				if ( stack.length < 6 ){
					return result;
				}
				var toClean : String;
					toClean = stack[5];
					toClean = toClean.slice( toClean.indexOf(" "), toClean.indexOf("[") );
					toClean = toClean.replace("(","").replace(")","").replace("/", ".").replace("$", ".");
				var className : Array = toClean.split("::");
				toClean = className.length>1 ? className[1].toString() : className.join().replace(" ","");
			}
			else{
				"[non-debugg]";
			}
			
			return toClean
		}
	}
}