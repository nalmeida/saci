package saci.uicomponents {
	
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.utils.clearInterval;
	import flash.utils.clearTimeout;
	import flash.utils.setInterval;
	import flash.utils.setTimeout;
	import saci.ui.SaciSprite;
	import saci.uicomponents.videoPlayer.VideoPlayerControlBar;
	import saci.uicomponents.videoPlayer.VideoPlayerScreen;
	import saci.util.DisplayUtil;
	import saci.util.Logger;
	import saci.video.Video;
	
	/**
	 * @author Nicholas Almeida
	 */
	public class VideoPlayer extends SaciSprite {
		
		private var _width:Number = 320;
		private var _height:Number = 272;
		private var _autoHideBar:Boolean = false;
		private var _image:String;
		private var _flv:String;
		private var _autoStart:Boolean;
		private var _stretching:Boolean = false;
		private var _fullScreenEnabled:Boolean = false;
		private var _timerEnabled:Boolean = true;
		private var _fullScreenMode:String = "normal"; // normal or fullscreen
		private var _timeout:int = 5000; // time in miliseconds
		
		private var _hasLayout:Boolean = false;
		private var _controlInterval:uint;
		
		/**
		 * Elements
		 */
		private var _skin:Sprite;
		private var _video:Video;
		
		private var _screen:VideoPlayerScreen;
		private var _controlBar:VideoPlayerControlBar;
		
		public function VideoPlayer() {
			Logger.init(Logger.logLevel);
		}
		
		/**
		 * PUBLIC
		 */
		public function refresh():void {
			if (_hasLayout) {
				
				screen.base.width = _width;
				
				if (autoHideBar) {
					screen.base.height = _height;
					controlBar.y = screen.base.height - controlBar.height;
				} else {
					screen.base.height = _height - controlBar.height;
					controlBar.y = screen.base.height;
				}
				screen.bigPlayIcon.x = screen.bufferIcon.x = screen.base.width * .5;
				screen.bigPlayIcon.y = screen.bufferIcon.y = screen.base.height * .5;
				
				controlBar.pauseButton.visible = false;
				controlBar.playButton.visible = true;
				
				_resizeVideo();
				
				_controlBar.refresh();
				
				controlBar.base.width = screen.width;
			}
		}
		
		public function change(flvFile:String):void {
			if (_video != null) {
				_video.dispose();
			}
			if (_controlInterval <=0) {
				_controlInterval = setInterval(_controlAll, 100);
			}
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
			_controlBar.percentPlayed = 0;
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
		
		/**
		 * PRIVATE
		 */
		
		private function _createLayoutElements():void {
			
			if (!_hasLayout) {
				
				_screen = new VideoPlayerScreen(this, _skin);
				_controlBar = new VideoPlayerControlBar(this, _skin);
				_video = new Video();
				
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
				
				_addListeners();
				
				_hasLayout = true;
				
				refresh();
			}
		}
		
		private function _resizeVideo():void {
			
			if (stretching) {
				_video.width = _width;
				_video.height = _height;
			} else {
				
				DisplayUtil.scaleProportionally(_video, screen.base.width, screen.base.height);
				
				_video.x = (screen.base.width * .5) - (video.width * .5);
				_video.y = (screen.base.height * .5) - (video.height * .5);
			}
		}
		
		private function _controlAll():void {
			
			if (video.duration > 0) {
				clearTimeout(timeout);
			}
			switch(video.status) {
				case "stop" :
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
				controlBar.percentLoaded = 1;
			}
		}
		
		/**
		 * LISTENERS
		 */
		private function _addListeners():void {
			mouseChildren = false;
			buttonMode = true;
			_listenerManager.addEventListener(this, Event.RESIZE, refresh);
			_listenerManager.addEventListener(this, MouseEvent.CLICK, _startLoading);
			_listenerManager.addEventListener(video, Video.BUFFER_FULL, _onBufferFull);
			_listenerManager.addEventListener(video, Video.BUFFER_EMPTY, _onBufferEmpty);
			_listenerManager.addEventListener(video, Video.STREAM_NOT_FOUND, _onStreamNotFound);
		}
		
		private function _removeListeners():void {
			_listenerManager.removeAllEventListeners(this);
			_listenerManager.removeAllEventListeners(video);
		}
		
		private function _onBufferEmpty(e:Event):void {
			//trace("[VideoPlayer._onBufferFull] _onBufferFull");
			screen.showBufferIcon();
			screen.disable();
		}
		
		private function _onBufferFull(e:Event):void {
			//trace("[VideoPlayer._onBufferFull] _onBufferFull");
			screen.hideBufferIcon();
			screen.enable();
			play();
		}
		
		private function _onStreamNotFound(e:Event = null):void{
			trace("VÏDEO NAO ENCONTRADO");
			dispatchEvent(new Event(Video.STREAM_NOT_FOUND));
			disable();
			screen.hideBigPlayIcon();
			screen.hideBufferIcon();
			_listenerManager.removeAllEventListeners(video);
			controlBar.pauseButton.visible = true;
			controlBar.playButton.visible = false;
		}
		
		private function _startLoading(e:MouseEvent = null):void{
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
			_listenerManager.addEventListener(screen, MouseEvent.CLICK, playPause);
			
			timeout = setTimeout(_onStreamNotFound, timeout);
		}
		
		/**
		 * OVERRIDE
		 */
		
		override public function get width():Number { return super.width; }
		override public function set width(value:Number):void {
			_width = value;
			refresh();
		}
		
		override public function get height():Number { return super.height; }
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
		public function get screen():VideoPlayerScreen { return _screen; }
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
		
		public function get volume():Number { 
			if (video != null) {
				return video.volume; 
			} else {
				return 1;
			}
			
		}
		public function set volume(value:Number):void {
			video.volume = value;
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
		
		public function get bufferTime():Number { return video.bufferTime; }
		public function set bufferTime(value:Number):void {
			video.bufferTime = value;
		}
		
		public function get timeout():int { return _timeout; }
		public function set timeout(value:int):void {
			_timeout = value;
		}
		
	}
	
}