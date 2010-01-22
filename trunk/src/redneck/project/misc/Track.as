/**
 *	@autor igor almeida 
 *	@version 0.4
 *	@usage
 *	<p>
 *	
 *		Track.defaultJSFunction = "myTrackerFunction";
 *		Track.defaultPrefix = "redneck/";
 *		Track.xmlTrack = <root><item name="test">this project is powered by %(name)s</item></root>;
 * 		
 * 		Track.it("init") // myTrackerFunction('init')
 * 		Track.it("test", {name:'redneck'} ) // myTrackerFunction('this project is powered by redneck')
 *	
 *	</p>
 */
package redneck.project.misc
{
	import br.com.stimuli.string.printf;
	
	import flash.external.ExternalInterface;
	import flash.net.URLRequest;
	import flash.net.navigateToURL;
	import flash.system.Capabilities;
	public class Track
	{
		public static var quiet : Boolean = false;
		public static var xmlTrack : XML;
		public static var defaultPrefix : String = "/";
		public static var defaultJSFunction : String;
		/**
		 * This class uses the <code>printf</code> by arthur debert, hosted in http://code.google.com/p/printf-as3/.
		 * By the way, use only <code>Object</code> to replace your hash, this issue will be fix in the future.  
	 	 * @param hash	String value to track
		 * @param args	arguments to be replaced
		 * @return Boolean true if the track has been sent successfully or false.
		 * @see http://code.google.com/p/printf-as3/
		 */
		private static var trackValue:String;
		public static function it( hash:String, args:*=null ) : Boolean
		{
			if( defaultJSFunction == null )
			{
				trace ( "[Track] the <code>defaultJSFunction</code> must be setted! The '"+hash+"' has not tracked." );
				return false;
			}
			
			if( xmlTrack )
			{	
				trackValue = xmlTrack.item.( @name == hash ).toString( )
				trackValue = (trackValue == null || trackValue.length == 0 ) ?  hash : trackValue;
			} 
			else
			{
				trackValue = hash;
			}
			try
			{
				var toSend : String = defaultPrefix;
				if(args)
				{
					toSend += printf( trackValue, args);	
				}
				else
				{
					toSend += trackValue;
				}
				if( Capabilities.playerType=="PlugIn" || Capabilities.playerType=="ActiveX" )
				{
					if( ExternalInterface.available == true )
					{
						ExternalInterface.call( defaultJSFunction , [ toSend ] );
					}
					else
					{
						navigateToURL( new URLRequest( "javascript:"+defaultJSFunction+"('"+toSend+"')" ) );
					}
				}
				/* just a debbug log. */ 
				if( !quiet )
				{
					trace( "[Track.it] " , defaultJSFunction +"('"+ toSend +"')" );
				}
				return true;
			}
			catch ( e:Error )
			{
				trace( " [Track] error: " + e.getStackTrace() );
			}
			return false;
		}
		
	}

}