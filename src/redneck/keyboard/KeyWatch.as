/**
* @author igor almeida
* @version 1.0
* @see KeyboardAnalyser

* KeyWatch was designed to manage the keyboard activity for a specific key.
* The class have support for callback function and/or listener control.
* 
* var k : KeyWatch = new KeyWatch(0)
* k.onDelay = callbackFunction
* k.onPress = callbackFunction
* k.onRelease = callbackFunction
* k.onCounter = callbackFunction
* k.addEventListener( KeyboardEvent.KEY_UP, listennerCallback )
* k.addEventListener( KeyboardEvent.KEY_DOWN, listennerCallback)
* k.addEventListener( KeyWatch.ON_DELAY, listennerCallback )
* k.addEventListener( KeyWatch.ON_COUNTER, listennerCallback )
* 
* function callbackFunction(o:KeyWatch):void{
* 	trace(o);
* }
* 
* function callbackFunction(o:Event):void{
* 	trace(o.tye,o.currentTarget);
* }
*
**/
package redneck.keyboard
{	
	import flash.events.*;
	[Event(name="keyUp", type="flash.events.KeyboarEvent")]
	[Event(name="keyDown", type="flash.events.KeyboarEvent")]
	[Event(name="onDelay", type="redneck.keyboard.KeyWatch")]
	[Event(name="onCounter", type="redneck.keyboard.KeyWatch")]
	public class KeyWatch extends EventDispatcher
	{
		/**
		* is called after <code>delay</code> seconds pressed.
		* @see delay
		**/
		public var onDelay : Function;
		/** 
		* is called whe the button is pressed
		* @see KeyboardEvent.KEY_DOWN
		**/
		public var onPress : Function;
		/**
		* is called whe the button is release 
		* @see KeyboardEvent.KEY_UP 
		* */
		public var onRelease : Function;
		/**
		* is called after <code>counter</code> times pressed.
		* @see counter
		**/
		public var onCounter : Function;
		/** 
		* define a number of times to monitore when this key was pressed
		* @see timesPressed
		* @see onCounter
		**/
		public var counter :Number;
		/**
		* check if this key was pressed for a specific time. 
		* the time is measured in seconds.
		* @see onDelay
		* @see pressedTime
		**/
		public var delay : Number;
		private var _evtPress : Event;
		private var _evtRelease : Event;
		private var _evtDelay : Event;
		private var _evtCounter : Event;
		private var _key : int;
		private var _currentTime:int;
		private var _pressedTime:int;
		private var _timesPressed : int;
		private var _pressedOffset : int;
		private var _enableCounter : Boolean;
		private var _enableTimer : Boolean;
		public static const ON_DELAY : String = "onDelay";
		public static const ON_COUNTER : String = "onCounter";
		/**
		* 
		* @param	p_key	int
		* @param	p_time	int	creating moment
		* @param	p_delay	int	trigger "onDelay" after this time
		* 
		**/
		public function KeyWatch( p_key:int, p_delay:Number=0, p_counter:Number=0 ) : void
		{
			super();
			_key = p_key;
			delay = p_delay;
			counter = p_counter;
			_currentTime = 0;
			_evtRelease = new Event(KeyboardEvent.KEY_UP,true);
			_evtPress = new Event(KeyboardEvent.KEY_DOWN,true);
			_evtDelay = new Event(ON_DELAY,true);
			_evtCounter = new Event(ON_COUNTER,true);
			_enableCounter = true;
			_enableTimer = true;
		}
		/**
		* the monitored key.
		* @return int 
		**/
		public function get key():int
		{
			return _key;
		}
		/**
		* return the number of times which this button was pressed
		* @return Number
		**/
		public function get timesPressed():Number
		{
			return _timesPressed;
		}
		/**
		* reset counter and flags
		**/
		internal function reset():void{
			_currentTime = 0;
			_pressedTime = 0;
			_enableTimer = true
		}
		/**
		* return the number in seconds which this button was pressed.
		* @return Number
		**/
		public function get pressedTime():Number
		{
			return _pressedTime*.001;
		}
		/**
		* update key status and the time.
		**/
		internal function updateStatus( p_status : String, p_time : Number):void{
			if (p_status == KeyboardEvent.KEY_DOWN){
				if (_enableTimer){
					_currentTime = p_time;
					_enableTimer = false
				}else{
					_pressedTime += p_time - _currentTime;
				}
				if (onPress!=null){
					onPress.apply(null,[this]);
				}else{
					dispatchEvent(_evtPress)
				}
				if (delay>0 && pressedTime>=delay){
					if(onDelay!=null){
						onDelay.apply(null,[this]);
					}else{
						dispatchEvent(_evtDelay);
					}
					reset();
				}
				_currentTime = p_time;
				if (_enableCounter){
					_timesPressed++;
					_enableCounter = false;
				}
				if (counter>1 && (_timesPressed-_pressedOffset)==counter){
					if (onCounter!=null){
						onCounter.apply(null,[this]);
					}else{
						dispatchEvent(_evtCounter);
					}
					_pressedOffset = _timesPressed;
				}
			}
			else{
				reset();
				if (onRelease!=null){
					onRelease.apply(null,[this]);
				}else{
					dispatchEvent(_evtRelease)
				}
				_enableCounter = true;
			}
		}
		/**
		* thanks gskinner for the optimization code.
		* @see http://www.gskinner.com/blog/archives/2008/12/making_dispatch.html
		**/
		override public function dispatchEvent(evt:Event):Boolean {
		 	if (hasEventListener(evt.type) || evt.bubbles) {
		  		return super.dispatchEvent(evt);
		  	}
		 	return true;
		}
		/**
		* clear all.
		**/
		public function destroy():void{
			_evtPress = null;
			_evtRelease = null;
			_evtDelay = null;
			_evtCounter = null;
		}
		/**
		* @return String
		**/
		public override function toString():String{
			return "[KeyWatch key:"+key+" pressedTime:"+pressedTime+" secs and "+_timesPressed+" timesPressed.]";
		}
	}
}