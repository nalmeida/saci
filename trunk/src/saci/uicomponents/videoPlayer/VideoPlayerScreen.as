package saci.uicomponents.videoPlayer {
	
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import saci.ui.SaciSprite;
	import saci.uicomponents.VideoPlayer;
	
	/**
	 * @author Nicholas Almeida
	 */
	public class VideoPlayerScreen extends SaciSprite{
		
		private var _skin:Sprite;
		private var _videoPlayer:VideoPlayer;
		private var _blocked:Boolean;
		
		private var _screen:Sprite;
			private var _blocker:Sprite;
			private var _base:Sprite;
			private var _videoHolder:Sprite;
			private var _bigPlayIcon:Sprite;
			private var _bufferIcon:MovieClip;
		
		public function VideoPlayerScreen($videoPlayer:VideoPlayer, $skin:Sprite) {
			_skin = $skin;
			_videoPlayer = $videoPlayer;
			
			_screen = _skin.getChildByName("screen") as Sprite;
				_blocker = _screen.getChildByName("blocker") as Sprite;
				_base = _screen.getChildByName("base") as Sprite;
				_videoHolder = _screen.getChildByName("videoHolder") as Sprite;
				_bufferIcon = _screen.getChildByName("bufferIcon") as MovieClip;
				_bigPlayIcon = _screen.getChildByName("bigPlayIcon") as Sprite;
			
			hideBufferIcon();
			hideBlocker();
			_blocker.mouseEnabled = true;
				
			_screen.x =
			_screen.y = 0;
			addChild(_screen);
				
		}
		
		public function showBufferIcon():void {
			if(!bufferIcon.visible) {
				bufferIcon.visible = true;
				bufferIcon.play();
			}
		}
		
		public function hideBufferIcon():void {
			if(bufferIcon.visible) {
				bufferIcon.visible = false;
				bufferIcon.stop();
			}
		}
		
		public function showBlocker():void {
			_blocked = true;
			blocker.visible = true;
		}
		
		public function hideBlocker():void {
			_blocked = false;
			blocker.visible = false;
		}
		
		public function showBigPlayIcon():void {
			bigPlayIcon.visible = true;
		}
		
		public function hideBigPlayIcon():void {
			bigPlayIcon.visible = false;
		}
		
		public function get base():Sprite { return _base; }
		public function get videoHolder():Sprite { return _videoHolder; }
		public function get bufferIcon():MovieClip { return _bufferIcon; }
		public function get bigPlayIcon():Sprite { return _bigPlayIcon; }
		public function get blocker():Sprite { return _blocker; }
		public function get blocked():Boolean { return _blocked; }
		
	}
	
}