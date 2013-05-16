/**
 * Exemplo de uso
 * Tracking.trackEvent.apply(null, [1,2,3]);
 */

package project_name.tracking
{
	/**
	@author Marcos Roque (mroque@fbiz.com.br)
	*/
	import flash.external.ExternalInterface;
	
	public class Tracking extends Object
	{
	
		public function Tracking()
		{
			super();
		}
		
		public static function trackEvent(... args):void {
			
			args.unshift("PageTracker._trackEvent");
			if(ExternalInterface.available) {
				ExternalInterface.call.apply(null, args);
			} else {
				trace("trackEvent:", args);
			}
		}
		
		public static function trackPageview(... args):void {
			
			args.unshift("PageTracker._trackPageview");
			if(ExternalInterface.available) {
				ExternalInterface.call.apply(null, args);
			} else {
				trace("trackPageview:", args);
			}
		}
		
	}

}