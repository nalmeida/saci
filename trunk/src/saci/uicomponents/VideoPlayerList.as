package saci.uicomponents {
	
	import flash.utils.setInterval;
	import redneck.events.VideoEvent;
	import saci.uicomponents.videoPlayer.VideoInfoVO;
	import saci.uicomponents.VideoPlayer;
	
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
			if (_currentIndex > _arrMedia.length) _currentIndex = 0;
			_loadVideo();
		}
		
		public function previous():void {
			_currentIndex --;
			if (_currentIndex < 0) _currentIndex = _arrMedia.length;
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
			
			_loadVideo();
			_controlInterval = setInterval(_controlAll, 100);
		}
		
		public function showList():void {
			screen.showBlocker();
		}
		
		public function hideList():void {
			
		}
		
		/**
		 * OVERRIDES
		 */
		
		override protected function _onComplete(e:VideoEvent):void {
			super._onComplete(e);
			showList();
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
	}
	
}