/**
 *	@author igor almeida
 *	@version 0.9
 * 
 */
package redneck.sound
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.media.*;
	
	import redneck.events.SoundEvent;
	import redneck.core.IDisposable;
	/**
	 *	Dispatched when sound complete.
	 *	@eventType redneck.events.SoundEvent.SOUND_COMPLETE
	 */
	[Event(name="soundComplete", type="redneck.events.SoundEvent")]
	/**
	 *	Dispatched when sound loop.
	 *	@eventType redneck.events.SoundEvent..SOUND_LOOP
	 */
	[Event(name="soundLoop", type="redneck.events.SoundEvent")]
	/**
	 *	Dispatched when sound start.
	 *	@eventType redneck.events.SoundEvent..SOUND_PLAY
	 */
	[Event(name="soundPlay", type="redneck.events.SoundEvent")]
	/**
	 *	Dispatched when sound stop.
	 *	@eventType redneck.events.SoundEvent..SOUND_STOP
	 */
	[Event(name="soundStop", type="redneck.events.SoundEvent")]
	/**
	 *	Dispatched when sound pause.
	 *	@eventType redneck.events.SoundEvent..SOUND_PLAUSE
	 */
	[Event(name="soundPause", type="redneck.sound.SoundEvent")]
	/**/
	public class SoundItem extends EventDispatcher implements IDisposable
	{
		private var _status:String;
		private var _id:String;
		private var _volume:Number = 1;
		private var _pan:Number = 0;
		private var _leftToLeft:Number = 1;
		private var _leftToRight:Number = 1;
		private var _rightToLeft:Number = 1;
		private var _rightToRight:Number = 1;
		private var _loops:int = 0;
		private var _isMute:Boolean = false;
		private var _startTime:Number = 0;
		private var _startProperties:Object;
		
		private var sound:Sound;
		private var muteVol:Number = 1;
		private var autoPlay:Boolean = false;
		private var channel:SoundChannel;
		private var play_count:int = 0;
		private var soundTransform:SoundTransform;
		private var lastPosition:Number = 0;
		
		public static const STATUS_STOP:String = "stop";
		public static const STATUS_PAUSE:String = "pause";
		public static const STATUS_REPEAT:String = "repeat";
		public static const STATUS_PLAY:String = "play";
		public static const VALID_STATUS:Array = [STATUS_PLAY,STATUS_STOP,STATUS_PAUSE,STATUS_REPEAT];
		public static const VALID_PROPS:Array = ["id", "startTime", "loops", "volume", "pan", "autoPlay", "rightToRight", "rightToLeft", "leftToLeft", "leftToRight"];
		
		/**
		 *	
		 * SoundItem
		 *  
		 * @param	file	:	Sound
		 * @param	obj		:	Object. See SoundItem.VALID_PROPS
		 * @defaul null
		 * 
		 * @example
		 * 
		 * var item : SoundItem = new SoundItem (new LinkageLibSound() , { id: "mouseOver", volume:.8, autoPlay:true } };
		 * item.play();
		 * 
		 */
		public function SoundItem( file:Sound , obj:Object = null ) : void
		{
			this.sound = file;	
			this._startProperties = obj;
			if( obj != null )
			{
				for (var i:String in obj) 
				{
					if ( VALID_PROPS.indexOf( i, 0 ) == -1)
					{
						trace("! [SoundItem] incosistent object param '" + i + "'. Check the allowed properties in SoundItem.VALID_PROPS ");
					}
					else
					{
						this[ i ] = obj[ i ];
					}
				}
			}
			if ( this.id == null)
			{
				this.id = String( this.sound );
			}
			this._status = STATUS_STOP;
			this.play_count = this.loops;
			if ( this.autoPlay )
			{
				play( true );	
			}
		}
		/**
		 * 
		 *	Stop sound.
		 * 
		 * @param	resetLoops	Boolean	This flag clear the loop count (if have one).
		 * @default false
		 * @return	Boolean
		 * 
		 */
		public function stop( resetLoops:Boolean = false ) : Boolean
		{
			if( this.channel != null && this.status != STATUS_STOP )
			{
				this.channel.stop( );
				this.lastPosition = 0;
				if ( resetLoops )
				{
					this.play_count = this.loops;
				}
				this._status = STATUS_STOP;
				this.dispatchEvent( new SoundEvent(SoundEvent.SOUND_STOP) );
				return true;
			}
			return false;
		}
		/**
		 * 
		 * Play sound. If the current status is <code>STATUS_PAUSE</code> the sound will 
		 * continue from the last position.
		 * 
		 * @param	resetLoops 	Boolean		This flag clear the loop count (if have one).
		 * @default	false
		 * @param	overPlay	Boolean		This flag play again a sound without wait to complete.
		 * @default	false
		 * @return Boolean
		 * 
		 */
		public function play( resetLoops:Boolean = false, overPlay:Boolean = false ) : Boolean
		{
			if (this.status == STATUS_PLAY && !overPlay )
			{
				return false;
			}
			var pos:Number =  this.lastPosition >= 0 ? this.lastPosition : this.startTime;
			this.channel = this.sound.play( pos , 0 , setTransform( this.volume, this.pan ) );
			this.channel.addEventListener( Event.SOUND_COMPLETE, repeat, false, 0, true );
			if( resetLoops )
			{
				this.play_count = this._loops;
			}
			this.dispatchEvent( new SoundEvent(SoundEvent.SOUND_PLAY) );
			lastPosition = 0;
			this._status = STATUS_PLAY;
			return true;
		}
		/**
		 * 
		 * Pause sound.
		 * 
		 * @return Boolean
		 * 
		 */
		public function pause():Boolean
		{
			if( this.channel != null && ( this.status == STATUS_PLAY || this.status == STATUS_REPEAT ) )
			{
				this.lastPosition = this.channel.position;
				this.channel.stop();
				this._status = STATUS_PAUSE;
				this.dispatchEvent( new SoundEvent(SoundEvent.SOUND_PAUSE) );
				return true;
			}
			return false;
		}
		/**
		 * 
		 * Seek the playhead to a specific position.
		 * 
		 * @param	pos			Number		reperesents the percent position. this number must be between 0 and 1.
		 * @param	seekAndPlay	Boolean		define if the sound will be start after change the playhead position.
		 * @default	false
		 * @return Boolean
		 * 
		 */
		public function seek( pos:Number, seekAndPlay:Boolean = false):Boolean
		{
			if ( !this.channel ) 
			{
				return false;
			}
			pause( );
			this.lastPosition = Math.max( 0 , Math.min( pos , 1 ) ) * this.sound.length;
			if ( seekAndPlay )
			{
				return play( );
			}
			return true;
		}
		/**
		 * @private
		 * 
		 * Repeat is a private method to manage sound loops.
		 * 
		 * @param	ev Event
		 * 
		 */
		private function repeat( ev:Event ) : void
		{
			if( this.play_count<=0 || this.loops<=0 )
			{
				this.sound.removeEventListener( Event.SOUND_COMPLETE, repeat );
				this.dispatchEvent( new SoundEvent(SoundEvent.SOUND_COMPLETE) );
				stop( );
			}
			else
			{
				this.play_count--;
				this._status = STATUS_REPEAT;
				this.dispatchEvent( new SoundEvent(SoundEvent.SOUND_LOOP) );
				play( );
			}
		}
		/**
		 * 
		 * Mute sound. When mute a sound, the current volume is set to 0 and the sound still playing.
		 * To unmute the sound, only <code>unmute</code> may solve your issue.
		 * 
		 * @return Boolean
		 * 
		 */
		public function mute( ):Boolean
		{
			if ( this.isMute || !this.channel )
			{
				return false;	
			}
			this.muteVol = this.volume;
			this.volume = 0;
			this._isMute = true;
			return true;
		}
		/**
		 * 
		 * Unmute sound. Reative the volume.
		 * 
		 * @return Boolean
		 * 
		 */
		public function unmute():Boolean
		{
			if ( !this.isMute || !this.channel )
			{
				return false;
			}
			this._isMute = false;
			this.volume = this.muteVol;
			return true;
		}
		/**
		 * @private
		 * 
		 * set the startTime
		 * 
		 * more in http://livedocs.adobe.com/flex/2/langref/index.html?flash/media/SoundTransform.html&flash/media/class-list.html
		 * 
		 */
		private function set startTime(t:Number):void
		{
			this._startTime = isNaN(t)? 0 : Math.min(t, this.sound.length);
		}
		/**
		 * @private
		 * 
		 * @return startTime
		 * 
		 */
		private function get startTime():Number
		{
			return this._startTime;
		}
		/**
		 * 
		 * Changes the sound volume. This setter works in many environment.
		 * If the sound never play yet, will change the inicial volume.
		 * If the sound is playing, will change the channel volume.
		 * if the sound is mute, will change the stored volume when become mute.
		 * 
		 * @param vol between 0 and 1.
		 * 
		 */
		public function set volume(vol:Number):void
		{
			vol = isNaN(Number(vol))? 1 : Number(vol);
			vol = Math.min(vol, 1);
			vol = Math.max(vol, 0);
			if (this.channel != null && !isMute)
			{
				this.channel.soundTransform = setTransform(vol, this.pan);
			}
			else if (this.channel != null && isMute)
			{
				this.muteVol = vol;
			}
			else
			{
				this._volume = vol;
			}
		}
		/**
		 * 
		 * return the current volume.
		 * 
		 * @return vol between 0 and 1.
		 * 
		 */
		public function get volume():Number 
		{
			if (this.channel != null && !isMute)
			{
				return this.channel.soundTransform.volume;
			}
			else if (this.channel != null && isMute)
			{
				return this.muteVol;
			}
			return this._volume;
		}
		/**
		 * 
		 * this is just a simple wraper to change the current pan or 
		 * change the inicial pan (if the sound don't start yet)
		 * 
		 * @param p	Number	between -1 and 1.
		 * 
		 */
		public function set pan(p:Number):void
		{
			if (this.channel != null) this.channel.soundTransform = setTransform(this.volume, p);
			else this._pan = p;
		}
		/**
		 * 
		 * Get the current pan. 
		 * If no channel exist, the returned pan is the initial pan.
		 * 
		 * @return <code>Number</code>
		 * 
		 */
		public function get pan():Number
		{
			if (this.channel != null) return this.channel.soundTransform.pan;
			return this._pan;
		}
		/**
		 * 
		 * this is just a simple wraper to change the current leftToLeft or 
		 * change the inicial leftToLeft (if the sound don't start yet)
		 * 
		 * @param p	Number	between 0 and 1.
		 * 
		 */
		public function set leftToLeft(p:Number):void
		{
			this._leftToLeft = p;
			if (this.channel != null) this.channel.soundTransform = setTransform(this.volume, p);
		}
		/**
		 * 
		 * Get the current leftToLeft.
		 *  
		 * @return <code>Number</code>
		 * 
		 */
		public function get leftToLeft():Number
		{
			return this._leftToLeft;
		}
		/**
		 * 
		 * this is just a simple wraper to change the current leftToRight or 
		 * change the inicial leftToRight(if the sound don't start yet)
		 * 
		 * @param p	Number	between 0 and 1.
		 * 
		 */
		public function set leftToRight(p:Number):void
		{
			this._leftToRight = p;
			if (this.channel != null) this.channel.soundTransform = setTransform(this.volume, this.pan);
		}
		/**
		 * 
		 * Get the current leftToRight.
		 *  
		 * @return <code>Number</code>
		 * 
		 */
		public function get leftToRight():Number
		{
			return this._leftToRight;
		}
		/**
		 * 
		 * this is just a simple wraper to change the current rightToLeft
		 * change the inicial rightToLeft(if the sound don't start yet)
		 * 
		 * @param p	Number	between 0 and 1.
		 * 
		 */
		public function set rightToLeft(p:Number):void
		{
			this._rightToLeft = p;
			if (this.channel != null) this.channel.soundTransform = setTransform(this.volume, this.pan);
		}
		/**
		 * 
		 * Get the current rightToLeft. 
		 * If no channel exist, the returned pan is the initial rightToLeft.
		 * 
		 * @return <code>Number</code>
		 * 
		 */
		public function get rightToLeft():Number
		{
			return this._rightToLeft;
		}
		/**
		 * 
		 * this is just a simple wraper to change the current rightToRight
		 * change the inicial rightToRight(if the sound don't start yet)
		 * 
		 * @param p	Number	between 0 and 1.
		 * 
		 */
		public function set rightToRight(p:Number):void
		{
			this._rightToRight = p;
			if (this.channel != null) this.channel.soundTransform = setTransform(this.volume, this.pan);
		}
		/**
		 * 
		 * Get the current rightToRight.
		 *  
		 * @return <code>Number</code>
		 * 
		 */
		public function get rightToRight():Number
		{
			return this._rightToRight;
		}
		/**
		 * 
		 * Set the amount of loop.
		 * 
		 * @param n
		 * 
		 */
		public function set loops(n:int):void
		{
			this._loops = n;
		}
		/**
		 * 
		 * @return amount of loops.
		 * 
		 */
		public function get loops():int
		{
			return this._loops;
		}
		/**
		 * 
		 * set the sound id.
		 * 
		 * @param s
		 *  
		 */
		public function set id(s:String):void
		{
			this._id = s; 
		}
		/**
		 * 
		 * @return instance id.
		 * 
		 */
		public function get id():String
		{
			return this._id;
		}
		/**
		 * @private
		 * 
		 * 
		 * @param	vol
		 * @param	pan
		 * @return SoundTransform
		 * 
		 */
		private function setTransform( vol:Number, pan:Number ) : SoundTransform
		{
			this.soundTransform = new  SoundTransform(this.isMute ? 0 : vol, this.pan);
			this.soundTransform.leftToLeft = this.leftToLeft;
			this.soundTransform.leftToRight = this.leftToRight;
			this.soundTransform.rightToLeft = this.rightToLeft;
			this.soundTransform.rightToRight = this.rightToRight;
			return this.soundTransform;
		}
		
		/******************************************************************************************
		 * READY ONLY
		 ******************************************************************************************/
		
		/**
		 * 
		 * @return the original properties passed on contructor.
		 * 
		 */
		public function get startProperties():Object
		{
			return this._startProperties;
		}
		/**
		 * 
		 * @see SoundItem.VALID_STATUS
		 * @return <code>String</code>
		 * 
		 */
		public function get status():String
		{
			return this._status;
		}
		/**
		 * 
		 * current position.
		 * @return <code>Number</code>
		 * 
		 */
		public function get position():Number
		{
			if (this.channel != null) return this.channel.position;
			return 0;
		}
		/**
		 * 
		 * current sound duration in miliseconds.
		 * @return <code>Number</code>
		 * 
		 */
		public function get duration():Number
		{
			return this.sound.length;
		}
		/**
		 * 
		 * get percent played.
		 * @return <code>Number</code>
		 * 
		 */
		public function get percent():Number
		{
			return  this.position / this.duration ;
		}
		/**
		 * 
		 * remaining loops
		 * @return <code>int</code>
		 * 
		 */
		public function get loopsRemaining():int
		{
			return this.play_count;
		}
		/**
		 * 
		 * return if sound is mute.
		 * 
		 */
		public function get isMute():Boolean
		{
			return _isMute;
		}
		/**
		 * 
		 * @return ID3Info.
		 * 
		 */
		public function get id3():ID3Info
		{
			return this.sound.id3;
		}
		/**
		 * 
		 * stop sound and dispose this item
		 * 
		 * @return Boolean
		 * 
		 */
		public function dispose( ...rest ):void
		{
			stop( true );
			this.sound.removeEventListener(Event.SOUND_COMPLETE,repeat);
			this.channel = null;
			this.soundTransform = null;
		}
		/**
		 * 
		 * 	Return a report.
		 * 
		 *	@return	String
		 * 
		 */
		public function report():String
		{
			var str:String = "[SoundItem] :";
			str += "\n - id: '" + this.id+"'";
			str += "\n - status: " + this.status;
			str += "\n - isMute: " + this.isMute;
			str += "\n - volume: " + this.volume;
			str += "\n - pan: " + this.pan;
			str += "\n - leftToLeft: " + this.leftToLeft;
			str += "\n - leftToRight: " + this.leftToRight;
			str += "\n - rightToLeft: " + this.rightToLeft;
			str += "\n - rightToRight: " + this.rightToRight;
			str += "\n - duration: " + this.duration +" miliseconds.";
			str += "\n - position: " + ((this.channel==null)? 'channel not created' : this.channel.position) + ' miliseconds';
			str += "\n - percent: " +  this.percent + '%';
			str += "\n - loops: " + this.loops;
			str += "\n - loops remaining: " + this.loopsRemaining;
			str += "\n";
			return str;
		}
		/**
		 * 
		 * the class name and current id.
		 * 
		 * @return String
		 * 
		 */
		public override function toString():String
		{
			return "[SoundItem '"+this.id+"']"; 
		}
	}	
}