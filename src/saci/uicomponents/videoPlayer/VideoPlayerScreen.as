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
		
		private var _screen:Sprite;
			private var _base:Sprite;
			private var _videoHolder:Sprite;
			private var _bigPlayIcon:Sprite;
			private var _bufferIcon:MovieClip;
		
		public function VideoPlayerScreen($videoPlayer:VideoPlayer, $skin:Sprite) {
			_skin = $skin;
			_videoPlayer = $videoPlayer;
			
			_screen = _skin.getChildByName("screen") as Sprite;
				_base = _screen.getChildByName("base") as Sprite;
				_videoHolder = _screen.getChildByName("videoHolder") as Sprite;
				_bufferIcon = _screen.getChildByName("bufferIcon") as MovieClip;
				_bigPlayIcon = _screen.getChildByName("bigPlayIcon") as Sprite;
			
			hideBufferIcon();
				
			_screen.x =
			_screen.y = 0;
			addChild(_screen);
				
		}
		
		public function showBufferIcon():void {
			//trace("[VideoPlayerScreen.showBufferIcon] showBufferIcon");
			bufferIcon.visible = true;
			bufferIcon.play();
		}
		public function hideBufferIcon():void {
			//trace("[VideoPlayerScreen.hideBufferIcon] hideBufferIcon");
			bufferIcon.visible = false;
			bufferIcon.stop();
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
		
	}
	
}