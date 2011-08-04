package saci.uicomponents.videoPlayer {
	
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import saci.ui.SaciSprite;
	import saci.uicomponents.VideoPlayer;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.text.TextFieldAutoSize;
	
	/**
	 * @author Nicholas Almeida
	 */
	public class VideoPlayerScreen extends SaciSprite{
		
		protected var _skin:Sprite;
		protected var _blocked:Boolean = false;
		
		protected var _screen:Sprite;
			protected var _base:Sprite;
			protected var _listContainer:Sprite;
			protected var _videoHolder:Sprite;
			protected var _bigPlayIcon:Sprite;
			protected var _bufferIcon:MovieClip;
			protected var _errorBox:TextField;
		
		public function VideoPlayerScreen($skin:Sprite) {
			_skin = $skin;
			
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
			if(_listContainer){
				_screen.removeChild(_listContainer);
			}
		}
		
		public function showError(str:String):void {
			if(_errorBox == null) {
				_errorBox  = new TextField();
				_errorBox.border = true;
				_errorBox.borderColor = 0xFF0000;
				_errorBox.background = true;
				_errorBox.backgroundColor = 0xFFFFFF;
				_errorBox.autoSize = TextFieldAutoSize.LEFT;
				
				var format:TextFormat = new TextFormat();
	            format.font = "Arial";
	            format.color = 0x000000;
	            format.align = "center";
	            format.size = 14;
	
				_errorBox.defaultTextFormat = format;
				
				_screen.addChild(_errorBox);
			}
			
			_errorBox.htmlText = str;
			_adjustErrorPosition();
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
		
		private function _adjustErrorPosition():void {
			if(_errorBox != null) {
				_errorBox.x = (_base.width * .5) - (_errorBox.width * .5);
				_errorBox.y = (_base.height * .5) - (_errorBox.height * .5);
			}
		}
		
		override public function set width(value:Number):void{
			base.width = value;
			bigPlayIcon.x = bufferIcon.x = base.width * .5;
			_adjustErrorPosition();
		}
		override public function set height(value:Number):void{
			base.height = value;
			bigPlayIcon.y = bufferIcon.y = base.height * .5;
			_adjustErrorPosition();
		}
		
		public function get base():Sprite { return _base; }
		public function get videoHolder():Sprite { return _videoHolder; }
		public function get bufferIcon():MovieClip { return _bufferIcon; }
		public function get bigPlayIcon():Sprite { return _bigPlayIcon; }
		public function get blocked():Boolean { return _blocked; }
		
	}
	
}