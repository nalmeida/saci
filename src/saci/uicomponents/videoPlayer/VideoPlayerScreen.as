package saci.uicomponents.videoPlayer {
	
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import saci.ui.SaciSprite;
	import saci.uicomponents.VideoPlayer;
	
	/**
	 * @author Nicholas Almeida
	 */
	public class VideoPlayerScreen extends SaciSprite{
		
		protected var _skin:Sprite;
		protected var _videoPlayer:*;
		protected var _blocked:Boolean = false;
		
		protected var _screen:Sprite;
			protected var _base:Sprite;
			protected var _listContainer:Sprite;
			protected var _videoHolder:Sprite;
			protected var _bigPlayIcon:Sprite;
			protected var _bufferIcon:MovieClip;
		
		public function VideoPlayerScreen($videoPlayer:*, $skin:Sprite) {
			_skin = $skin;
			_videoPlayer = $videoPlayer;
			
			_screen = _skin.getChildByName("screen") as Sprite;
				_base = _screen.getChildByName("base") as Sprite;
				_listContainer = _screen.getChildByName("listContainer") as Sprite;
				_videoHolder = _screen.getChildByName("videoHolder") as Sprite;
				_bufferIcon = _screen.getChildByName("bufferIcon") as MovieClip;
				_bigPlayIcon = _screen.getChildByName("bigPlayIcon") as Sprite;
			
			hideBufferIcon();

			_bigPlayIcon.mouseChildren = 
			_bigPlayIcon.mouseEnabled = 
			_bufferIcon.mouseChildren = 
			_bufferIcon.mouseEnabled = 
			_videoHolder.mouseChildren =
			_videoHolder.mouseEnabled = false;
				
			_screen.x =
			_screen.y = 0;
			addChild(_screen);
			
			_removeListContainer();
		}
		
		protected function _removeListContainer():void{
			_screen.removeChild(_listContainer);
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
		
		public function showBigPlayIcon():void {
			bigPlayIcon.visible = true;
		}
		
		public function hideBigPlayIcon():void {
			bigPlayIcon.visible = false;
		}
		
		public function refresh():void {
			
			if(_videoPlayer.hasLayout) {
				base.width = _videoPlayer.width;
				
				if (_videoPlayer.autoHideBar) {
					base.height = _videoPlayer.height
				} else {
					base.height = _videoPlayer.height - _videoPlayer.controlBar.base.height;
				}
				bigPlayIcon.x = bufferIcon.x = base.width * .5;
				bigPlayIcon.y = bufferIcon.y = base.height * .5;
				
			}
		}
		
		public function get base():Sprite { return _base; }
		public function get videoHolder():Sprite { return _videoHolder; }
		public function get bufferIcon():MovieClip { return _bufferIcon; }
		public function get bigPlayIcon():Sprite { return _bigPlayIcon; }
		public function get blocked():Boolean { return _blocked; }
		
	}
	
}