/**
 * 
 * @author igor almeida
 * @version 0.3
 * 
 * BasePreloader is a simple preloader model to use
 * for any kind of loader. The advantage to use this 
 * class is because it's integrated with <code>RatioLoader</code>
 * and <code>BulkLoader</code> events.
 *  
 * */
package redneck.core
{
	import br.com.stimuli.loading.BulkProgressEvent;
	import flash.events.*;
	import redneck.util.*;
	import redneck.events.*;
	public class BasePreloader extends BaseDisplay implements IPreloader
	{
		/**
		 * 
		 * */
		public function BasePreloader()
		{
			super();
		}
		/**
		 * 
		 * destroy preloader listeners.
		 * 
		 * @param	e	*
		 *  
		 * */
		public override function destroy(e:*=null):void
		{
			super.destroy();
		}
		/**
		 * 
		 * catches percent from RatioLoader when it changes.
		 * 
		 * @param	e	*
		 * 
		 * */
		public function change( e : Event ) : void
		{
			if( e is RatioEvent ){ 
				percent = RatioLoader( e.currentTarget ).percent;
			}
			else if( e is BulkProgressEvent ){ 
				percent = BulkProgressEvent( e ).weightPercent;
			}
			else if( e is ProgressEvent ){ 
				percent = ProgressEvent( e ).bytesLoaded / ProgressEvent( e ).bytesTotal;
			}
		}
		/**
		 * 
		 * sets the current percent
		 * 
		 * @param p Number
		 * 
		 * */
		internal var _percent:Number;
		public function set percent( p:Number ):void
		{
			_percent = p;
		}
		/**
		 * 
		 * Return the current percent
		 * 
		 * @return Number
		 * 
		 * */
		public function get percent( ):Number
		{
			return _percent;
		}
	}
}