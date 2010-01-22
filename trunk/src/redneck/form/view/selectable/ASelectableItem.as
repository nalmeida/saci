package redneck.form.view.selectable
{
	import flash.display.*;
	import flash.events.*;
	public class ASelectableItem extends Sprite
	{
		private var _selected : Boolean;
		private var _label : *
		private var _value : *
		public function ASelectableItem()
		{
			super();
		}
		public function get selected():Boolean
		{
			return _selected;
		}
		public function set selected(value:Boolean):void
		{
			_selected = Boolean(value);
		}
		public function set label(value:*):void
		{
			_label = value;
		}
		public function get label():*
		{
			return _label;
		}
		public function set value(value:*):void
		{
			_value = value;
		}
		public function get value():*
		{
			return _value;
		}
		public function destroy():void{
			//
		}
		public function changeValue(e:*):void{
			dispatchEvent( new Event(Event.CHANGE) );
		}
	}
}

