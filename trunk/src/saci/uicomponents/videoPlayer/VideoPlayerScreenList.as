package saci.uicomponents.videoPlayer {
	
	import flash.text.TextField;
	import redneck.video.VideoPlayer;
	import flash.display.Sprite
	import flash.utils.describeType;
	import saci.util.DisplayUtil;
	
	/**
	 * @author Nicholas Almeida
	 */
	public class VideoPlayerScreenList extends VideoPlayerScreen{
		
		protected var _listTitle:Sprite;
			protected var _title:TextField;
		protected var _listItemsHolder:Sprite;
			protected var _listItemModel:Sprite;
		protected var _blocker:Sprite;
		protected var _playlist:XML;
		protected var _pagination:int = 2;
		protected var _arrItems:Array;
		
		public function VideoPlayerScreenList($videoPlayer:*, $skin:Sprite) {
			super($videoPlayer, $skin);
			_arrItems = [];
			_listTitle = _listContainer.getChildByName("listTitle") as Sprite;
				_title = _listTitle.getChildByName("title") as TextField;
			_listItemsHolder = _listContainer.getChildByName("listItemsHolder") as Sprite;
				_listItemModel = _listItemsHolder.getChildByName("listItem") as Sprite;
			_blocker = _listContainer.getChildByName("blocker") as Sprite;
			
			_listItemsHolder.removeChild(_listItemModel);
			
			refresh();
			
			//hideList();
			
			_title.mouseEnabled = false;
			_blocker.mouseEnabled = true;
			_blocker.useHandCursor = false;
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
		
		public function get blocker():Sprite { return _blocker; }
		
		public function get playlist():XML { return _playlist; }
		public function set playlist(value:XML):void {
			_playlist = value;
			_createList();
		}
		
		/**
		 * PRIVATE
		 */
		
		private function _createList():void{
			_title.text = _playlist.config.title;
			if(_playlist.config.pagination != undefined && _playlist.config.pagination != "") {
				_pagination = int(_playlist.config.pagination);
			}
			
			var len:int = _videoPlayer.arrMedia.length;
			
			for (var i:int = 0; i < len; i++) {
				var item:Sprite = DisplayUtil.duplicateDisplayObject(_listItemModel) as Sprite;
				
				_arrItems[_arrItems.length] = new VideoListItem(_videoPlayer, item, _videoPlayer.arrMedia[i]);
				
				_listItemsHolder.addChild(item);
				item.y = item.height * i;
			}
			
			refresh();
		}
		
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
		}
	}
	
}