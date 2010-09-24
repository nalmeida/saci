package saci.uicomponents {
	
	import caurina.transitions.Tweener;
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.display.StageDisplayState;
	import flash.events.Event;
	import flash.events.FullScreenEvent;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.net.SharedObject;
	import flash.utils.clearInterval;
	import flash.utils.clearTimeout;
	import flash.utils.setInterval;
	import flash.utils.setTimeout;
	import redneck.events.VideoEvent;
	import saci.ui.SaciSprite;
	import saci.uicomponents.videoPlayer.VideoPlayerControlBar;
	import saci.uicomponents.videoPlayer.VideoPlayerScreen;
	import saci.util.Logger;
	import saci.video.Video;
	import flash.utils.Timer;
	import flash.ui.Mouse;
	
	/**
	 *	@author Nicholas Almeida, Marcelo Miranda Carneiro
	 *	@example
	 *		<code>
	 *		_videoPlayer = new VideoPlayer(_skin);
	 * 		addChild(_videoPlayer);
	 * 		_videoPlayer.init(_flv);
	 *		</code>
	 */
	
	//TODO: Fazer o player ficar desabilitado antes de dar um load, loadPlaylist ou change
	//TODO: Separar as classes de slider de "volume" e slider de "track"
	
	public class VideoPlayer extends SaciSprite {
		
		protected var _bounds:Rectangle;
		protected var _size:Rectangle;
		protected var _fullScreenSize:Rectangle;
		protected var _fullScreenRotation:Number;
		protected var _flv:String;
		protected var _autoHideBar:Boolean;
		protected var _controlBarVisibility:Boolean = true;
		protected var _fullScreenEnabled:Boolean;
		protected var _timerEnabled:Boolean = true;
		protected var _fullScreenMode:String = StageDisplayState.NORMAL; // normal or fullscreen
		protected var _timeoutVal:int = 5000; // time in miliseconds
		protected var _timeout:uint;
		protected var _smoothing:Boolean;
		
		protected var _ready:Boolean;
		protected var _hasAlreadyStartedLoading:Boolean;
		protected var _controlInterval:uint;
		protected var _volume:Number = .7;
		protected var _isMute:Boolean;
		protected var _oldVolume:Number = 1;
		protected var _useSharedObject:Boolean;
		protected var _sharedObject:SharedObject;
		
		// mouse inactivity
		protected var _mouseTimer:uint;
		protected var _mouseTimerIsActive:Boolean;
		protected var _mouseVisibility:Boolean = true;
		protected var _mouseIsOver:Boolean;
		protected var _rewindAtEnd:Boolean = true;
		protected var _mousePosition:Point;
		protected var _hideInactiveMouseCursor:Boolean;
		protected var _hideInactiveMouseCursorTime:Number = 1;
		
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
			_video = new Video();
			_screen = new VideoPlayerScreen(_skin);
			_controlBar = new VideoPlayerControlBar(this, _skin);
			_id = _video.id;
			_screen.videoHolder.addChild(_video);
			_fullScreenMode = FULL_SCREEN_NORMAL;
			fullScreenEnabled = false;
			_useSharedObject = true;
			_mousePosition = new Point();
			hideInactiveMouseCursor = true;
		}
		
		/**
		 * PUBLIC
		 */
		/**
		 *	Build video player with initial flv
		 *	@param p_flv URL path
		 */
		public function init(p_flv:String):void {
			_flv = p_flv;
			_video.init();
			
			if(_smoothing){
				_video.smoothing = _smoothing;
			}
			
			_sharedObject = SharedObject.getLocal("saci.videoplayer");
			if(_useSharedObject){
				if(_sharedObject.data.volume != null){
					volume = _sharedObject.data.volume;
				}
			}else{
				_sharedObject.clear();
			}
			
			addChild(_screen);
			addChild(_controlBar);
			
			_addListeners();
			_controlAll();
			refresh();
			_ready = true;
		}
		
		/**
		 *	Refresh visual data of the video player
		 */
		public function refresh():void {
			if (_autoHideBar) {
				_screen.width = _size.width;
				_screen.height = _size.height;
				_controlBar.y = _screen.base.height - _controlBar.base.height;
				_onRollOut(null);
			} else {
				_screen.width = _size.width;
				_screen.height = _size.height - _controlBar.base.height;
				_controlBar.y = _screen.base.height;
			}
			_video.resize(_screen.base.width, _screen.base.height);
			_video.x = (_screen.base.width - _video.size.width) * .5;
			_video.y = (_screen.base.height - _video.size.height) * .5;
			_controlBar.refresh();
			_bounds = getBounds(this);
		}
		
		/**
		 *	changes the player size without distortion
		 */
		public function setSize(p_width:Number, p_height:Number):void{
			_size.width = p_width;
			_size.height = p_height;
			refresh();
		}
		
		/**
		 *	loads video
		 */
		public function load(p_flv:String = null):void {
			if(_ready){
				if (_video.ready) {
					rewind();
				}
				if (_controlInterval <= 0) {
					_controlInterval = setInterval(_controlAll, 100);
				}
				_hasAlreadyStartedLoading = true;
				_flv = p_flv != null ? p_flv : _flv;
				_video.load(_flv);
			}else{
				init(p_flv);
				load();
			}
		}
		
		/**
		 *	starts loading and plays video (same as the big play button)
		 */
		public function rewind(e:Event = null):void {
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
			_startLoading();
		}
		public function seek(p_time:Number, p_playAfter:Boolean = false):void {
			_video.seek(p_time, p_playAfter);
			_controlBar.seek(p_time);
		}
		public function mute():void {
			_oldVolume = volume;
			volume = 0;
			_isMute = true;
		}
		public function unMute():void {
			volume = _oldVolume;
			_isMute = false;
		}
		
		public function dispose():void {
			if (_video != null) {
				_video.dispose();
			}
			clearInterval(_controlInterval);
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
					if(_mouseIsOver && !_mouseVisibility && _hideInactiveMouseCursor){
						_mouseVisibility = true;
						Mouse.show();
					}
					break;
				case "pause" :
					if(_mouseIsOver && !_mouseVisibility && _hideInactiveMouseCursor){
						_mouseVisibility = true;
						Mouse.show();
					}
					_controlBar.pauseButton.visible = false;
					_controlBar.playButton.visible = true;
					break;
				case "play" :
					if(
						!_mouseIsOver &&
						mouseX < _bounds.x + _bounds.width && 
						mouseX > _bounds.x && 
						mouseY < _bounds.y + _bounds.height && 
						mouseY > _bounds.y
					){
						_onMouseOver(null);
					}
					_controlBar.pauseButton.visible = true;
					_controlBar.playButton.visible = false;
					
					_screen.enable();
					_screen.hideBigPlayIcon();
					_video.hidePreview();
					_screen.hideBufferIcon();
					
					if(_listenerManager.hasEventListener(this, MouseEvent.CLICK, _startLoading)){
						_listenerManager.removeEventListener(this, MouseEvent.CLICK, _startLoading);
						mouseChildren = true;
						buttonMode = false;
					}
					
					if (!_listenerManager.hasEventListener(screen.base, MouseEvent.CLICK, playPause)) {
						_listenerManager.addEventListener(screen.base, MouseEvent.CLICK, playPause);
						_screen.disable();
						_screen.showBufferIcon();
						_screen.buttonMode = true;
					}
					
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
			_listenerManager.addEventListener(_video, VideoEvent.PLAY_START, _forwardEvent);
			_listenerManager.addEventListener(_video, Video.FIRST_TIME_COMPLETE, _forwardEvent);
			_listenerManager.addEventListener(_video, Video.FIRST_TIME_PLAY, _forwardEvent);
			
			_listenerManager.addEventListener(_controlBar, VideoPlayerControlBar.VOLUME_CHANGED, _onVolumeChanged);
		}
		protected function _addMouseOverListeners():void{
			if(!_listenerManager.hasEventListener(this, MouseEvent.ROLL_OVER, _onMouseOver))
				_listenerManager.addEventListener(this, MouseEvent.ROLL_OVER, _onMouseOver);
			if(!_listenerManager.addEventListener(this, MouseEvent.MOUSE_MOVE, _onMouseMove))
				_listenerManager.addEventListener(this, MouseEvent.MOUSE_MOVE, _onMouseMove);
			if(!_listenerManager.addEventListener(this, MouseEvent.ROLL_OUT, _onMouseOut))
				_listenerManager.addEventListener(this, MouseEvent.ROLL_OUT, _onMouseOut);
			if(!_listenerManager.addEventListener(this, Event.MOUSE_LEAVE, _onMouseOut))
				_listenerManager.addEventListener(this, Event.MOUSE_LEAVE, _onMouseOut);
		}
		protected function _removeMouseOverListeners():void{
				_listenerManager.removeEventListener(this, MouseEvent.MOUSE_OVER, _onMouseOver);
				_listenerManager.removeEventListener(this, MouseEvent.MOUSE_MOVE, _onMouseMove);
				_listenerManager.removeEventListener(this, MouseEvent.MOUSE_OUT, _onMouseOut);
				_listenerManager.removeEventListener(this, Event.MOUSE_LEAVE, _onMouseOut);
		}
		
		protected function _removeListeners():void {
			_listenerManager.removeAllEventListeners(this);
			_listenerManager.removeAllEventListeners(video);
		}
		
		protected function _onMetaData(e:VideoEvent):void{
			_listenerManager.removeEventListener(_video.redneckVideoPlayer, VideoEvent.METADATA, _onMetaData);
			refresh();
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
				dispatchEvent(e != null ? e : new VideoEvent(VideoEvent.PLAY_STREAMNOTFOUND));
				_screen.showError("<b>ERROR</b>\nUnable to find:\"" + flv + "\"")
				disable();
				_listenerManager.removeAllEventListeners(video);
				_controlBar.pauseButton.visible = true;
				_controlBar.playButton.visible = false;
			}
		}
		protected function _onComplete(e:VideoEvent):void{
			_forwardEvent(e);
			if(_rewindAtEnd)
				rewind();
		}
		
		protected function _onVolumeChanged(e:Event):void {
			_sharedObject.data.volume = _volume = _video.volume = _controlBar.volume;
		}
		
		protected function _startLoading(e:MouseEvent = null):void {
			if (!_hasAlreadyStartedLoading) {
				
				if (_autoHideBar){
					_onRollOver();
				}
				load(_flv);
				_startLoading();
				
			} else {
				_video.play();
				clearTimeout(_timeout);
				_timeout = setTimeout(_onStreamNotFound, _timeoutVal);
			}
		}
		
		protected function _onImagePreviewLoad(e:Event):void {
			_listenerManager.removeEventListener(_video, Video.IMAGE_PREVIEW_COMPLETE, _onImagePreviewLoad);
			refresh();
		}
		protected function _onFullScreen(e:FullScreenEvent):void {
			_controlBar.isFullScreen = e.fullScreen;
			if(!e.fullScreen)
				fullScreenMode = FULL_SCREEN_NORMAL;
		}
		
		/* mouse activity stuff */
		protected function _verifyMousePosition(e:Event):void{
			if(!_mouseTimerIsActive && _mouseIsOver){
				_mouseTimerIsActive = true;
				clearTimeout(_mouseTimer);
				_mouseTimer = setTimeout(_doVerifyMousePosition, _hideInactiveMouseCursorTime * 1000);
			}
		}
		protected function _doVerifyMousePosition():void{
			if(mouseX == _mousePosition.x && _mousePosition.y == mouseY){
				if(_hideInactiveMouseCursor && _video.status == "play"){
					_mouseVisibility = false;
					Mouse.hide();
				}
				if(_autoHideBar){
					_onRollOut();
				}
			}
			_mousePosition.x = mouseX;
			_mousePosition.y = mouseY;
			_mouseTimerIsActive = false;
		}
		protected function _onMouseOver(e:Event):void{
			_mouseIsOver = true;
			_listenerManager.addEventListener(this, Event.ENTER_FRAME, _verifyMousePosition);
			_onRollOver();
		}
		protected function _onMouseMove(e:MouseEvent):void{
			if(_hideInactiveMouseCursor && !_mouseVisibility){
				Mouse.show();
				_mouseVisibility = true;
			}
			if(_autoHideBar && !_controlBarVisibility){
				_onRollOver();
			}
		}
		protected function _onMouseOut(e:Event):void{
			_mouseIsOver = false;
			_listenerManager.removeEventListener(this, Event.ENTER_FRAME, _verifyMousePosition);
			if(_hideInactiveMouseCursor){
				Mouse.show();
			}
			if(_autoHideBar){
				_onRollOut();
			}
		}
		
		/* control bar stuff */
		protected function _onRollOver(e:MouseEvent = null):void {
			_controlBarVisibility = true;
			_controlBar.visible = true;
			Tweener.pauseTweens(_controlBar);
			Tweener.addTween(_controlBar, {
				alpha:1,
				time: .3,
				transition: "linear"
			});
		}
		protected function _onRollOut(e:MouseEvent = null):void {
			_controlBarVisibility = false;
			Tweener.addTween(_controlBar, { 
				alpha:0,
				time: .2,
				delay: .5,
				transition: "linear",
				onComplete: _onHideControlBar
			});
		}
		protected function _onHideControlBar():void {
			_controlBar.visible = false;
		}
		
		protected function _forwardEvent(e:*):void {
			dispatchEvent(e);
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
		public function get screen():VideoPlayerScreen { return _screen; }
		public function get controlBar():VideoPlayerControlBar { return _controlBar; }
		public function get time():Number { 
			return _video != null ? _video.time : 0; 
		}
		
		public function get autoHideBar():Boolean { return _autoHideBar; }
		public function set autoHideBar(value:Boolean):void {
			_autoHideBar = value;
			if(value){
				_addMouseOverListeners();
			}else if(!hideInactiveMouseCursor){
				_removeMouseOverListeners();
			}
			refresh();
		}
		public function get hideInactiveMouseCursorTime():Number { return _hideInactiveMouseCursorTime; }
		public function set hideInactiveMouseCursorTime(value:Number):void {
			_hideInactiveMouseCursorTime = value;
		}
		public function get hideInactiveMouseCursor():Boolean { return _hideInactiveMouseCursor; }
		public function set hideInactiveMouseCursor(value:Boolean):void {
			_hideInactiveMouseCursor = value;
			if(value){
				_addMouseOverListeners();
			}else if(!autoHideBar){
				_removeMouseOverListeners();
			}
		}
		
		public function get rewindAtEnd():Boolean { return _rewindAtEnd; }
		public function set rewindAtEnd(value:Boolean):void { _rewindAtEnd = value; }
		
		public function get autoStart():Boolean { return _video.autoStart; }
		public function set autoStart(value:Boolean):void { _video.autoStart = value; }
		
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
		
		/**
		 *	sets the autosize method to AUTO_SIZE_NONE (streched), AUTO_SIZE_BIGGER (will bleed), AUTO_SIZE_SMALLER (fits) and AUTO_SIZE_ORIGINAL
		 */
		public function get autoSize():String { return _video.autoSize; }
		public function set autoSize(value:String):void {
			_video.autoSize = value;
			refresh();
		}
		
		/**
		 *	URL for preview image or swf (use this OR preview)
		 */
		public function get previewURL():String { return _video.previewURL; }
		public function set previewURL(value:String):void {
			if (value != null) {
				_video.previewURL = value;
				_listenerManager.addEventListener(_video, Video.IMAGE_PREVIEW_COMPLETE, _onImagePreviewLoad);
			}
		}
		
		/**
		 *	preview element (use this OR previewURL)
		 */
		public function get preview():DisplayObject { return _video.preview; }
		public function set preview(value:DisplayObject):void {
			if (value != null) {
				_video.preview = value;
			}
		}
		
		/**
		 *	show fullscreenButton on the control bar
		 */
		public function get fullScreenEnabled():Boolean { return _fullScreenEnabled; }
		public function set fullScreenEnabled(value:Boolean):void {
			_fullScreenEnabled = value;
			if (_fullScreenEnabled) {
				_controlBar.enableFullScreen();
			} else {
				_controlBar.disableFullScreen();
			}
			_controlBar.refresh();
		}
		/**
		 *	shows timer on the control bar
		 */
		public function get timerEnabled():Boolean { return _timerEnabled; }
		public function set timerEnabled(value:Boolean):void {
			_timerEnabled = value;
			if (_timerEnabled) {
				_controlBar.enableTimer();
			} else {
				_controlBar.disableTimer();
			}
			_controlBar.refresh();
		}
		
		public function get volume():Number { 
			return _video != null ? _video.volume : _volume; 
		}
		public function set volume(value:Number):void {
			_volume = value;
			if (value > 1) {
				throw new Error("[ERROR] VideoPlayer volume MUST be > 0 and < 1");
			}
			_video.volume = value;
			_controlBar.seekVolume(_video.volume);
		}
		
		/**
		 *	sends the video to full screen
		 */
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
		
		public function get timeout():int { return _timeoutVal; }
		public function set timeout(value:int):void {
			_timeoutVal = value;
		}
		
		public function get isMute():Boolean { return _isMute; }
		public function get id():String { return _id; }
		
		
		public function get useSharedObject():Boolean { return _useSharedObject; }
		public function set useSharedObject(value:Boolean):void { _useSharedObject = value; }
	}
}