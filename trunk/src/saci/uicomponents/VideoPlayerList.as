package saci.uicomponents {
	
	import flash.events.Event;
	import flash.utils.setInterval;
	import redneck.events.VideoEvent;
	import saci.uicomponents.videoPlayer.VideoInfoVO;
	import saci.uicomponents.VideoPlayer;
	import saci.uicomponents.videoPlayer.VideoPlayerControlBar;
	import saci.uicomponents.videoPlayer.VideoPlayerScreenList;
	import saci.video.Video;
	
	/**
	 * @author Nicholas Almeida
	 */
	public class VideoPlayerList extends VideoPlayer {
		
		protected var _playlist:XML;
		protected var _currentIndex:int = 0;
		protected var _arrMedia:Array;
		
		public function VideoPlayerList() {
			_arrMedia = [];
			super();
		}
		
		public function add(info:VideoInfoVO):void {
			_arrMedia[_arrMedia.length] = info;
		}
		
		public function next():void {
			_currentIndex ++;
			if (_currentIndex >= _arrMedia.length) _currentIndex = 0;
			_loadVideo();
		}
		
		public function previous():void {
			_currentIndex --;
			if (_currentIndex < 0) _currentIndex = _arrMedia.length - 1;
			_loadVideo();
		}
		
		public function loadByIndex(index:int):void {
			_currentIndex = index;
			_loadVideo();
		}
		
		public function loadById(id:String):void {
			
			var len:int = _arrMedia.length
			for (var i:int = 0; i < len; i++) {
				if (id == _arrMedia[i].id) {
					loadByIndex(i);
					return;
				}
			}
		}
		
		/**
		 * 
		 * @param	playlist XML, XMLList or String
		 */
		public function loadPlayList(playlist:*):void {
			_playlist = new XML(playlist);
			
			var len:int = _playlist.media.length();
			for (var i:int = 0; i < len; i++) {
				var info:VideoInfoVO = new VideoInfoVO(
					_playlist.media[i].id,
					_playlist.media[i].flv,
					_playlist.media[i].img,
					_playlist.media[i].title,
					_playlist.media[i].description,
					_playlist.media[i].thumbImg
				);
				
				add(info);
			}
			
			screen.playlist = _playlist;
			
			_loadVideo();
			_controlInterval = setInterval(_controlAll, 100);
		}
		
		public function showList():void {
			screen.showList();
		}
		
		public function hideList():void {
			screen.hideList();
		}
		
		/**
		 * OVERRIDES
		 */
		
		override protected function _onComplete(e:VideoEvent):void {
			super._onComplete(e);
			if (_arrMedia.length > 1) {
				showList();
			}
		}
		
		override public function play(e:Event = null):void {
			if (screen.blocked) screen.hideList();
			super.play(e);
		}
		
		override public function refresh():void {
			super.refresh();
			screen.blocker.width = screen.base.width;
			
			if (autoHideBar) {
				screen.blocker.height = screen.base.height
			} else {
				screen.blocker.height = screen.base.height;
			}
		}
		
		override protected function _removeListSprites():void {
			// DO NOT REMOVE!
		}
		
		override protected function _createLayoutElements():void {
			
			if (!_hasLayout) {
				
				_screen = new VideoPlayerScreenList(this, _skin);
				_controlBar = new VideoPlayerControlBar(this, _skin);
				_video = new Video();
				_video.autoStart = autoStart;
				
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
				_removeListSprites();
				
				_hasLayout = true;
				
				refresh();
			}
		}
		
		/**
		 * PRIVATE
		 */
		
		protected function _loadVideo():void {
			_current = video.id = _arrMedia[_currentIndex].id;
			video.image = _arrMedia[_currentIndex].img;
			change(_arrMedia[_currentIndex].flv);
		}
		
		/**
		 * GETTERS ans SETTERS
		 */
		public function get currentIndex():int { return _currentIndex; }
		public function get playlist():XML { return _playlist; }
		public function get arrMedia():Array { return _arrMedia; }
	}
	
}