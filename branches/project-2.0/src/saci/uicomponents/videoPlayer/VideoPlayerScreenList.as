package saci.uicomponents.videoPlayer {
	
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import redneck.video.VideoPlayer;
	import flash.display.Sprite
	import flash.utils.describeType;
	import saci.util.DisplayUtil;
	
	/**
	 * @author Nicholas Almeida
	 */
	public class VideoPlayerScreenList extends VideoPlayerScreen{
		
		protected var _listPrevious:Sprite;
		protected var _listNext:Sprite;
		protected var _listTitle:Sprite;
			protected var _title:TextField;
		protected var _listItemsHolder:Sprite;
			protected var _listItemModel:Sprite;
		protected var _blocker:Sprite;
		protected var _playlist:XML;
		protected var _arrItems:Array;
		
		public function VideoPlayerScreenList($videoPlayer:*, $skin:Sprite) {
			super($videoPlayer, $skin);
			_arrItems = [];
			_listTitle = _listContainer.getChildByName("listTitle") as Sprite;
				_title = _listTitle.getChildByName("title") as TextField;
			_listItemsHolder = _listContainer.getChildByName("listItemsHolder") as Sprite;
				_listItemModel = _listItemsHolder.getChildByName("listItem") as Sprite;
			_blocker = _listContainer.getChildByName("blocker") as Sprite;
			_listPrevious = _listContainer.getChildByName("listPrevious") as Sprite;
			_listNext = _listContainer.getChildByName("listNext") as Sprite;
			
			_listItemsHolder.removeChild(_listItemModel);
			
			refresh();
			
			hideList();
			
			_title.mouseEnabled = false;
			_blocker.mouseEnabled = true;
			_blocker.useHandCursor = false;
			
			_listPrevious.mouseChildren = 
			_listNext.mouseChildren = false;
			_listPrevious.buttonMode = 
			_listNext.buttonMode = true;
			
			_listenerManager.addEventListener(_listPrevious, MouseEvent.CLICK, _videoPlayer.prevList);
			_listenerManager.addEventListener(_listNext, MouseEvent.CLICK, _videoPlayer.nextList);
		}
		
		public function showList():void {
			showBlocker();
			_listContainer.visible = true;
		}
		
		public function hideList():void {
			hideBlocker();
			_listContainer.visible = false;
		}
		
		public function showBlocker():void {
			_blocked = true;
			blocker.visible = true;
		}
		
		public function hideBlocker():void {
			_blocked = false;
			blocker.visible = false;
		}
		
		public function createList():void{
			_title.text = _playlist.config.title;
			destroyList();
			_arrItems = [];
			
			var page:Array = _videoPlayer.arrPages[_videoPlayer.currentPage];
			var len:int = page.length;
			for (var i:int = 0; i < len; i++) {
				var item:Sprite = DisplayUtil.duplicateDisplayObject(_listItemModel) as Sprite;
				
				_arrItems[_arrItems.length] = new VideoListItem(_videoPlayer, item, page[i]);
				
				_listItemsHolder.addChild(item);
				item.y = item.height * i;
			}
			refresh();
		}
		
		public function destroyList():void {
			var len:int = _arrItems.length;
			for (var i:int = 0; i < len; i++) {
				_arrItems[i].destroy();
				DisplayUtil.removeChilds(_listItemsHolder);
			}
		}
		
		/**
		 * PRIVATE
		 */
		
		/**
		 * OVERRIDES
		 */
		
		override protected function _removeListContainer():void {
			// DO NOT REMOVE
		}
		
		override public function refresh():void {
			super.refresh();
			
			_listTitle.x = (base.width * .5) - (_listTitle.width * .5);
			_listItemsHolder.x = (base.width * .5) - (_listItemsHolder.width * .5);
			
			_listPrevious.y = (base.height * .5) - (_listPrevious.height * .5);
			_listNext.y = (base.height * .5) - (_listNext.height * .5);
			_listNext.x = (base.width) - (_listNext.width);
		}
		
		/**
		 * GETTERS AND SETTERS
		 */
		public function get blocker():Sprite { return _blocker; }
		
		public function get playlist():XML { return _playlist; }
		public function set playlist(value:XML):void {
			_playlist = value;
		}
		
		public function get listNext():Sprite { return _listNext; }
		public function get listPrevious():Sprite { return _listPrevious; }
	}
	
}