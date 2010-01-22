package redneck.form.view.selectable
{
	import flash.display.*;
	import flash.text.*;
	import flash.events.*;
	import redneck.arrange.*;
	import redneck.form.view.selectable.*;
	public class RadioItem extends ASelectableItem
	{
		public var icon : Sprite;
		public var fieldLabel : TextField;
		private var toAlign : Array;
		public function RadioItem()
		{
			super();
			toAlign = [];
			icon  = addChild( new Sprite() ) as Sprite;
			toAlign.push( icon )
			draw();

			fieldLabel = addChild( new TextField() ) as TextField;
			fieldLabel.selectable = false;
			fieldLabel.autoSize = TextFieldAutoSize.LEFT;
			toAlign.push( fieldLabel )
			arrange();
			
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
		*	Arrange content
		*	
		**/
		public function arrange():void{
			Arrange.toRight( toAlign, {padding_x:5} );
		}
		/**
		*	
		*	Draw icon
		*	
		**/
		public function draw( ):void{
			with(icon.graphics){
				clear();
				beginFill( 0xffffff ,1 );
				lineStyle(1, 0x0, 1);
				drawCircle(5,5,5);
				if (selected){
					beginFill(0x0,1)
					drawCircle(5,5,2);
				}
			}
		}
		/**
		*	
		*	@parm value
		*	
		**/
		public override function set selected(value:Boolean):void
		{
			super.selected = Boolean(value);
			draw( );
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
			arrange();
		}
		/**
		*	
		*	removing all listeners and instances from stage.
		*	
		**/
		public override function destroy():void{
			this.removeEventListener(MouseEvent.CLICK, changeValue );
			if (icon){
				if (contains(icon)){
					removeChild(icon)
				}
				icon = null;
			}
			
			if ( fieldLabel ){
				if (contains(fieldLabel)){
					removeChild(fieldLabel)
				}
				fieldLabel = null;
			}
			toAlign = null;
			super.destroy();
		}
	}
}

