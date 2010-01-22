/**
* @author igor almeida
* @version 1.0
* @see KeyWatch
*
* KeyboardAnalyser was designed to help managing the keyboard activity. 
* The design is pretty simples and useful.
* @usage
*
* //example 1
* var k : KeyboardAnalyser = new KeyboardAnalyser(stage);
* k.start();
* k.isPressed(Keyboard.SPACE) // just return is this button is pressed.
* k.getPressedList() // return all pressed buttons.
*
* // example 2
* var k : KeyboardAnalyser = new KeyboardAnalyser(stage);
* k.start();
*
* // monitoring the activity for a specific key
* var w : KeyWatch = k.watch(Keyboard.SPACE);
*  // at each 1.5 seconds pressed the KeyWatch instance will be runs onDelay callback or dispatchs the KeyWatch.ON_DELAY event;
* w.delay = 1.5;
* w.onDelay = funcDoSomething;

* // at each 2 times pressed the KeyWatch instance will be runs onCounter callback or dispatchs the KeyWatch.ON_COUNTER event;
* w.counter = 2
* w.onCounter = funcDoOtherThing;
* 
**/
package redneck.keyboard
{
	import flash.events.*;
	import flash.display.*;
	import flash.utils.*;
	import flash.ui.*;
	public class KeyboardAnalyser extends EventDispatcher
	{
		private var watching : Dictionary;
		private var pressed : Dictionary;
		private var stage : Stage;
		private var currentTime : int;
		/**
		* 
		* KeyboardAnalyser was designed to help managing the keyboard activity
		* 
		* @param p_stage;
		* 
		**/
		public function KeyboardAnalyser( p_stage:Stage )
		{
			super();
			stage = p_stage;
			watching = new Dictionary(true);
			pressed = new Dictionary(true);
		}
		/**
		* start monitoring all keyboard activity
		**/
		public function start( e:*=null ):void{
			stage.addEventListener( KeyboardEvent.KEY_DOWN, check );
			stage.addEventListener( KeyboardEvent.KEY_UP, check );
		}
		/**
		* stop monitoring all keyboard activity
		**/
		public function stop(e:*=null):void{
			stage.removeEventListener( KeyboardEvent.KEY_DOWN, check );
			stage.removeEventListener( KeyboardEvent.KEY_UP, check );
		}
		/**
		* internal checking for keyboard activity.
		**/
		private function check( e:KeyboardEvent ):void{
			currentTime = getTimer( );
			if (e.type == KeyboardEvent.KEY_DOWN){
				pressed[e.keyCode] = true;
				var code : String;
				for ( code in pressed ){
					if ( isWatching( int(code) ) ){
						getKeyWatch( int(code) ).updateStatus( e.type,currentTime );
					}
				}
			}
			else{
				pressed[ e.keyCode ] = null;
				delete pressed[ e.keyCode ];
				if (isWatching(e.keyCode)){
					getKeyWatch(e.keyCode).updateStatus(e.type,currentTime);
				}
			}
		}
		/**
		* 
		* Add <code>p_key</code> on the watching list and returns an KeyWatch instance 
		* to monitore in detail all behaviors with that key.
		* 
		* The <code>p_key</code> is dynamic to allow the programmer to choose the better way to
		* do both <code>int</code> or <code>KeyWatch</code>.
		* 
		* @param	p_key	*	int or KeyWatch
		* @param	p_delay	uint
		* 
		* @see unwatch
		* @see isWatching
		* @see getWatchingList
		* 
		* @usage
		* //example 1
		* 	var k : KeyboardAnalyser = new KeyboardAnalyser(this.stage);
		*		k.start()
		* 
		* 	var w : KeyWatch = k.watch(Keyboard.SPACE, 0, 5);
		* 		w.onCounter = function(p:KeyWatch):void{ trace( p+"has pressed 5 times"); }
		* 
		* //example 2
		* 	var k : KeyboardAnalyser = new KeyboardAnalyser(this.stage);
		*		k.start()
		* 
		* 	var w : KeyWatch = new KeyWatch(Keyboard.SPACE, 0, 5);
		* 		w.onCounter = function(p:KeyWatch):void{ trace( p+"has pressed 5 times"); }
		* 		k.watch(w);
		* 
		* @return	KeyWatch
		* 
		**/
		public function watch ( p_key:*, p_delay:Number = 0, p_counter:int = 0 ) : KeyWatch {
			currentTime = getTimer( );
			if ( p_key is KeyWatch ){
				watching[p_key.key] = p_key;
				return p_key;
			}
			else if ( p_key is int ){
				if (isWatching(p_key)){
					unwatch(p_key);
				}
				watching[p_key] = new KeyWatch(p_key, p_delay, p_counter);
				return watching[p_key] as KeyWatch;
			}
			return null;
		}
		/**
		* 
		* stop watching this key
		* 
		* @param	p_key	int or KeyWatch
		* 
		* @result	Boolean
		* 
		**/
		public function unwatch( p_key:* ):Boolean{
			var result : Boolean
			var k : int;
			if ( p_key is KeyWatch ){
				k = p_key.key;
			}else{
				k = p_key;
			}
			result = isWatching(k);
			if (result){
				watching[k].destroy();
				watching[k] = null;
				delete watching[k];
			}
			return result;
		}
		/**
		* Just a small report about the keyboard status
		* @return String
		*/
		public function report():String{
			return "------\n-pressed list:\n"+getPressedList().join("\n")+"\n-watching list:\n"+getWatchingList().join("\n")+"\n------\n";
		}
		/**
		* @return Boolean
		**/
		public function isPressed( p_key:int ):Boolean{
			return pressed[p_key]!=null;
		}
		/**
		* @return Array
		**/
		public function getPressedList():Array{
			var result:Array = [];
			for (var k:String in pressed){
				result.push(int(k));
			}
			return result;
		}
		/**
		* @return Array
		**/
		public function getWatchingList():Array{
			var result:Array = [];
			var k:KeyWatch
			for each( k in watching){
				result.push(k);
			}
			return result;
		}
		/**
		* @param p_key	int
		* @return KeyWatch
		**/
		public function getKeyWatch(p_key:int):KeyWatch{
			return isWatching(p_key) ? watching[p_key] as KeyWatch : null;
		}
		/**
		* @param	p_key	int
		* @return	Boolean	
		**/
		public function isWatching(p_key:int):Boolean{
			return (watching[p_key]!=null);
		}
		/**
		* clear all.
		**/
		public function destroy():void{
			for each(var k:KeyWatch in watching){
				unwatch(k.key);
			}
			pressed = null;
			watching = null;
		}
	}
}