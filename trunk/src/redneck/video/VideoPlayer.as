/**
* @author igor almeoda
* @version 1.0
* @TODO
* - test cuepoint and other metadata
* - test runtime reisze
**/
package redneck.video
{
	import flash.media.SoundTransform;
	import flash.display.*;
	import flash.events.*;
	import flash.net.*;
	import flash.media.*;
	import redneck.events.*;

	[Event(name="videoLoadComplete", type="redneck.events.VideoEvent")]
	[Event(name="videoComplete", type="redneck.events.VideoEvent")]
	[Event(name="videoMetadata", type="redneck.events.VideoEvent")]
	[Event(name="videoLoop", type="redneck.events.VideoEvent")]
	
	
	[Event(name="NetStream.Buffer.Empty", type="redneck.events.VideoEvent")]
	[Event(name="NetStream.Buffer.Full", type="redneck.events.VideoEvent")]
	[Event(name="NetStream.Buffer.Flush", type="redneck.events.VideoEvent")]
	
	[Event(name="NetStream.Failed", type="redneck.events.VideoEvent")]
	
	[Event(name="NetStream.Publish.Start", type="redneck.events.VideoEvent")]
	[Event(name="NetStream.Publish.BadName", type="redneck.events.VideoEvent")]
	[Event(name="NetStream.Publish.Idle", type="redneck.events.VideoEvent")]
	[Event(name="NetStream.Unpublish.Success", type="redneck.events.VideoEvent")]
	
	[Event(name="NetStream.Play.Start", type="redneck.events.VideoEvent")]
	[Event(name="NetStream.Play.Stop", type="redneck.events.VideoEvent")]
	[Event(name="NetStream.Play.Failed", type="redneck.events.VideoEvent")]
	[Event(name="NetStream.Play.StreamNotFound", type="redneck.events.VideoEvent")]
	[Event(name="NetStream.Play.Reset", type="redneck.events.VideoEvent")]
	[Event(name="NetStream.Play.PublishNotify", type="redneck.events.VideoEvent")]
	[Event(name="NetStream.Play.UnpublishNotify", type="redneck.events.VideoEvent")]
	[Event(name="NetStream.Play.InsufficientBW", type="redneck.events.VideoEvent")]
	
	[Event(name="NetStream.Pause.Notify", type="redneck.events.VideoEvent")]
	[Event(name="NetStream.Unpause.Notify", type="redneck.events.VideoEvent")]
	
	[Event(name="NetStream.Record.Start", type="redneck.events.VideoEvent")]
	[Event(name="NetStream.Record.NoAccess", type="redneck.events.VideoEvent")]
	[Event(name="NetStream.Record.Stop", type="redneck.events.VideoEvent")]
	[Event(name="NetStream.Record.Failed", type="redneck.events.VideoEvent")]
	
	[Event(name="NetStream.Seek.Failed", type="redneck.events.VideoEvent")]
	[Event(name="NetStream.Seek.InvalidTime", type="redneck.events.VideoEvent")]
	[Event(name="NetStream.Seek.Notify", type="redneck.events.VideoEvent")]

	public class VideoPlayer extends Sprite
	{
		private var _width : Number;
		private var _height : Number;
		private var _video : Video;
		private var _netConnection : NetConnection;
		private var _stream : NetStream;
		private var _metadata : Object
		private var _duration : Number;
		private var _status : String;
		private var _loopCount : int;
		private var _volume : Number;
		private var _completed: Boolean;
		private var _isLoadedDispatched: Boolean = false;

		/*define whether this instance will auto reize when the metada comes.*/
		public var autoSize : Boolean;
		/*define the number of loops before dispatch VideoEvent.COMPLETE*/
		public var loops : int;
		/* define whether the stream must go to the first frame of the movie after it ends. */
		public var rewindAfterComplete : Boolean

		public static const STATUS_PLAY : String = "play";
		public static const STATUS_STOP : String = "stop";
		public static const STATUS_PAUSE : String = "pause";
		/**
		* 
		* @param p_width	int
		* @param p_height	int
		* @param p_autoSize	Boolean	define whether this instance will auto reize when the metada comes. 
		* 
		**/
		public function VideoPlayer(p_width:int=320, p_height:int = 240, p_autoSize : Boolean = true):void
		{
			super();

			_video = addChild( new Video( p_width, p_height ) ) as Video;
			width = p_width;
			height = p_height;
			autoSize = p_autoSize;
			rewindAfterComplete = false;
			loops = 0;

			_netConnection = new NetConnection();
			_netConnection.connect( null );

			_status = STATUS_STOP;
		}
		/**
		*	@return Boolean
		**/
		public function get isPlaying():Boolean
		{
			return (status == STATUS_PLAY);
		}
		/**
		*	@return Boolean
		**/
		public function get isStoped():Boolean
		{
			return (status == STATUS_STOP);
		}
		/**
		*	@return Boolean
		**/
		public function get isPaused():Boolean
		{
			return (status == STATUS_PAUSE);
		}
		/**
		* video smoothing
		**/
		public function set smoothing(value:Boolean):void
		{
			if(_video){
				_video.smoothing = value;
			}
		}
		/**
		* @return Boolean;
		**/
		public function get smoothing():Boolean
		{
			if (_video){
				return _video.smoothing
			}
			return false
		}
		/**
		* @return String
		**/
		public function get status():String
		{
			return _status;
		}
		/**
		* 
		* Load an external flv.
		* 
		* @param p_url	String
		* 
		* @return Boolean
		* 
		**/
		public function load(p_url:String):Boolean{
			if (p_url==null){
				return  false;
			}

			stream = new NetStream( _netConnection );
			_stream.play(p_url);
			seek(0);

			return true;
		}
		/**
		* 
		* Send the video to a specific position
		* 
		* @param p_time		Number	send the playhead to a specific position
		* @param play_after	Boolean	define whether the video will should play after the seek finishes.
		* 
		**/
		public function seek(p_time:Number, play_after:Boolean = false):void
		{
			if (_stream){
				if (play_after){
					_status = STATUS_PLAY;
				}
				_stream.seek(p_time);
			}
		}
		/**
		* 
		* Play stream
		* 
		* @return Boolean
		* 
		**/
		public function play():Boolean{
			if (_stream && status!=STATUS_PLAY){
				_status = STATUS_PLAY;
				if (_completed && (Math.round(time) >= Math.round(duration))) {
					_completed = false;
					seek(0, true);
				}else{
					_stream.resume();
				}
				return true
			}
			return false;
		}
		/**
		* 
		* Stop stream
		* 
		* @return Boolean
		* 
		**/
		public function stop():Boolean{
			if (_stream && status!=STATUS_STOP){
				_status = STATUS_STOP
				_stream.pause();
				seek(0);
				return true;
			}
			return false;
		}
		/**
		* 
		* Pause stream
		* 
		* @return Boolean
		* 
		**/
		public function pause():Boolean{
			if (_stream && status!=STATUS_PAUSE ){
				_status = STATUS_PAUSE
				_stream.pause();
			}
			return false;
		}
		/**
		* @return NetStream
		**/
		public function get stream():NetStream{
			return _stream
		}
		/**
		* Attach a new NetStream instance on the current video.
		**/
		public function set stream(value:NetStream):void
		{
			if (_stream){
				_video.attachNetStream( null );
			}

			_loopCount = 0;

			_stream = value;
			_stream.addEventListener(NetStatusEvent.NET_STATUS, onNetStatus);
			_video.attachNetStream( _stream );

			if (!isNaN(_volume)){
				volume = _volume;
			}

			seek(0);

			_metadata = new Object();
			_metadata.onMetaData = onMetaData;
			_metadata.onCuePoint = onCuePoint;
			_metadata.onImageData = onImageDataHandler;
			_metadata.onTextData = onTextDataHandler;
			_stream.client = _metadata;

			_status = STATUS_STOP;
		}
		/**
		* @return Number
		**/
		public function get bytesTotal():Number
		{
			if (_stream){
				return _stream.bytesTotal;
			}
			return NaN;
		}
		/**
		* @return Number
		**/
		public function get bytesLoaded():Number
		{
			if ( _stream ){
				return _stream.bytesLoaded;
			}
			return NaN;
		}
		/**
		* @return Number
		**/
		public function get percentLoaded():Number
		{
			return bytesLoaded/bytesTotal;
		}
		/**
		* @return Boolean
		**/
		public function get isLoaded():Boolean{
			return (!isNaN(bytesTotal) && !isNaN(bytesLoaded) && percentLoaded==1);
		}
		/**
		* @param value	Number
		**/
		public override function set width(value:Number):void
		{
			_width = value;
			if (_video){
				_video.width = width
			}
		}
		/**
		* @return Number
		**/
		public override function get width():Number
		{
			return _width;
		}
		/**
		* @param value	Number
		**/
		public override function set height(value:Number):void
		{
			_height = value;
			if(_video){
				_video.height = height
			}
		}
		/**
		* @return Number
		**/
		public override function get height():Number
		{
			return _height;
		}
		/**
		* @param value	Number
		**/
		public function set duration(value:Number):void
		{
			_duration = value;
		}
		/**
		* @return Number
		**/
		public function get duration():Number
		{
			return _duration;
		}
		/**
		* current stream time.
		* @return Number
		**/
		public function get time():Number{
			if (_stream){
				return _stream.time;
			}
			return NaN
		}
		/**
		* TODO
		**/
		private function onCuePoint(e:*):void{
			trace("VideoPlayer :: onCuePoint:")
			for (var key:String in e) {
				trace(key + ": " + e[key]);
			}
		}
		/**
		* TODO
		**/
		private function onImageDataHandler(e:*):void{
			trace("VideoPlayer :: onImageDataHandler");
			for (var key:String in e) {
				trace(key + ": " + e[key]);
			}
		}
		/**
		* TODO
		**/
		private function onTextDataHandler(e:*):void{
			trace("VideoPlayer :: onTextDataHandler");
			for (var key:String in e) {
				trace(key + ": " + e[key]);
			}
		}
		/**
		* @private
		* manages the current metadata
		**/
		private function onMetaData( p_data:Object ):void{
			duration = isNaN(duration) ? p_data.duration : duration;
			if (autoSize){
				width = p_data.width
				height = p_data.height;
			}
			dispatchEvent(new VideoEvent(VideoEvent.METADATA));
		}
		/**
		* changes the current video volume
		* @param value Number
		**/
		public function set volume(value:Number):void
		{
			_volume = value;
			if (stream){
				stream.soundTransform = new SoundTransform( value );
			}
		}
		/**
		* @return Number
		**/
		public function get volume():Number
		{
			if (stream){
				return stream.soundTransform.volume;
			}
			return _volume;
		}
		/**
		* dispose all instances and remove the video from displaylist
		**/
		public function dispose(e:*=null):void{
			if (stream){
				stream.removeEventListener( NetStatusEvent.NET_STATUS, onNetStatus );
				stop();
				stream.close();
			}
			if (_video){
				_video.attachNetStream( null );
				if (contains(_video)){
					removeChild(_video)
				}
			}
			_metadata = null;
		}
		/**
		* @private
		* manages NetStatusEvent
		**/
		private function onNetStatus(e : NetStatusEvent):void {
			
			//trace("[VideoPlayer.onNetStatus]: " + e.info.code);
			
			switch(e.info.code)
			{
				case VideoEvent.SEEK_NOTIFY:
					if (status == STATUS_PLAY){
						if(_stream){
							_stream.resume();
						}
					}else{
						if (_stream){
							_stream.pause();
						}
					}
					dispatchEvent( new VideoEvent( VideoEvent.SEEK_NOTIFY, e.info.level, e.info.details ) );
					break;

				case VideoEvent.PLAY_START :
					if (status == STATUS_PLAY){
						dispatchEvent( new VideoEvent( VideoEvent.PLAY_START, e.info.level, e.info.details ) );
					}
					break;

				case VideoEvent.PLAY_STOP :
					if (isLoaded && Math.ceil(time) >= Math.ceil(duration)) {
						_loopCount++;
						if ( _loopCount > loops ) {
							if (rewindAfterComplete) {
								stop();
							}else{
								_status = STATUS_STOP;
								_completed = true;
							}
							dispatchEvent( new VideoEvent( VideoEvent.COMPLETE, e.info.level, e.info.details ) );
						}else{
							dispatchEvent( new VideoEvent( VideoEvent.LOOP ) );
							seek(0, true);
						}
					}
					break;

				case VideoEvent.BUFFER_FULL :
					dispatchEvent( new VideoEvent( VideoEvent.BUFFER_FULL, e.info.level, e.info.details ) );
					if (isLoaded && !_isLoadedDispatched) { // check to send LOAD_COMPLETE once!
						dispatchEvent( new VideoEvent( VideoEvent.LOAD_COMPLETE ) );
						_isLoadedDispatched = true;
					}
					
					break;
					
				default :
					dispatchEvent(new VideoEvent(e.info.code, e.info.level, e.info.details));
					break;
			}
			
		}
	}
}

