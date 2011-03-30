package saci.video {
	
	import flash.display.Bitmap;
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.net.NetStream;
	import flash.utils.clearInterval;
	import flash.utils.setInterval;
	import flash.utils.setTimeout;
	import saci.loader.SimpleLoader;
	import saci.ui.SaciSprite;
	import redneck.video.VideoPlayer;
	import redneck.events.VideoEvent;
	import saci.util.Logger;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	import saci.util.DisplayUtil;
	import flash.geom.Rectangle;
	import flash.display.DisplayObject;
	
	/**
	 *	@author Nicholas Almeida
	 *	@example
	 *		<code>
	 *			var video:Video = new Video();
	 *			video.autoStart = true;
	 *			video.videoArea.width = 300;
	 *			video.videoArea.height = 350;
	 *			video.autoSize = Video.AUTO_SIZE_SMALLER;
	 *			
	 *			var preview:Sprite = new Sprite();
	 *			preview.graphics.beginFill(0xFF0000, .5);
	 *			preview.graphics.drawRect(0, 0, 320, 180);
	 *			preview.graphics.endFill();
	 *			
	 *			video.preview = preview;
	 *			addChild(video);
	 *			video.load("http://interface.aceite.fbiz.com.br/testes/flv/video.flv?v=1");
	 *		</code>
	 */
	public class Video extends SaciSprite {
		
		public static function getById(p_id:String):Video{
			for (var i:int = 0; Boolean(_instances[i]); i++){
				if(_instances[i].id === p_id){
					return _instances[i];
				}
			}
			return null;
		}
		
		public static var instancesCreated:int = 0;
		public static var _instances:Array = [];
		
		public static const FIRST_TIME_COMPLETE:String = "firstTimeComplete";
		public static const FIRST_TIME_PLAY:String = "firstTimePlay";
	
		public static const IMAGE_PREVIEW_COMPLETE:String = "imagePreviewComplete";
		public static const IMAGE_PREVIEW_ERROR:String = "imagePreviewError";
		
		public static const AUTO_SIZE_NONE:String = "none";
		public static const AUTO_SIZE_BIGGER:String = "bigger";
		public static const AUTO_SIZE_SMALLER:String = "smaller";
		public static const AUTO_SIZE_ORIGINAL:String = "original";

		private var _id:String;
		private var _previewURL:String;
		private var _flv:String;
		private var _videoArea:Rectangle; // desired size (for proportional resize)
		private var _size:Rectangle; // current size (based on video > preview > sprite)
		private var _autoSize:String = AUTO_SIZE_SMALLER;
		private var _autoSized:Boolean;
		private var _autoStart:Boolean;
		private var _volume:Number = 1;
		private var _bufferTime:Number = 5;
		
		private var _isMute:Boolean;
		private var _playCount:int = 0;
		private var _completeCount:int = 0;
		private var _loopCount:int = 0;
		private var _ready:Boolean = false;
		private var _autoStartInt:uint;
		
		private var _redneckVideoPlayer:VideoPlayer;
		private var _imgHolder:SaciSprite;
		private var _preview:DisplayObject;
		private var _simpleLoader:SimpleLoader;
		
		public function Video($id:String = null) {
			super();
			_instances[_instances.length] = this;
			_videoArea = new Rectangle(0,0,320,240);
			_size = new Rectangle();
			if($id == null )
				_id = "Video-" + (instancesCreated++);
			else 
				_id = $id;
		}
		
		/**
		 * PUBLIC
		 */
		public function rewind():void {
			if(redneckVideoPlayer != null) {
				redneckVideoPlayer.seek(0, false);
				dispatchEvent(new VideoEvent(VideoEvent.REWIND));
			}
		}
		
		public function seek(time:Number, playAfter:Boolean = false):void {
			_redneckVideoPlayer.seek(time, playAfter);
		}
		
		public function stop():void {
			if(_redneckVideoPlayer != null) {
				_redneckVideoPlayer.stop();
				dispatchEvent(new VideoEvent(VideoEvent.PLAY_STOP));
			}
		}
		public function playPause():void {
			if (isPlaying) {
				pause();
			} else {
				play();
			}
		}
		public function pause():void {
			_redneckVideoPlayer.pause();
			dispatchEvent(new VideoEvent(VideoEvent.PAUSE_NOTIFY));
		}
		public function play():void {
			hidePreview();
			_redneckVideoPlayer.play();
			dispatchEvent(new VideoEvent(VideoEvent.PLAY_START));
		}
		public function mute():void {
			_redneckVideoPlayer.volume = 0;
			_isMute = true;
		}
		public function unMute():void {
			_redneckVideoPlayer.volume = _volume;
			_isMute = false;
		}

		public function hidePreview():void{
			if(_preview != null && _preview.parent != null){
				if(_preview.parent != null){
					_preview.parent.removeChild(_preview);
				}
			}
		}
		public function showPreview():void{
			if(_preview != null && _preview.parent == null){
				addChild(_preview);
			}
		}

		public function load(flvFile:String):void {
			if(_flv != null && _flv != flvFile){
				_disposeVideo();
				init();
			} else if(!_ready){
				init();
			}
			_flv = flvFile;
			_redneckVideoPlayer.load(_flv);
			if (_autoStart) {
				_createAutoStartInt();
			}
		}
		
		public function resize(p_width:Number = NaN, p_height:Number = NaN):void {
			if(!isNaN(p_width)){_videoArea.width = p_width;}
			if(!isNaN(p_height)){_videoArea.height = p_height;}
			switch(_autoSize){
				case AUTO_SIZE_ORIGINAL:
					if(_redneckVideoPlayer != null){
						_redneckVideoPlayer.width = _redneckVideoPlayer.originalVideoSize.width;
						_redneckVideoPlayer.height = _redneckVideoPlayer.originalVideoSize.height;
						if(_preview != null){
							_preview.width = _redneckVideoPlayer.width;
							_preview.height = _redneckVideoPlayer.height;
						}
					}
					break;
				case AUTO_SIZE_SMALLER:
				case AUTO_SIZE_BIGGER:
					if(_redneckVideoPlayer != null){
						DisplayUtil.scaleProportionally(_redneckVideoPlayer, _videoArea.width, _videoArea.height, _autoSize);
					}
					if(_preview != null){
						DisplayUtil.scaleProportionally(_preview, _videoArea.width, _videoArea.height, _autoSize);
					}
					break;
				case AUTO_SIZE_NONE:
					if(_redneckVideoPlayer != null){
						_redneckVideoPlayer.width = _videoArea.width;
						_redneckVideoPlayer.height = _videoArea.height;
					}
					if(_preview != null){
						_preview.width = _videoArea.width;
						_preview.height = _videoArea.height;
					}
					break;
			}
		}
		
		public function dispose():void {
			_disposeVideo();
			
			if (_preview != null) {
				if(_preview is Bitmap){
					var bitmapPreview:Bitmap = _preview as Bitmap;
					bitmapPreview.bitmapData.dispose();
				}
				_preview = null;
			}
			
			if (_simpleLoader != null) {
				_listenerManager.removeAllEventListeners(_simpleLoader);
				_simpleLoader.destroy();
				_simpleLoader = null;
			}
		}

		public function init():void {
			_redneckVideoPlayer = new VideoPlayer(_videoArea.width, _videoArea.height, _autoSize != AUTO_SIZE_NONE);
			
			_listenerManager.addEventListener(_redneckVideoPlayer, VideoEvent.COMPLETE, _onComplete);
			_listenerManager.addEventListener(_redneckVideoPlayer, VideoEvent.PLAY_START, _onPlay);
			_listenerManager.addEventListener(_redneckVideoPlayer, VideoEvent.METADATA, _onVideoMetadata);
			_listenerManager.addEventListener(_redneckVideoPlayer, VideoEvent.BUFFER_FULL, _onBufferFull);
			
			_listenerManager.addEventListener(_redneckVideoPlayer, VideoEvent.BUFFER_EMPTY, _forwardVideoEvent);
			_listenerManager.addEventListener(_redneckVideoPlayer, VideoEvent.PLAY_STREAMNOTFOUND, _forwardVideoEvent);
			_listenerManager.addEventListener(_redneckVideoPlayer, VideoEvent.SEEK_INVALIDTIME, _forwardVideoEvent);
			_listenerManager.addEventListener(_redneckVideoPlayer, VideoEvent.LOAD_COMPLETE, _forwardVideoEvent);
			
			_ready = true;
		}
		
		/**
		 * PRIVATE
		 */
		
		// interval for "autoStart" mode (keeps verifying if the stream already exists)
		protected function _createAutoStartInt():void{
			clearInterval(_autoStartInt);
			_autoStartInt = setInterval(_verifyStream, 300);
		}
		protected function _verifyStream():void {
			if (_redneckVideoPlayer != null && _redneckVideoPlayer.stream != null) {
				clearInterval(_autoStartInt);
				play();
			}
		}
		
		// Preview Image Stuff
		private function _initImage():void {
			switch(true){
				case (_previewURL != null && _previewURL != ""):
					if(_simpleLoader != null){
						_simpleLoader.destroy();
					}
					_simpleLoader = new SimpleLoader();
					_listenerManager.addEventListener(_simpleLoader, Event.COMPLETE, _onLoadImageComplete);
					_listenerManager.addEventListener(_simpleLoader, ErrorEvent.ERROR, _onLoadImageError);
					_listenerManager.addEventListener(_simpleLoader, IOErrorEvent.IO_ERROR, _onLoadImageIOError);
					_simpleLoader.load(_previewURL);
					break;
				case (_preview != null):
					if(!isPlaying){
						addChild(_preview);
						resize();
					}
					break;
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
				switch(_simpleLoader.contentType){
					case "image/jpeg":
					case "image/png":
					case "image/gif":
						if(_preview != null && _preview.parent != null){
							_preview.parent.removeChild(_preview);
						}
						_preview = _simpleLoader.content;
						if(_preview is Bitmap){
							var bitmapPreview:Bitmap = _preview as Bitmap;
							bitmapPreview.smoothing = true;
						}
						break;
				}
				if(_preview != null){
					addChild(_preview);
					resize();
					dispatchEvent(new Event(IMAGE_PREVIEW_COMPLETE));
				}
			}
		}
		
		// dispose only video
		protected function _disposeVideo():void {
			_autoSized = false;
			if(_redneckVideoPlayer != null){
				_listenerManager.removeAllEventListeners(_redneckVideoPlayer);
				_redneckVideoPlayer.dispose();
				if (_redneckVideoPlayer.parent != null) {
					_redneckVideoPlayer.parent.removeChild(_redneckVideoPlayer);
				}
				_redneckVideoPlayer = null;
			}
			_completeCount = _playCount = 0;
			_ready = false;
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
			dispatchEvent(new VideoEvent(VideoEvent.PLAY_START));
		}
		private function _onVideoMetadata(e:VideoEvent):void {
			_forwardVideoEvent(e);
			if(_redneckVideoPlayer.stream.bufferTime != _bufferTime){
				_redneckVideoPlayer.stream.bufferTime = _bufferTime;
			}
			if(_redneckVideoPlayer.volume != volume){
				_redneckVideoPlayer.volume = volume;
			}
			if(!_autoSized){
				_autoSized = true;
				resize(_videoArea.width, _videoArea.height);
				addChildAt(_redneckVideoPlayer, 0);
			}
		}
		private function _onBufferFull(e:VideoEvent):void {
			_forwardVideoEvent(e);
			if(_autoStart){
				play();
			}
			if (_playCount == 0) {
				dispatchEvent(new Event(FIRST_TIME_PLAY));
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
		
		public function get autoSize():String { return _autoSize; }
		public function set autoSize(value:String):void {
			switch(value){
				case AUTO_SIZE_NONE:
				case AUTO_SIZE_ORIGINAL:
				case AUTO_SIZE_BIGGER:
				case AUTO_SIZE_SMALLER:
					_autoSize = value;
					if (_redneckVideoPlayer != null)
						_redneckVideoPlayer.autoSize = (_autoSize != AUTO_SIZE_NONE);
					resize();
				break;
			}
		}

		/**
		 * sets the desired video area. Useful for autosize
		 *	
		 */
		public function set videoArea(value:Rectangle):void {
			if(_redneckVideoPlayer != null) _redneckVideoPlayer.width = value.width;
			if (_imgHolder != null) _imgHolder.width = value.width;
			if (_redneckVideoPlayer != null) _redneckVideoPlayer.height = value.height;
			if (_imgHolder != null) _imgHolder.height = value.height;
		}
		public function get videoArea():Rectangle {
			return _videoArea;
		}
		/**
		 * gets the size of the generated area. Verifies Video > Preview > Native Width and Height
		 */
		public function get size():Rectangle {
			switch(true){
				case (_autoSized && _redneckVideoPlayer != null):
					_size.width = _redneckVideoPlayer.width;
					_size.height = _redneckVideoPlayer.height;
					break;
				case (_preview != null):
					_size.width = _preview.width;
					_size.height = _preview.height;
					break;
				default:
					_size.width = _videoArea.width;
					_size.height = _videoArea.height;
					break;
			}
			return _size;
		}
		
		/**
		 * SETTERS GETTERS
		 */
		public function get redneckVideoPlayer():VideoPlayer { return _redneckVideoPlayer; }
		public function get status():String { return (_redneckVideoPlayer != null) ? _redneckVideoPlayer.status : null; }
		public function get percentLoaded():Number { return (_redneckVideoPlayer != null) ? _redneckVideoPlayer.percentLoaded : NaN; }
		public function get duration():Number { return (_redneckVideoPlayer != null) ? _redneckVideoPlayer.duration : NaN; }
		public function get time():Number { return (_redneckVideoPlayer != null) ? _redneckVideoPlayer.time : NaN; }
		public function get playCount():int { return _playCount; }
		public function get completeCount():int { return _completeCount; }
		public function get isPlaying():Boolean { return (_redneckVideoPlayer != null) ? _redneckVideoPlayer.isPlaying : false; }
		public function get isStoped():Boolean { return (_redneckVideoPlayer != null) ? _redneckVideoPlayer.isStoped : false; }
		public function get isPaused():Boolean { return (_redneckVideoPlayer != null) ? _redneckVideoPlayer.isPaused : false; }
		public function get isLoaded():Boolean { return (_redneckVideoPlayer != null) ? _redneckVideoPlayer.isLoaded : false; }
		public function get isMute():Boolean { return _isMute; }
		public function get flv():String { return _flv; }
		public function get stream():NetStream{ return (_redneckVideoPlayer != null) ? _redneckVideoPlayer.stream : null; }
		public function get bufferLength():Number{ return (_redneckVideoPlayer != null && _redneckVideoPlayer.stream != null) ? _redneckVideoPlayer.stream.bufferLength : NaN; }
		
		public function get autoStart():Boolean { return _autoStart; }
		public function set autoStart(value:Boolean):void {
			_autoStart = value;
		}
		
		public function get smoothing():Boolean{ return _redneckVideoPlayer != null ? _redneckVideoPlayer.smoothing : false; }
		public function set smoothing(value:Boolean):void {
			if(_redneckVideoPlayer != null){
				_redneckVideoPlayer.smoothing = value;
			}
		}
		
		public function get volume():Number { return _volume; }
		public function set volume(value:Number):void {
			_volume = value;
			if (_redneckVideoPlayer != null) {
				_redneckVideoPlayer.volume = value;
			}
		}
		
		public function get preview():DisplayObject { return _preview; }
		public function set preview(value:DisplayObject):void {
			if(value != null){
				_preview = value;
				_previewURL = null;
			}
		}
			
		public function get previewURL():String { return _previewURL; }
		public function set previewURL(value:String):void {
			if (value != null) {
				_previewURL = value;
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