package saci.uicomponents {
	
	import caurina.transitions.Tweener;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.utils.clearInterval;
	import flash.utils.clearTimeout;
	import flash.utils.setInterval;
	import flash.utils.setTimeout;
	import redneck.events.VideoEvent;
	import saci.ui.SaciSprite;
	import saci.uicomponents.videoPlayer.VideoPlayerControlBar;
	import saci.uicomponents.videoPlayer.VideoPlayerScreen;
	import saci.util.DisplayUtil;
	import saci.util.Logger;
	import saci.video.Video;
	import flash.display.DisplayObject;
	import flash.geom.Rectangle;
	import flash.display.StageDisplayState;
	import flash.geom.Point;
	import flash.events.FullScreenEvent;
	import flash.utils.Timer;
	
	/**
	 * @author Nicholas Almeida
	 */
	
	//TODO: Fazer o player ficar desabilitado antes de dar um load, loadPlaylist ou change
	//TODO: Separar as classes de slider de "volume" e slider de "track"
	
	
	
	public class VideoPlayer extends SaciSprite {
		
		protected var _size:Rectangle;
		protected var _fullScreenSize:Rectangle;
		protected var _fullScreenRotation:Number;
		protected var _flv:String;
		protected var _autoHideBar:Boolean;
		protected var _fullScreenEnabled:Boolean;
		protected var _timerEnabled:Boolean = true;
		protected var _fullScreenMode:String = StageDisplayState.NORMAL; // normal or fullscreen
		protected var _timeout:int = 5000; // time in miliseconds
		protected var _smoothing:Boolean; // time in miliseconds
		
		protected var _hasAlreadyStartedLoading:Boolean = false;
		protected var _controlInterval:uint;
		protected var _autoStarted:Boolean = false;
		protected var _volume:Number = .7;
		protected var _isMute:Boolean;
		protected var _oldVolume:Number = 1;
		
		/**
		 * Elements
		 */
		protected var _skin:Sprite;
		protected var _video:Video;
		
		protected var _screen:VideoPlayerScreen;
		protected var _controlBar:VideoPlayerControlBar;
		protected var _id:String;
		
		/**
		 * Events
		 */
		public static const FIRST_TIME_COMPLETE:String = Video.FIRST_TIME_COMPLETE;
		public static const FIRST_TIME_PLAY:String = Video.FIRST_TIME_PLAY;

		/**
		 * options
		 */
		public static const AUTO_SIZE_NONE:String = Video.AUTO_SIZE_NONE;
		public static const AUTO_SIZE_BIGGER:String = Video.AUTO_SIZE_BIGGER;
		public static const AUTO_SIZE_SMALLER:String = Video.AUTO_SIZE_SMALLER;
		public static const AUTO_SIZE_ORIGINAL:String = Video.AUTO_SIZE_ORIGINAL;
		public static const FULL_SCREEN_NORMAL:String = StageDisplayState.NORMAL;
		public static const FULL_SCREEN_FULL:String = StageDisplayState.FULL_SCREEN;
		
		public function VideoPlayer(p_skin:Sprite) {
			_size = new Rectangle(0, 0, 320, 272);
			_fullScreenSize = new Rectangle(0, 0, 1024, 768);
			_skin = p_skin;
			_screen = new VideoPlayerScreen(_skin);
			_screen.hideBufferIcon();
			_controlBar = new VideoPlayerControlBar(this, _skin);
			_video = new Video();
			_screen.videoHolder.addChild(_video);
			_fullScreenMode = FULL_SCREEN_NORMAL;
			fullScreenEnabled = false;
		}
		
		/**
		 * PUBLIC
		 */
		public function init(p_flv:String):void {
			_flv = p_flv;
			_video.init();
			
			if(_smoothing){
				_video.smoothing = _smoothing;
			}
			
			addChild(_screen);
			addChild(_controlBar);
			
			_addListeners();
			_controlAll();
			refresh();
		}
		
		public function refresh():void {
			if (_autoHideBar) {
				_screen.width = _size.width;
				_screen.height = _size.height;
				_controlBar.y = _screen.base.height - _controlBar.base.height;
				_controlBar.visible = false;
			} else {
				_screen.width = _size.width;
				_screen.height = _size.height - _controlBar.base.height;
				_controlBar.y = _screen.base.height;
			}
			_video.resize(_screen.base.width, _screen.base.height);
			_video.x = (_screen.base.width - _video.size.width) * .5;
			_video.y = (_screen.base.height - _video.size.height) * .5;
			_controlBar.refresh();
		}
		
		public function load(p_flv:String = null):void {
			if (_video.ready) {
				rewind();
			}
			if (_controlInterval <= 0) {
				_controlInterval = setInterval(_controlAll, 100);
			}
			_hasAlreadyStartedLoading = true;
			_id = _video.id;
			_flv = p_flv != null ? p_flv : _flv;
			_video.load(_flv);
		}
		public function startVideo():void{
			_startLoading();
		}
		
		public function dispose():void {
			if (_video != null) {
				_video.dispose();
			}
			clearInterval(_controlInterval);
		}
		
		public function rewind(e:Event = null):void {
			stop();
			_video.rewind();
			_screen.showBigPlayIcon();
			_video.showPreview();
			_controlBar.percentPlayed = 
			_controlBar.time = 0;
			_controlBar.sliderButton.x = _controlBar.timeTrack.x;
		}
		
		public function stop(e:Event = null):void {
			_video.stop();
		}
		
		public function playPause(e:Event = null):void {
			_video.playPause();
		}
		
		public function pause(e:Event = null):void {
			_video.pause();
		}
		
		public function play(e:Event = null):void {
			_video.play();
		}
		
		public function seek(p_time:Number, p_playAfter:Boolean = false):void {
			_video.seek(p_time, p_playAfter);
		}
		
		public function mute():void {
			_oldVolume = volume;
			_video.volume = 0;
			_controlBar.seekVolume(0);
			_isMute = true;
		}
		
		public function unMute():void {
			_video.volume = _oldVolume;
			_controlBar.seekVolume(_oldVolume);
			_isMute = false;
		}
		public function setSize(p_width:Number, p_height:Number):void{
			_size.width = p_width;
			_size.height = p_height;
			refresh();
		}
		
		/**
		 * PRIVATE
		 */
		protected function _controlAll():void {

			if (_video.duration > 0) {
				clearTimeout(_timeout);
			}
			
			switch(_video.status) {
				case "stop" :
					_controlBar.pauseButton.visible = false;
					_controlBar.playButton.visible = true;
					break;
				case "pause" :
					_controlBar.pauseButton.visible = false;
					_controlBar.playButton.visible = true;
					break;
				case "play" :
					_controlBar.pauseButton.visible = true;
					_controlBar.playButton.visible = false;
					_screen.hideBigPlayIcon();
					_video.hidePreview();
					break;
			}
			
			// show timer
			if (_timerEnabled && _video.isPlaying) {
				_controlBar.time = _video.time;
			}
			
			// moves the slider bar
			if (_video.isPlaying) {
				_controlBar.percentPlayed = _video.time / _video.duration;
			}
			
			// scales the loader bar
			if (!_video.isLoaded) {
				_controlBar.percentLoaded = _video.percentLoaded;
			} else {
				_controlBar.percentLoaded = 1;
			}
			
			// volume
		}
		
		/**
		 * LISTENERS
		 */
		protected function _addListeners():void {
			mouseChildren = false;
			buttonMode = true;
			_listenerManager.addEventListener(this, MouseEvent.CLICK, _startLoading);
			
			_listenerManager.addEventListener(_video, VideoEvent.COMPLETE, _onComplete);
			_listenerManager.addEventListener(_video.redneckVideoPlayer, VideoEvent.METADATA, _onMetaData);
			_listenerManager.addEventListener(_video, VideoEvent.BUFFER_FULL, _onBufferFull);
			_listenerManager.addEventListener(_video, VideoEvent.BUFFER_EMPTY, _onBufferEmpty);
			_listenerManager.addEventListener(_video, VideoEvent.PLAY_STREAMNOTFOUND, _onStreamNotFound);
			_listenerManager.addEventListener(_video, Video.FIRST_TIME_COMPLETE, _forwardEvent);
			_listenerManager.addEventListener(_video, Video.FIRST_TIME_PLAY, _forwardEvent);
			
			_listenerManager.addEventListener(_controlBar, VideoPlayerControlBar.VOLUME_CHANGED, _onVolumeChanged);
		}
		
		protected function _onMetaData(e:VideoEvent):void{
			_listenerManager.removeEventListener(_video.redneckVideoPlayer, VideoEvent.METADATA, _onMetaData);
			refresh();
		}
		protected function _onComplete(e:VideoEvent):void{
			_forwardEvent(e);
			rewind();
		}
		
		protected function _onVolumeChanged(e:Event):void {
			_video.volume = _controlBar.volume;
		}
		
		protected function _onFullScreen(e:FullScreenEvent):void {
			_controlBar.isFullScreen = e.fullScreen;
			if(!e.fullScreen)
				fullScreenMode = FULL_SCREEN_NORMAL;
		}
		
		protected function _removeListeners():void {
			_listenerManager.removeAllEventListeners(this);
			_listenerManager.removeAllEventListeners(video);
		}
		
		protected function _forwardEvent(e:*):void {
			dispatchEvent(e);
		}
		
		protected function _onBufferEmpty(e:VideoEvent):void {
			if(!_video.redneckVideoPlayer.isLoaded) {
				_screen.showBufferIcon();
				_screen.disable();
			}
		}
		
		protected function _onBufferFull(e:VideoEvent):void {
			_screen.hideBufferIcon();
			_screen.enable();
			if (_video.isPlaying && (_video.isPaused || _video.isStoped)) play();
		}
		
		protected function _onStreamNotFound(e:VideoEvent = null):void {
			if(!_video.isLoaded) {
				Logger.logError("[VideoPlayer._onStreamNotFound] video: \"" + flv +  "\" not found");
				dispatchEvent(e);
				disable();
				_listenerManager.removeAllEventListeners(video);
				_controlBar.pauseButton.visible = true;
				_controlBar.playButton.visible = false;
			}
		}
		
		protected function _startLoading(e:MouseEvent = null):void {
			/*refresh();*/
			_listenerManager.removeEventListener(this, MouseEvent.CLICK, _startLoading);
			if (!_listenerManager.hasEventListener(screen.base, MouseEvent.CLICK, playPause)) {
				_listenerManager.addEventListener(screen.base, MouseEvent.CLICK, playPause);
			}
			_screen.disable();
			_screen.showBufferIcon();
			
			mouseChildren = true;
			buttonMode = false;
			
			_screen.buttonMode = true;
			
			if (_autoHideBar) _onRollOver();
			
			if (!_hasAlreadyStartedLoading) {
				load(_flv);
				_startLoading();
			} else {
				_video.bufferTime = bufferTime;
				setTimeout(play, 200);
				_timeout = setTimeout(_onStreamNotFound, _timeout);
			}
			_onRollOver();
		}
		
		protected function _onRollOver(e:MouseEvent = null):void {
			if(!_screen.bigPlayIcon.visible && !_controlBar.visible) {
				_controlBar.visible = true;
				if(_controlBar.alpha > 0) {
					_controlBar.alpha = 0;
				}
				Tweener.addTween(_controlBar, {
					alpha:1,
					time: .3,
					transition: "linear"
				});
			}
		}
		protected function _onRollOut(e:MouseEvent = null):void {
			if (_controlBar.visible && !_screen.blocked) {
				Tweener.addTween(_controlBar, { 
					alpha:0,
					time: .2,
					delay:.5,
					transition: "linear",
					onComplete: _onHideControlBar
				});
			}
		}
		protected function _onHideControlBar():void {
			_controlBar.visible = false;
		}
		
		protected function _onImagePreviewLoad(e:Event):void {
			_listenerManager.removeEventListener(_video, Video.IMAGE_PREVIEW_COMPLETE, _onImagePreviewLoad);
			refresh();
		}
		
		/**
		 * OVERRIDE
		 */
		override public function destroy():Boolean {
			dispose();
			_removeListeners();
			return super.destroy();
		}
		
		/**
		 * SETTERS AND GETTERS
		 */
		public function get skin():Sprite { return _skin; }
		public function get video():Video { return _video; }
		public function get screen():* { return _screen; }
		public function get controlBar():VideoPlayerControlBar { return _controlBar; }
		public function get time():Number { 
			return _video != null ? _video.time : 0; 
		}
		
		public function get autoHideBar():Boolean { return _autoHideBar; }
		public function set autoHideBar(value:Boolean):void {
			_autoHideBar = value;
			if(_autoHideBar){
				_listenerManager.addEventListener(this, MouseEvent.ROLL_OVER, _onRollOver);
				_listenerManager.addEventListener(this, MouseEvent.MOUSE_OVER, _onRollOver);
				_listenerManager.addEventListener(this, MouseEvent.ROLL_OUT, _onRollOut);
				_onRollOut(null);
			}else{
				_listenerManager.removeEventListener(this, MouseEvent.ROLL_OVER, _onRollOver);
				_listenerManager.removeEventListener(this, MouseEvent.MOUSE_OVER, _onRollOver);
				_listenerManager.removeEventListener(this, MouseEvent.ROLL_OUT, _onRollOut);
			}
		}
		
		public function get flv():String { return _video.flv; }
		public function set flv(value:String):void { 
			if(value != null){
				_video.load(flv);
			}
		}
		
		public function get size():Rectangle { return _size; }
		public function set size(value:Rectangle):void {
			_size = value;
			refresh();
		}
		
		public function get autoSize():String { return _video.autoSize; }
		public function set autoSize(value:String):void {
			_video.autoSize = value;
		}
		
		public function get previewURL():String { return _video.previewURL; }
		public function set previewURL(value:String):void {
			if (value != null) {
				_video.previewURL = value;
				_listenerManager.addEventListener(_video, Video.IMAGE_PREVIEW_COMPLETE, _onImagePreviewLoad);
			}
		}
		
		public function get preview():DisplayObject { return _video.preview; }
		public function set preview(value:DisplayObject):void {
			if (value != null) {
				_video.preview = value;
			}
		}
		
		public function get fullScreenEnabled():Boolean { return _fullScreenEnabled; }
		public function set fullScreenEnabled(value:Boolean):void {
			_fullScreenEnabled = value;
			if (_fullScreenEnabled) {
				_controlBar.enableFullScreen();
			} else {
				_controlBar.disableFullScreen();
			}
		}
		
		public function get volume():Number { 
			return _video != null ? _video.volume : _volume; 
		}
		public function set volume(value:Number):void {
			_volume = value;
			if (_video != null) {
				if (value > 1) {
					throw new Error("[ERROR] VideoPlayer volume MUST be > 0 and < 1");
				}
				_video.volume = value;
				_controlBar.seekVolume(_video.volume);
			}
		}
		
		public function get fullScreenMode():String { return _fullScreenMode; }
		public function set fullScreenMode(value:String):void {
			_fullScreenMode = value;
			if(stage != null){
				
				switch(_fullScreenMode){
					case FULL_SCREEN_NORMAL:
						if(_listenerManager.hasEventListener(stage, FullScreenEvent.FULL_SCREEN, _onFullScreen)){
							_listenerManager.removeEventListener(stage, FullScreenEvent.FULL_SCREEN, _onFullScreen);
						}
						rotation = _fullScreenRotation;
						setSize(_fullScreenSize.width, _fullScreenSize.height);
						break;
					case FULL_SCREEN_FULL:
						if(!_listenerManager.hasEventListener(stage, FullScreenEvent.FULL_SCREEN, _onFullScreen)){
							_listenerManager.addEventListener(stage, FullScreenEvent.FULL_SCREEN, _onFullScreen);
						}
						var globalPos:Point = localToGlobal(new Point(0, 0));
						var newHeight:Number = stage.fullScreenHeight * width / stage.fullScreenWidth;
						_fullScreenSize.width = _size.width;
						_fullScreenSize.height = _size.height;
						_fullScreenRotation = rotation;
						rotation = 0;
						stage.fullScreenSourceRect = new Rectangle(globalPos.x, globalPos.y, stage.fullScreenWidth, stage.fullScreenHeight);
						setSize(stage.fullScreenWidth, stage.fullScreenHeight);
						break;
				}
				
				stage.displayState = _fullScreenMode;
			}
		}
		
		public function get timerEnabled():Boolean { return _timerEnabled; }
		public function set timerEnabled(value:Boolean):void {
			_timerEnabled = value;
			if (_timerEnabled) {
				_controlBar.enableTimer();
			} else {
				_controlBar.disableTimer();
			}
		}
		
		public function get bufferTime():Number { return _video.bufferTime; }
		public function set bufferTime(value:Number):void {
			_video.bufferTime = value;
		}
		public function get smoothing():Boolean {
			if(_video != null){
				return _video.smoothing;
			}
			return _smoothing;
		}
		public function set smoothing(value:Boolean):void {
			_smoothing = value;
			if(_video != null){
				_video.smoothing = value;
			}
		}
		
		public function get timeout():int { return _timeout; }
		public function set timeout(value:int):void {
			_timeout = value;
		}
		
		public function get isMute():Boolean { return _isMute; }
		public function get id():String { return _id; }
		
	}
}