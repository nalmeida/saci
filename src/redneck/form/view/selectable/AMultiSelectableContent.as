package redneck.form.view.selectable
{
	import flash.events.*;
	import flash.display.*;
	import redneck.form.view.FieldView;
	import redneck.form.view.FieldContentBridge;
	import redneck.form.view.selectable.ASelectableContent;
	public class AMultiSelectableContent extends FieldContentBridge
	{
		private var _options : Array = []
		public var padding: Number = 0;
		public var selectedItem : ASelectableItem
		public function AMultiSelectableContent()
		{
			super();
			display = addChild(new Sprite()) as Sprite;
			addChild(display);
		}
		/**
		*	
		*	Add a new item to this list
		*	
		*	@param p_item	ASelectableItem
		*	
		**/
		public function addItem( p_item : ASelectableItem ):void{
			options.push( display.addChild( p_item ) as ASelectableItem );
			p_item.addEventListener( Event.CHANGE, changeContent, false, 0, true )
		}
		/**
		*	
		*	Changes the current selectedItem and disable the others.
		*	
		**/
		public function changeContent(e:Event):void{
			if (e){
				selectedItem = e.currentTarget as ASelectableItem
				selectedItem.selected = true
				options.forEach( function(item:ASelectableItem, ...rest ):void{
					if ( item != selectedItem ){
						item.selected = false;
					}
				} ,null );
				dispatchEvent(new Event(Event.SELECT));
			}
		}
		/**
		*	Set the selected item by value.	
		**/
		public function setSelected( p_value : * ):void{
			options.forEach( function(item : ASelectableItem, ...rest):void{
				if ( item.value == p_value ){
					item.dispatchEvent( new Event(Event.CHANGE) );
					return;
				}
			} , null )
		}
		/**
		*	
		*	Current options list
		*	
		*	@return Array
		*	
		**/
		public function get options():Array
		{
			return _options;
		}
		/**
		*	
		*	Return the current seletect item value.
		*	
		*	@see ASelectableItem
		*	
		*	@return *
		**/
		public override function get value():*
		{
			return selectedItem ? selectedItem.value : null;
		}
		/**
		*	
		* destroying all items
		*	
		**/
		public override function destroy():void{
			
			options.forEach( function(item:ASelectableItem, ...rest ):void{
					item.removeEventListener( Event.CHANGE, changeContent );
					item.destroy();
					if ( display.contains( item ) ){
						display.removeChild( item );
					}
					item = null
				} ,null );

			selectedItem = null;
			_options = [];
			super.destroy();
		}
	}
}

