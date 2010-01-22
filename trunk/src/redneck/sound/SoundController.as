/**
 *
 * SoundController é um wrapper para controlar varios Sounditems. 
 *  
 * @author igor almeida
 * @version 0.4
 * @see SoundItem
 * 
 */
package redneck.sound
{
	import br.com.stimuli.loading.BulkLoader;

	import flash.events.*;
	import flash.media.*;
	import flash.utils.*;

	import redneck.core.IDisposable;
	import redneck.events.SoundEvent;
	/**
	*	Dispatched when a new sound goes to active list.
	*	@eventType redneck.events.SoundEvent.LIST_PUSH
	*/
	[Event(name="listPush", type="redneck.events.SoundEvent")]
	/**
	*	Dispatched when a <code>SoundItem</code> is removed from active list.
	*	@eventType redneck.events.SoundEvent.LIST_REMOVE
	*/
	[Event(name="listRemove", type="redneck.events.SoundEvent")]
	/**
	*	Dispatched when the active list become empty.
	*	@eventType redneck.events.SoundEvent.LIST_EMPTY
	*/
	[Event(name="listEmpty", type="redneck.events.SoundEvent")]
	/**
	*	Dispatched when the current <code>status</code> is changed.
	*	@eventType redneck.events.SoundEvent.STATUS_CHANGE
	*/
	[Event(name="statusChange", type="redneck.events.SoundEvent")]
	/**/
	public class SoundController extends EventDispatcher implements IDisposable
	{
		private var _status:String;
		private var _isMute:Boolean = false;
		private var sounds:Dictionary
		private var logLevel:int;
		private var quiet:Boolean = true;
		private var activeItems:Dictionary;
		private var id:String;
		private static var controllers:Dictionary
		public static const STATUS_STOP:String	= "stop";
		public static const STATUS_PAUSE:String	= "pause";
		public static const STATUS_PLAY:String	= "play";
		public static const LOG_ERROR:int = 4;
		public static const LOG_ALL:int = 0;
		/**
		 * 
		 * @param	key String SoundController id
		 * @return SoundController
		 * 
		 */
		public static function getController( key:String ) : SoundController
		{
			if ( !controllers ) 
			{
				controllers = new Dictionary( true );
			}
			return SoundController.controllers[ key ] || null ;
		}
		/**
		 * 
		 * 
		 * @param	key			String	layer name 
		 * @param	isQuiet		Boolean	define if the application will stay quiet or not.
		 * @default true
		 * @param	logLevel	String	define which will be outputed.
		 * @default LOG_ERROR
		 * 
		 */
		public function SoundController( key:String, isQuiet:Boolean = true, logLevel:int = LOG_ERROR):void
		{
			if ( !controllers ) 
			{
				controllers = new Dictionary( true );
			}
			if ( SoundController.controllers[ key ] )
			{
				traceMSG( "a SoundController with id:'"+key+"' already exist", LOG_ERROR );
				return
			}
			this.logLevel = logLevel;
			this.quiet = isQuiet;
			this.id = key;
			this.sounds = new Dictionary( true );
			this.activeItems = new Dictionary( true );
			this.status = STATUS_STOP;
			traceMSG( "SoundController created", LOG_ALL );
			SoundController.controllers[ key ] = this;
		}
		/**
		 * @private
		 *  
		 * add item to activelist
		 * 
		 * @dispatch SoundEvent.LIST_PUSH
		 * 
		 */
		private function addToActiveList(e:Event):void
		{
			var s:SoundItem = (e.currentTarget as SoundItem);
			if (s == null || activeItems[s.id] !=null ) return;
			this.dispatchEvent( new SoundEvent(SoundEvent.LIST_PUSH) );
			activeItems[ s.id ] = s;
			traceMSG( s.id + " is active", LOG_ALL);
		}
		/**
		 * @private
		 * 
		 * remove item from activelist
		 * 
 		 * @dispatch SoundEvent.LIST_REMOVE
 		 * @dispatch SoundEvent.LIST_EMPTY
 		 * 
		 */
		private function removeFromActiveList( e:Event ) : void
		{
			var s:SoundItem = (e.currentTarget as SoundItem);
			if ( s )
			{
				activeItems[ s.id ] = null;
				delete activeItems[ s.id ];
				this.dispatchEvent( new SoundEvent(SoundEvent.LIST_REMOVE) );
				var i:int = 0;
				for each( var tmp:SoundItem in activeItems ) {
					i++;
				}
				if( i==0 ){
					this.dispatchEvent( new SoundEvent(SoundEvent.LIST_EMPTY) );
				}
				traceMSG(s.id + " is inactive.", LOG_ALL);
			}
		}
		/**
		 *	
		 * Play all sounds.
		 * 
		 * @param resetLoops	Boolean 
		 * @default	false
		 * @see SoundItem.play
		 * 
		 */
		public function play( resetLoops:Boolean = false ) : void
		{
			traceMSG("Play all sounds",LOG_ALL);
			for each (var i:SoundItem in sounds)
			{
				i.play( resetLoops );
			}
			this.status = STATUS_PLAY;
		}
		/**
		 * 
		 * Stop all sounds.
		 * 
		 * @param resetLoops	Boolean
		 * @default false
		 * @see SoundItem.stop
		 * 
		 */
		public function stop(resetLoops:Boolean = false):void
		{
			traceMSG("Stop all sounds",LOG_ALL);
			for each (var i:SoundItem in sounds)
			{
				i.stop(resetLoops);
			}
			this.status = STATUS_STOP;
		}
		/**
		 * 
		 * Pause all sounds
		 * 
		 */
		public function pause():void
		{
			traceMSG("Pause all sounds",LOG_ALL);
			for each (var i:SoundItem in sounds)
			{
				i.pause();
			}
			this.status = STATUS_PAUSE;
		}
		/**
		 * 
		 * mute all sounds.
		 * 
		 */
		public function mute():void
		{
			if ( isMute ) return ;
			traceMSG("Mute all sounds",LOG_ALL);
			for each (var i:SoundItem in sounds)
			{
				i.mute();
			}
			this._isMute = true;
		}
		/**
		 * 
		 * unmute all sounds.
		 * 
		 */
		public function unmute():void
		{
			if ( !isMute ) return ;
			traceMSG("Unmute all sounds",LOG_ALL);
			for each (var i:SoundItem in sounds)
			{
				i.unmute();
			}
			this._isMute = false;
		}
		/**
		 * 
		 * Normalize all volumes
		 * 
		 * @param v Number
		 * 
		 */
		public function volume(v:Number):void
		{
			for each (var i:SoundItem in sounds)
			{
				i.volume = v;
			}
		}
		/**
		 * 
		 * Adiciona um novo som a lista.
		 * 
		 * @param	sound	Sound
		 * @param	_obj	Object
		 * @default null
		 * @param	autoRemove	Boolean to set if this sound will be removed from list after complete. 
		 * @default false
		 * @see SoundEvent.VALID_PROPS;
		 * 
		 */
		public function add( sound:Sound, _obj:Object = null, autoRemove:Boolean = false ) : SoundItem
		{
			var obj:Object = _obj;
			if ( (obj != null && sounds[ String( obj.id ) ] is SoundItem) || ( sounds[String(sound)] is SoundItem ) )
			{
				traceMSG("this sound " + sound + " already exist",LOG_ERROR);
				return null;
			}
			try
			{
				var item:SoundItem = new SoundItem( sound, obj );
				if ( this.isMute )
				{
					item.mute();
				}
				sounds[ item.id ] = item;
				item.addEventListener( SoundEvent.SOUND_STOP , removeFromActiveList , false , 0 , true);
				item.addEventListener( SoundEvent.SOUND_PLAY , addToActiveList , false , 0 , true);
				if (autoRemove) 
				{
					item.addEventListener(SoundEvent.SOUND_COMPLETE, removeItem, false, 0, true);
					item.addEventListener(SoundEvent.SOUND_LOOP, removeItem, false, 0, true);
				}
				if (obj != null && obj.autoPlay)
				{
					item.dispatchEvent( new Event(SoundEvent.SOUND_PLAY) );
				}
				traceMSG("new sound: " + item.id + " added!", LOG_ALL);
				return item;
			}
			catch (err:Error)
			{
				traceMSG("error adding new sound: " + err + "\n" + err.getStackTrace(), LOG_ERROR);
			}
			return null;
		}
		/**
		 * @private
		 * 
		 * this method remove a specific item after it complete.
		 * called when "autoRemove" is true.
		 * 
		 * @param	ev
		 * 
		 */
		private function removeItem(ev:Event):void
		{
			var item:SoundItem = ev.currentTarget as SoundItem;
			if (item != null)
			{
				remove( item.id );
			}
		}
		/**
		 * 
		 * return array with all keys
		 * 
		 * @return Array
		 * 
		 */
		public function getKeys( ) : Array
		{
			var arr:Array = new Array;
			for (var i:String in sounds)
			{
				arr.push( sounds[i].id );
			}
			return arr;
		}
		/**
		 * 
		 * remove from sound list.
		 * 
		 * @return Boolean
		 * 
		 */
		public function remove( key:String ) : Boolean
		{
			if (sounds[key] is SoundItem)
			{
				sounds[key].removeEventListener( SoundEvent.SOUND_COMPLETE, removeItem );
				sounds[key].removeEventListener( SoundEvent.SOUND_LOOP, removeItem );
				sounds[key].removeEventListener( SoundEvent.SOUND_STOP , removeFromActiveList );
				sounds[key].removeEventListener( SoundEvent.SOUND_PLAY , addToActiveList );
				sounds[key].dispose();
				sounds[key] = null;
				activeItems[key] = null;
				delete activeItems[ key ]
				delete sounds[ key ];
				traceMSG("sound: " + key + " removed", LOG_ALL);
				return true;
			}
			else
			{
				traceMSG("the key: " + key + "don't exist",LOG_ALL);
				return false;
			}
		}
		/**
		 * 
		 *	clear sound list.
		 * 
		 */
		public function removeAll():void
		{
			for each (var i:SoundItem in sounds)
			{
				i.dispose( );
				remove( i.id );
			}
		}
		/**
		 * 
		 * @return Array
		 * 
		 */
		public function getActiveSounds() : Array
		{
			var arr:Array = new Array();
			for each (var i:SoundItem in activeItems )
			{
				arr.push( i );
			}
			return arr;
		}
		/**
		 * 
		 * 
		 * @param	key String
		 * @return SoundItem
		 * 
		 */
		public function get( key:String ) : SoundItem
		{
			return sounds[ key ];
		}
		/**
		 * 
		 * @return String
		 * 
		 */
		public function get status():String
		{
			return _status;
		}
		/**
		 * 
		 * @return String: current status
		 * 
		 */
		public function set status(s:String):void
		{
			_status = s;
			dispatchEvent( new Event(SoundEvent.STATUS_CHANGE) );
		}
		/**
		 * 
		 * @return Boolean
		 * 
		 */
		public function get isMute():Boolean
		{
			return this._isMute;
		}
		/**
		 * 
		 * stop all sounds and disposes them
		 * 
		 */
		public function dispose( ...rest ):void
		{
			removeAll();
			this._isMute = false;
			sounds = null;
			SoundController.controllers[ id ] = null;
			delete SoundController.controllers[ id ];
		}
		/**
		 * @private
		 * 
		 * output internal messages for debug
		 * @param	msg		String	message to trace
		 * @param	level	int		output logLevel level
		 * @default
		 * 
		 */
		private function traceMSG(msg:*, level:int = 0 ):void
		{
			if ( !quiet && level >= logLevel )
			{
				trace( "[ SoundController ] "+id+ ": " + msg );
			}
		}
	}	
}