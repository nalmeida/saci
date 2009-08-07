package saci.video {
	
	import flash.display.Bitmap;
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.net.NetStream;
	import flash.utils.setTimeout;
	import saci.events.ListenerManager;
	import saci.loader.SimpleLoader;
	import saci.ui.SaciSprite;
	import redneck.video.VideoPlayer;
	import redneck.events.VideoEvent;
	import saci.util.Logger;
	
	/**
	 * @author Nicholas Almeida
	 */
	public class Video extends SaciSprite {
		
		private var _id:String;
		private var _image:String;
		private var _flv:String;
		private var _width:int = 320;
		private var _height:int = 240;
		private var _duration:int = 0;
		private var _autoStart:Boolean;
		private var _volume:Number = 1;
		private var _bufferTime:Number = 5;
		
		private var _isMute:Boolean;
		private var _playCount:int = 0;
		private var _completeCount:int = 0;
		private var _loopCount:int = 0;
		private var _ready:Boolean = false;
		
		private var _redneckVideoPlayer:VideoPlayer;
		private var _imgHolder:SaciSprite;
		private var _bmpImage:Bitmap;
		private var _simpleLoader:SimpleLoader;
		
		public static const FIRST_TIME_COMPLETE:String = "firstTimeComplete";
		public static const FIRST_TIME_PLAY:String = "firstTimePlay";
	
		public static const IMAGE_PREVIEW_COMPLETE:String = "imagePreviewComplete";
		public static const IMAGE_PREVIEW_ERROR:String = "imagePreviewError";
		
		public function Video() {
			super();
			Logger.init(Logger.LOG_VERBOSE);
		}
		
		/**
		 * PUBLIC
		 */
		public function rewind():void {
			redneckVideoPlayer.seek(0, false);
			dispatchEvent(new VideoEvent(VideoEvent.REWIND));
		}
		
		public function seek(time:Number, playAfter:Boolean = false):void {
			redneckVideoPlayer.seek(time, playAfter);
		}
		
		public function stop():void {
			redneckVideoPlayer.stop();
			dispatchEvent(new VideoEvent(VideoEvent.PLAY_STOP));
		}
		
		public function playPause():void {
			if (isPlaying) {
				pause();
			} else {
				play();
			}
		}
		
		public function pause():void {
			redneckVideoPlayer.pause();
			dispatchEvent(new VideoEvent(VideoEvent.PAUSE_NOTIFY));
		}
		
		public function play():void {
			_hidePreviewImage();
			_redneckVideoPlayer.play();
		}
		
		public function mute():void {
			_redneckVideoPlayer.volume = 0;
			_isMute = true;
		}
		
		public function unMute():void {
			_redneckVideoPlayer.volume = _volume;
			_isMute = false;
		}
		
		public function change(flvFile:String):void {
			dispose();
			_init();
			_flv = flvFile;
			_redneckVideoPlayer.load(flv);
		}
		
		public function load(flvFile:String):void {
			change(flvFile);
		}
		
		public function dispose():void {
			if(_redneckVideoPlayer != null){
				_listenerManager.removeAllEventListeners(_redneckVideoPlayer);
				
				_redneckVideoPlayer.dispose();
				if (numChildren > 1) {
					removeChild(_redneckVideoPlayer);
				}
				_redneckVideoPlayer = null;
			}
			
			if (_imgHolder != null) {
				_imgHolder.removeAllEventListeners();
				_imgHolder.destroy();
				_imgHolder = null;
			}
			
			if (_bmpImage != null) {
				_bmpImage = null;
			}
			
			if (_simpleLoader != null) {
				_listenerManager.removeAllEventListeners(_simpleLoader);
				_simpleLoader.destroy();
				_simpleLoader = null;
			}
		}
		
		/**
		 * PRIVATE
		 */
		private function _init():void {
			_redneckVideoPlayer = new VideoPlayer(_width, _height, false);
			addChild(_redneckVideoPlayer);
			
			_listenerManager.addEventListener(_redneckVideoPlayer, VideoEvent.COMPLETE, _onComplete);
			_listenerManager.addEventListener(_redneckVideoPlayer, VideoEvent.PLAY_START, _onPlay);
			_listenerManager.addEventListener(_redneckVideoPlayer, VideoEvent.METADATA, _onVideoMetadata);
			
			_listenerManager.addEventListener(_redneckVideoPlayer, VideoEvent.BUFFER_FULL, _onBufferFull);
			_listenerManager.addEventListener(_redneckVideoPlayer, VideoEvent.BUFFER_EMPTY, _forwardVideoEvent);
			_listenerManager.addEventListener(_redneckVideoPlayer, VideoEvent.PLAY_STREAMNOTFOUND, _forwardVideoEvent);
			_listenerManager.addEventListener(_redneckVideoPlayer, VideoEvent.SEEK_INVALIDTIME, _forwardVideoEvent);
			
			_initImage();
			
			_ready = true;
		}

		private function _initImage():void {
			_imgHolder = new SaciSprite();
			addChild(_imgHolder);
			if(image != null && image != ""){
				_simpleLoader = new SimpleLoader();
				_listenerManager.addEventListener(_simpleLoader, Event.COMPLETE, _onLoadImageComplete);
				_listenerManager.addEventListener(_simpleLoader, ErrorEvent.ERROR, _onLoadImageError);
				_listenerManager.addEventListener(_simpleLoader, IOErrorEvent.IO_ERROR, _onLoadImageIOError);
				_simpleLoader.load(image);
			}
		}
		
		private function _onLoadImageIOError(e:IOErrorEvent):void {
			Logger.logError("[Video._onLoadImageIOError]: " + e);
			dispatchEvent(new Event(IMAGE_PREVIEW_ERROR));
			
		}
		
		private function _onLoadImageError(e:ErrorEvent):void {
			Logger.logError("[Video._onLoadImageError]: " + e);
			dispatchEvent(new Event(IMAGE_PREVIEW_ERROR));
		}
		
		private function _onLoadImageComplete(e:Event):void {
			if(!isPlaying){
				if(_simpleLoader.contentType == "image/jpeg") {
					_bmpImage = _simpleLoader.content;
					_bmpImage.smoothing = true;
				}
				_imgHolder.addChild(_bmpImage);
				_imgHolder.width = width;
				_imgHolder.height = height;
				dispatchEvent(new Event(IMAGE_PREVIEW_COMPLETE));
			}
		}
		
		private function _hidePreviewImage():void{
			if(_imgHolder.visible) setTimeout(_imgHolder.hide, 150);
		}
		
		/**
		 * LISTENERS
		 */
		
		private function _onComplete(e:VideoEvent):void {
			if (_completeCount == 0) {
				dispatchEvent(new Event(FIRST_TIME_COMPLETE));
			}
			dispatchEvent(new VideoEvent(VideoEvent.COMPLETE));
			_loopCount++;
			_completeCount++;
		}
		
		private function _onPlay(e:VideoEvent):void {
			_hidePreviewImage();
			dispatchEvent(new VideoEvent(VideoEvent.PLAY_START));
		}
		
		private function _onVideoMetadata(e:VideoEvent):void {
			//TODO: ver pq mesm ocom autostart true, ele não começa tocando depois do change.
			_redneckVideoPlayer.stream.bufferTime = bufferTime;
			seek(0);
			if (autoStart && _redneckVideoPlayer.stream.bufferLength > bufferTime) {
				play();
			}
			_redneckVideoPlayer.volume = volume;
		}
		
		private function _onBufferFull(e:VideoEvent):void {
			_forwardVideoEvent(e);
			
			if (_playCount == 0) {
				dispatchEvent(new VideoEvent(FIRST_TIME_PLAY));
				_playCount++;
			}
			
		}
		private function _forwardVideoEvent(e:VideoEvent):void {
			dispatchEvent(new VideoEvent(e.type, e.level, e.details));
		}
		
		/**
		 * OVERRIDES
		 */
		
		override public function destroy():Boolean {
			_ready = false;
			dispose();
			return super.destroy();
		}
		
		override public function get width():Number { return _width; }
		override public function set width(value:Number):void {
			_width = value;
			if (_redneckVideoPlayer != null) _redneckVideoPlayer.width = value;
			if (_imgHolder != null) _imgHolder.width = value;
		}
		
		override public function get height():Number { return _height; }
		override public function set height(value:Number):void {
			_height = value;
			if (_redneckVideoPlayer != null) _redneckVideoPlayer.height = value;
			if (_imgHolder != null) _imgHolder.height = value;
		}
		
		/**
		 * SETTERS GETTERS
		 */
		public function get redneckVideoPlayer():VideoPlayer { return _redneckVideoPlayer; }
		public function get status():String { return _redneckVideoPlayer.status; }
		public function get percentLoaded():Number { return _redneckVideoPlayer.percentLoaded; }
		public function get duration():Number { return _redneckVideoPlayer.duration; }
		public function get time():Number { return _redneckVideoPlayer.time; }
		public function get playCount():int { return _playCount; }
		public function get completeCount():int { return _completeCount; }
		public function get isPlaying():Boolean { return (redneckVideoPlayer != null) ? redneckVideoPlayer.isPlaying : false; }
		public function get isStoped():Boolean { return redneckVideoPlayer.isStoped; }
		public function get isPaused():Boolean { return redneckVideoPlayer.isPaused; }
		public function get isLoaded():Boolean { return redneckVideoPlayer.isLoaded; }
		public function get isMute():Boolean { return _isMute; }		
		public function get flv():String { return _flv; }
		public function get stram():NetStream{ return redneckVideoPlayer.stream; }
		public function get bufferLength():Number{ return redneckVideoPlayer.stream.bufferLength; }
		
		public function get autoStart():Boolean { return _autoStart; }
		public function set autoStart(value:Boolean):void {
			_autoStart = value;
		}
		
		public function get volume():Number { return _volume; }
		public function set volume(value:Number):void {
			_volume = value;
		}
		
		public function get image():String { return _image; }
		public function set image(value:String):void {
			_image = value;
			if (_imgHolder == null) {
				_initImage();
			}
		}
		
		public function get id():String { return _id; }
		public function set id(value:String):void {
			_id = value;
		}
		
		public function get bufferTime():Number { return _bufferTime; }
		public function set bufferTime(value:Number):void {
			_bufferTime = value;
		}
		
		public function get ready():Boolean { return _ready; }
		
	}
	
}