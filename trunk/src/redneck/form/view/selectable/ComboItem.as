package redneck.form.view.selectable
{
	import flash.display.*;
	import flash.text.*;
	import flash.events.*;
	import redneck.arrange.*;
	import redneck.form.view.selectable.*;
	public class ComboItem extends ASelectableItem
	{
		public var fieldLabel : TextField;
		public function ComboItem()
		{
			super();

			fieldLabel = addChild( new TextField() ) as TextField;
			fieldLabel.autoSize = TextFieldAutoSize.LEFT;
			fieldLabel.selectable = false;
			fieldLabel.mouseEnabled = false;

			addEventListener(MouseEvent.CLICK, changeValue, false, 0, true )
			addEventListener( FocusEvent.FOCUS_IN , keyboarListener, false, 0, true );
			addEventListener( FocusEvent.FOCUS_OUT , keyboarListener, false, 0, true );
		}
		/**
		*	manage keyboard interaction
		**/
		public function keyboarListener(e:FocusEvent):void{
			//TODO
			if (e.type == FocusEvent.FOCUS_OUT){
				if(stage){
					stage.removeEventListener(KeyboardEvent.KEY_DOWN, changeValue);
				}
			}else{
				if(stage){
					stage.addEventListener(KeyboardEvent.KEY_DOWN, changeValue);
				}
			}
		}
		/**
		*	
		*	@param value
		*	
		**/
		public override function set label(value:*):void
		{
			super.label = value;
			if ( fieldLabel ){
				fieldLabel.text = label;
			}
		}
		/**
		*	
		*	removing all listeners and instances from stage.
		*	
		**/
		public override function destroy():void{
			this.removeEventListener(MouseEvent.CLICK, changeValue );
			if ( fieldLabel ){
				if (contains(fieldLabel)){
					removeChild(fieldLabel)
				}
				fieldLabel = null;
			}
			super.destroy();
		}
	}
}

