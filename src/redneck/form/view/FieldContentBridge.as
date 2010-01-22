/**
* FieldContentBridge is the bridge between the FieldView and the widget to provide the value. 
*
* @author igor almeida
* @version 1.0
*
**/
package redneck.form.view {
	import flash.display.*;
	public class FieldContentBridge extends Sprite {
		private var _display:*
		private var _value:*;
		public function FieldContentBridge()
		{
			super();
		}
		public function set display(value:*):void
		{
			_display = value;
		}
		public function get display():*
		{
			return _display;
		}
		public function get value():*
		{
			return _value;
		}
		public function set value(value:*):void
		{
			_value = value;
		}
		public function destroy():void{
			if(display && contains(display)){
				removeChild(display);
			}
		}
	}
}

