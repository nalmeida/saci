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
	
	/**
	 * @author Nicholas Almeida
	 */
	
	//TODO: Fazer o player ficar desabilitado antes de dar um load, loadPlaylist ou change
	//TODO: Separar as classes de slidre de "volume" e slider de "track"
	//TODO: fullscreen
	
	public class VideoPlayer extends SaciSprite {
		
		protected var _width:Number = 320;
		protected var _height:Number = 272;
		protected var _autoHideBar:Boolean = false;
		protected var _image:String;
		protected var _flv:String;
		protected var _autoStart:Boolean;
		protected var _stretching:Boolean = false;
		protected var _fullScreenEnabled:Boolean = false;
		protected var _timerEnabled:Boolean = true;
		protected var _fullScreenMode:String = "normal"; // normal or fullscreen
		protected var _timeout:int = 5000; // time in miliseconds
		
		protected var _hasLayout:Boolean = false;
		protected var _controlInterval:uint;
		protected var _autoStarted:Boolean = false;
		protected var _volume:Number = 1;
		protected var _isMute:Boolean;
		protected var _oldVolume:Number = 1;
		protected var _proportion:String = "smaller";
		protected var _bufferTime:Number;
		
		/**
		 * Elements
		 */
		protected var _skin:Sprite;
		protected var _video:Video;
		
		protected var _screen:*;
		protected var _controlBar:VideoPlayerControlBar;
		protected var _id:String;
		
		/**
		 * Events
		 */
		public static const FIRST_TIME_COMPLETE:String = Video.FIRST_TIME_COMPLETE;
		public static const FIRST_TIME_PLAY:String = Video.FIRST_TIME_PLAY;
		
		public function VideoPlayer() {
			Logger.init(Logger.logLevel);
		}
		
		/**
		 * PUBLIC
		 */
		public function refresh():void {
			if (_hasLayout) {
				
				_screen.refresh();
				
				if (autoHideBar) {
					controlBar.y = screen.base.height - controlBar.base.height;
					controlBar.visible = false;
					_listenerManager.addEventListener(this, MouseEvent.ROLL_OVER, _onRollOver);
					_listenerManager.addEventListener(this, MouseEvent.MOUSE_OVER, _onRollOver);
					_listenerManager.addEventListener(this, MouseEvent.ROLL_OUT, _onRollOut);
				} else {
					controlBar.y = screen.base.height;
				}
				
				controlBar.pauseButton.visible = false;
				controlBar.playButton.visible = true;
				
				_resizeVideo();
				_controlBar.refresh();
			}
		}
		
		public function change(flvFile:String):void {
			//var oldStatus:String;
			if (video != null) {
				if (video.ready) {
					//oldStatus = video.status;
					rewind();
				}
				video.dispose();
				
				screen.showBufferIcon();
			}
			if (_controlInterval <=0) {
				_controlInterval = setInterval(_controlAll, 100);
			}
			//if (oldStatus == "play") { 
				//autoStart = true;
			//} else {
				//autoStart = false;
			//}
			_autoStarted = false;
			_id = video.id;
			_flv = flvFile;
			_video.load(flv);

		}
		
		public function load(flvFile:String):void {
			change(flvFile);
		}
		
		public function dispose():void {
			if (_video != null) {
				_video.dispose();
			}
			clearInterval(_controlInterval);
		}
		
		public function rewind(e:Event = null):void {
			stop();
			video.rewind();
			_controlBar.percentPlayed = 
			_controlBar.time = 0;
			
			_controlBar.sliderButton.x = _controlBar.timeTrack.x;
		}
		
		public function stop(e:Event = null):void {
			video.stop();
		}
		
		public function playPause(e:Event = null):void {
			video.playPause();
		}
		
		public function pause(e:Event = null):void {
			video.pause();
		}
		
		public function play(e:Event = null):void {
			video.play();
		}
		
		public function seek(time:Number, playAfter:Boolean = false):void {
			video.seek(time, playAfter);
		}
		
		public function mute():void {
			_oldVolume = volume;
			video.volume = 0;
			controlBar.seekVolume(0);
			_isMute = true;
		}
		
		public function unMute():void {
			video.volume = _oldVolume;
			controlBar.seekVolume(_oldVolume);
			_isMute = false;
		}
		
		/**
		 * PRIVATE
		 */
		
		protected function _createLayoutElements():void {
			
			if (!_hasLayout) {
				
				_screen = new VideoPlayerScreen(this, _skin);
				_controlBar = new VideoPlayerControlBar(this, _skin);
				_video = new Video();
				_video.autoStart = autoStart;
				_video.bufferTime = bufferTime;
				
				screen.videoHolder.addChild(_video);
				
				/* BAR */
				if (_fullScreenEnabled) {
					_controlBar.enableFullScreen();
				} else {
					_controlBar.disableFullScreen();
				}
				if (_timerEnabled) {
					_controlBar.enableTimer();
				} else {
					_controlBar.disableTimer();
				}
				
				addChild(_screen);
				addChild(_controlBar);
				
				if (autoStart) {
					screen.hideBigPlayIcon();
				}
				
				_addListeners();
				_removeListSprites();
				
				_hasLayout = true;
				
				refresh();
			}
		}
		
		protected function _resizeVideo():void {
			
			if (stretching) {
				_video.width = _width;
				_video.height = _height;
			} else {
				
				DisplayUtil.scaleProportionally(_video, screen.base.width, screen.base.height, proportion);
				
				_video.x = (screen.base.width * .5) - (video.width * .5);
				_video.y = (screen.base.height * .5) - (video.height * .5);
			}
		}
		
		protected function _controlAll():void {
			//video.mute();
			
			if (video.duration > 0) {
				clearTimeout(timeout);
			}
			
			//trace("[VideoPlayer._controlAll] video.status: " + video.status);
			
			switch(video.status) {
				case "stop" :
				
					if (autoStart && (_video.bufferLength  >= _video.bufferTime) && !_autoStarted) {
						_autoStarted = true;
						setTimeout(function():void {
							_startLoading();
						}, 1000);
					}
				
					controlBar.pauseButton.visible = false;
					controlBar.playButton.visible = true;
					break;
				case "pause" :
					controlBar.pauseButton.visible = false;
					controlBar.playButton.visible = true;
					break;
				case "play" :
					controlBar.pauseButton.visible = true;
					controlBar.playButton.visible = false;
					break;
			}
			
			// show timer
			if (timerEnabled && video.isPlaying) {
				controlBar.time = video.time;
			}
			
			// moves the slider bar
			if (video.isPlaying) {
				controlBar.percentPlayed = video.time / video.duration;
			}
			
			// scales the loader bar
			if (!video.isLoaded) {
				controlBar.percentLoaded = video.percentLoaded;
			} else {
				screen.hideBufferIcon();
				controlBar.percentLoaded = 1;
			}
			
			// volume
		}
		
		/**
		 * LISTENERS
		 */
		protected function _addListeners():void {
			mouseChildren = false;
			buttonMode = true;
			_listenerManager.addEventListener(this, Event.RESIZE, refresh);
			_listenerManager.addEventListener(this, MouseEvent.CLICK, _startLoading);
			
			_listenerManager.addEventListener(video, VideoEvent.COMPLETE, _onComplete);
			_listenerManager.addEventListener(video, VideoEvent.LOAD_COMPLETE, _onLoadComplete);
			_listenerManager.addEventListener(video, VideoEvent.BUFFER_FULL, _onBufferFull);
			_listenerManager.addEventListener(video, VideoEvent.BUFFER_EMPTY, _onBufferEmpty);
			_listenerManager.addEventListener(video, VideoEvent.PLAY_STREAMNOTFOUND, _onStreamNotFound);
			_listenerManager.addEventListener(video, Video.FIRST_TIME_COMPLETE, _forwardEvent);
			_listenerManager.addEventListener(video, Video.FIRST_TIME_PLAY, _forwardEvent);
			
			_listenerManager.addEventListener(_controlBar, VideoPlayerControlBar.VOLUME_CHANGED, _onVolumeChanged);
		}
		
		protected function _onComplete(e:VideoEvent):void{
			_forwardEvent(e);
		}
		
		protected function _onVolumeChanged(e:Event):void {
			video.volume = _controlBar.volume;
		}
		
		protected function _onLoadComplete(e:VideoEvent):void {
			if (autoStart && !_autoStarted) {
				_autoStarted = true;
				_startLoading();
				_onBufferFull(e);
			}
		}
		
		protected function _removeListeners():void {
			_listenerManager.removeAllEventListeners(this);
			_listenerManager.removeAllEventListeners(video);
		}
		
		protected function _forwardEvent(e:*):void {
			dispatchEvent(e);
		}
		
		protected function _onBufferEmpty(e:VideoEvent):void {
			if(!video.redneckVideoPlayer.isLoaded) {
				screen.showBufferIcon();
				screen.disable();
			}
		}
		
		protected function _onBufferFull(e:VideoEvent):void {
			screen.hideBufferIcon();
			screen.enable();
			if (video.isPlaying && _video.isPaused || _video.isStoped) play();
		}
		
		protected function _onStreamNotFound(e:VideoEvent = null):void {
			if(!video.isLoaded) {
				Logger.logError("[VideoPlayer._onStreamNotFound] video: \"" + flv +  "\" not found");
				dispatchEvent(e);
				disable();
				_listenerManager.removeAllEventListeners(video);
				controlBar.pauseButton.visible = true;
				controlBar.playButton.visible = false;
			}
		}
		
		protected function _startLoading(e:MouseEvent = null):void {
			video.bufferTime = bufferTime;
			
			refresh();
			if (_listenerManager.hasEventListener(this, MouseEvent.CLICK, _startLoading)) {
				_listenerManager.removeEventListener(this, MouseEvent.CLICK, _startLoading);
			}
			screen.disable();
			screen.hideBigPlayIcon();
			screen.showBufferIcon();
			
			mouseChildren = true;
			buttonMode = false;
			play();
			
			screen.buttonMode = true;
			_listenerManager.addEventListener(screen.base, MouseEvent.CLICK, playPause);
			
			if (autoHideBar) _onRollOver();
			
			timeout = setTimeout(_onStreamNotFound, timeout);
		}
		
		protected function _onRollOver(e:MouseEvent = null):void {
			if(!screen.bigPlayIcon.visible && !controlBar.visible && !screen.blocked) {
				controlBar.visible = true;
				if(controlBar.alpha == 1) controlBar.alpha = 0
				Tweener.addTween(controlBar, { alpha:1, time: .3, transition: "linear"} );
			}
		}
		
		protected function _onRollOut(e:MouseEvent = null):void {
			if (controlBar.visible && !screen.blocked) {
				Tweener.addTween(controlBar, { alpha:0, time: .2, delay:.5 , transition: "linear", onComplete: function():void {controlBar.visible = false;}} );
			}
		}
		
		protected function _removeListSprites():void {
		}
		
		/**
		 * OVERRIDE
		 */
		
		override public function get width():Number { return _width; }
		override public function set width(value:Number):void {
			_width = value;
			refresh();
		}
		
		override public function get height():Number { return _height; }
		override public function set height(value:Number):void {
			_height = value;
			refresh();
		}
		
		override public function destroy():Boolean {
			dispose();
			_removeListeners();
			return super.destroy();
		}
		
		/**
		 * SETTERS AND GETTERS
		 */
		public function get skin():Sprite { return _skin; }
		public function set skin(value:Sprite):void {
			_skin = value;
			_createLayoutElements();
		}
		
		public function get autoHideBar():Boolean { return _autoHideBar; }
		public function set autoHideBar(value:Boolean):void {
			_autoHideBar = value;
		}
		
		public function get flv():String { return _flv; }
		
		public function get stretching():Boolean { return _stretching; }
		public function set stretching(value:Boolean):void {
			_stretching = value;
		}
		
		public function get autoStart():Boolean { return _autoStart; }
		public function set autoStart(value:Boolean):void {
			_autoStart = value;
			if (_video != null) {
				_video.autoStart = _autoStart;
			}
		}
		
		public function get image():String { return _image; }
		public function set image(value:String):void {
			_image = value;
			if (_video != null) {
				video.image = _image;
			}
		}
		
		public function get video():Video { return _video; }
		public function get screen():* { return _screen; }
		public function get controlBar():VideoPlayerControlBar { return _controlBar; }
		
		public function get fullScreenEnabled():Boolean { return _fullScreenEnabled; }
		public function set fullScreenEnabled(value:Boolean):void {
			_fullScreenEnabled = value;
			if (_fullScreenEnabled) {
				_controlBar.enableFullScreen();
			} else {
				_controlBar.disableFullScreen();
			}
		}
		
		public function get time():Number { 
			if (video != null) {
				return video.time; 
			} else {
				return 0;
			}
		}
		
		public function get volume():Number { 
			if (video != null) {
				return video.volume; 
			} else {
				return _volume;
			}
			
		}
		public function set volume(value:Number):void {
			_volume = value;
			if (video != null) {
				if (value > 1) {
					throw new Error("[ERROR] VideoPlayer volume MUST be > 0 and < 1");
				}
				video.volume = value;
				controlBar.seekVolume(video.volume);
			}
		}
		
		public function updateOldVolume(value:Number):void {
			_oldVolume = value;
		}
		
		public function get fullScreenMode():String { return _fullScreenMode; }
		
		public function get timerEnabled():Boolean { return _timerEnabled; }
		public function set timerEnabled(value:Boolean):void {
			_timerEnabled = value;
			if (_timerEnabled) {
				_controlBar.enableTimer();
			} else {
				_controlBar.disableTimer();
			}
		}
		
		public function get bufferTime():Number { return _bufferTime; }
		public function set bufferTime(value:Number):void {
			_bufferTime = value;
		}
		
		public function get timeout():int { return _timeout; }
		public function set timeout(value:int):void {
			_timeout = value;
		}
		
		public function get isMute():Boolean { return _isMute; }
		public function get id():String { return _id; }
		public function get hasLayout():Boolean { return _hasLayout; }
		
		public function get proportion():String { return _proportion; }
		public function set proportion(value:String):void {
			_proportion = value;
		}
		
	}
	
}