/**
 * 
 * @author igor almeida
 * @version 1
 *
 * */
package redneck.util
{
	import flash.events.*;
	import redneck.core.IDisposable;
	/**
	 *	Dispatched when all steps finishes
	 *	@eventType Event.COMPLETE
	 */
	[Event(name="complete", type="flash.events.Event")]
	/**
	 *	Dispatched when the currentStep changes
	 *	@eventType Event.CHANGE
	 */
	[Event(name="change", type="flash.events.Event")]
	
	public class Counter extends EventDispatcher implements IDisposable
	{
		public var totalSteps : uint;
		
		private var _currentStep : uint;
		public function get currentStep  ( ) : uint {return _currentStep}
		public function get stepsRemaining () : int { return totalSteps-currentStep }

		private var _items : Array;
		
		public var onComplete : Function;
		public var onChange : Function;

		public function Counter()
		{
			super( this );
			totalSteps = 0;
			_currentStep = 0;
			_items = new Array ( )
		}
		/**
		 * 
		 * Adiciona um item como step e analiza o <code>toListening</code>
		 * para executar o update 
		 * 
		 * @param	obj			EventDispatcher
		 * @param	toListening	String
		 * 
		 * */
		public function add( obj:EventDispatcher, toListening : String ) : void
		{
			obj.addEventListener( toListening, update, false, 0, true);
			_items.push( [obj, toListening] );
			totalSteps++;
		}
		/**
		 * 
		 * Updates the <code>currentStep</code> and checks whether this count is finished or just udpated
		 * 
		 * */
		public function update( ...rest ) : void
		{
			_currentStep++;
			var evt : Event;
			if ( currentStep >= totalSteps ){
				if ( onComplete!=null ) onComplete( );
				evt = new Event( Event.COMPLETE );
			}
			else{
				if ( onChange!=null ) onChange( );
				evt = new Event(Event.CHANGE);
			}
			dispatchEvent( evt );
		}
		/**
		 * 
		 * resets <code>currentStep</code>
		 * 
		 * */
		public function reset ( ) : void
		{
			_currentStep = 0;
		}
		/**
		*	
		*	Clean all added items (<code>Counter.add</code>) and resets the <code>totalSteps</code>
		*	
		*	@see reset
		*	@see dispose
		* 
		* */
		public function clear( ):void
		{
			reset();
			for each ( var dispatcher : Array in _items ){
				if (dispatcher[ 0 ] && dispatcher[ 1 ]){
					dispatcher[ 0 ].removeEventListener( dispatcher[ 1 ], update );
				}
			}
			_items = new Array();
			totalSteps = 0;
		}
		/**
		*	Diposes this instance
		**/
		public function dispose( ...rest ):void
		{
			clear( );
			onComplete = null;
			onChange = null;
			_items = null;
		}
	}
}