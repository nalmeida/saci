package saci.uicomponents.videoPlayer {
	
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.MouseEvent;
	import flash.events.ProgressEvent;
	import flash.text.TextField;
	import saci.events.ListenerManager;
	import saci.loader.SimpleLoader;
	import saci.util.DisplayUtil;
	import saci.util.Logger;
	
	/**
	 * @author Nicholas Almeida
	 */
	public class VideoListItem {
		
		private var _videoPlayer:*;
		private var _item:Sprite;
			private var _base:Sprite;
			private var _frame:Sprite;
			private var _image:Sprite;
			private var _imageMask:Sprite;
			private var _imageNotFoud:Sprite;
			private var _title:TextField;
			private var _description:TextField;
		private var _info:VideoInfoVO;
		
		private var _listenerManager:ListenerManager;
		private var _loader:SimpleLoader;
		private var _bmp:Bitmap;
		
		public function VideoListItem($videoPlayer:*, $item:Sprite, $info:VideoInfoVO) {
			
			_listenerManager = ListenerManager.getInstance();
			
			_videoPlayer = $videoPlayer;
			_item = $item;
			_info = $info;
			
			_base = _item.getChildByName("base") as Sprite;
			_frame = _item.getChildByName("frame") as Sprite;
			_imageMask = _item.getChildByName("image") as Sprite;
			_imageNotFoud = _item.getChildByName("imageNotFoud") as Sprite;
			_title = _item.getChildByName("title") as TextField;
			_description = _item.getChildByName("description") as TextField;
			_image = new Sprite();
			
			_image.x = _imageMask.x;
			_image.y = _imageMask.y;
			item.addChild(_image);
			
			_image.mouseEnabled = 
			_frame.mouseEnabled = 
			_imageNotFoud.mouseEnabled = 
			_imageMask.mouseEnabled = 
			_base.mouseEnabled = 
			_title.mouseEnabled = 
			_description.mouseEnabled = false;
			
			
			_title.htmlText = _info.title;
			_description.htmlText = _info.description;
			
			_base.mouseEnabled = true;
			
			_loadThumb();
			
			_listenerManager.addEventListener(_base, MouseEvent.CLICK, _onClick);
		}
		
		/**
		 * PRIVATE
		 */
		private function _loadThumb():void{
			if (_info.thumbImg == "") {
				_image.visible = 
				_imageMask.visible = false;
			} else {
				_loader = new SimpleLoader();
				_listenerManager.addEventListener(_loader, Event.COMPLETE, _onLoadComplete);
				_listenerManager.addEventListener(_loader, ErrorEvent.ERROR, _onLoadError);
				_listenerManager.addEventListener(_loader, IOErrorEvent.IO_ERROR, _onLoadError);		
				_loader.load(_info.thumbImg);
			}
		}
		
		public function _onLoadError(e:*):void { // ErrorEvent or IOErrorEvent
			Logger.logError("[VideoListItem._onLoadError] Unable to load: " + _info.thumbImg);
			_image.visible = 
			_imageMask.visible = false;
			destroy();
		}

		public function _onLoadComplete(e:Event):void {
			_bmp = _loader.content as Bitmap;
			_bmp.smoothing = true;
			_image.addChild(_bmp);
			_image.mask = _imageMask;
			DisplayUtil.scaleProportionally(_image, _imageMask.width, _imageMask.height, "bigger");
			destroy();
		}
		
		public function destroy():void {
			if(_loader != null) {
				_listenerManager.removeAllEventListeners(_loader);
				_loader.destroy();
				_loader = null;
			}
		}
		
		/**
		 * LISTENERS
		 */
		private function _onClick(e:MouseEvent):void{
			_videoPlayer.loadById(_info.id);
		}
		
		/**
		 * SETTERS AND GETTERS
		 */
		public function get item():Sprite { return _item; }
		public function get info():VideoInfoVO { return _info; }
		
	}
	
}