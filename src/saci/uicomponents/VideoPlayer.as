package saci.uicomponents {
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import saci.ui.SaciSprite;
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
		private var _flv:String;
		private var _autoStart:Boolean;
		private var _stretching:Boolean = false;
		
		private var _hasLayout:Boolean = false;
		
		/**
		 * Elements
		 */
		private var _skin:Sprite;
		private var _video:Video;
		
		private var _screen:Sprite;
			private var _screenBase:Sprite;
			private var _screenVideoHolder:Sprite;
			private var _bufferIcon:MovieClip;
			
		private var _controlBar:Sprite;
			private var _controlBase:Sprite;
			private var _playButton:Sprite;
			private var _pauseButton:Sprite;
			private var _rewindButton:Sprite;
		
		public function VideoPlayer() {
			Logger.init(Logger.logLevel);
		}
		
		/**
		 * PUBLIC
		 */
		public function refresh():void {
			if (_hasLayout) {
				
				_screenBase.width = _width;
				
				if (autoHideBar) {
					_screenBase.height = _height;
					_controlBar.y = _screenBase.height - _controlBar.height;
				} else {
					_screenBase.height = _height - _controlBar.height;
					_controlBar.y = _screenBase.height;
				}
				_bufferIcon.x = _screenBase.width * .5;
				_bufferIcon.y = _screenBase.height * .5;
				
				_resizeVideo();
				
				_controlBase.width = _screen.width;
			}
		}
		
		public function change(flvFile:String):void {
			dispose();
			_flv = flvFile;
			_video.load(flv);
		}
		
		public function load(flvFile:String):void {
			change(flvFile);
		}
		
		private function dispose():void{
			if (_video != null) {
				_video.dispose();
			}
		}
		
		/**
		 * PRIVATE
		 */
		private function _arrangeLayout():void {
			if (!_hasLayout) {
				_createLayoutElements();
			}
			addChild(_screen);
			addChild(_controlBar);
			
			refresh();
		}
		
		private function _createLayoutElements():void {
			
			_screen = _skin.getChildByName("screen") as Sprite;
				_screenVideoHolder = _screen.getChildByName("screenVideoHolder") as Sprite;
				_screenBase = _screen.getChildByName("screenBase") as Sprite;
				_bufferIcon = _screen.getChildByName("bufferIcon") as MovieClip;
				
			_controlBar = _skin.getChildByName("controlBar") as Sprite;
				_controlBase = _controlBar.getChildByName("controlBase") as Sprite;
				_playButton = _controlBar.getChildByName("playButton") as Sprite;
				_pauseButton = _controlBar.getChildByName("pauseButton") as Sprite;
				_rewindButton = _controlBar.getChildByName("rewindButton") as Sprite;
			
			_video = new Video();
			_screenVideoHolder.addChild(_video);
				
			_listenerManager.addEventListener(this, Event.RESIZE, refresh);
			
			_hasLayout = true;
		}
		
		private function _resizeVideo():void {
			//_video.width = _width;
			if (stretching) {
				_video.width = _width;
				_video.height = _height;
			} else {
				
				DisplayUtil.scaleObject(_video, _screenBase.width, _screenBase.height);
				
				_video.x = (_screenBase.width * .5) - (_video.width * .5);
				_video.y = (_screenBase.height * .5) - (_video.height * .5);
			}
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
		
		/**
		 * SETTERS AND GETTERS
		 */
		public function get skin():Sprite { return _skin; }
		public function set skin(value:Sprite):void {
			_skin = value;
			_arrangeLayout();
		}
		
		public function get autoHideBar():Boolean { return _autoHideBar; }
		public function set autoHideBar(value:Boolean):void {
			_autoHideBar = value;
		}
		
		public function get flv():String { return _flv; }
		
		public function get autoStart():Boolean { return _autoStart; }
		public function set autoStart(value:Boolean):void {
			_autoStart = value;
			if (_video != null) {
				_video.autoStart = autoStart;
			}
		}
		
		public function get stretching():Boolean { return _stretching; }
		public function set stretching(value:Boolean):void {
			_stretching = value;
		}
		
	}
	
}