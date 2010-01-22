package redneck.project.contextmenu {
	import flash.ui.*;
	import flash.events.*;
	import flash.display.*;
	public class ContextNavigation extends EventDispatcher {
	
		private var contextMenu : ContextMenu;
		public var tailoredItems : Array
		public var selected : ContextMenuItem;
		public static const COPY_LOG : String = "Copy Log to Clipboard";
		public function ContextNavigation( p_context : Sprite )
		{
			super();
			contextMenu = new ContextMenu();
			contextMenu.addEventListener(ContextMenuEvent.MENU_SELECT, menuSelectHandler);

			contextMenu.hideBuiltInItems();
			p_context.contextMenu = contextMenu;
			tailoredItems = new Array();
		}
		
		public function menuSelectHandler(e:Event):void{
			dispatchEvent(new Event(Event.OPEN));
		}
		
		public function clear():void{
			contextMenu.customItems = [];
		}

		public function add( p_label:String ):void{
			var item:ContextMenuItem = new ContextMenuItem( p_label );
			contextMenu.customItems.push( item );
			tailoredItems.push( item.caption );
			item.addEventListener( ContextMenuEvent.MENU_ITEM_SELECT, menuItemSelectHandler );
		}

		private function menuItemSelectHandler(event:ContextMenuEvent):void {
			if (event.currentTarget is ContextMenuItem){
				if ( tailoredItems.indexOf( event.currentTarget.caption ) != -1 ){
					selected = event.currentTarget as ContextMenuItem;
					dispatchEvent( new Event(Event.CHANGE) );
				}
			}
		}
	}
}