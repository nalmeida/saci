package redneck.form.view.selectable
{
	import flash.ui.Keyboard;
	import flash.events.*;
	import redneck.form.view.FieldView;
	import redneck.arrange.Arrange;
	public class CheckBox extends FieldView
	{
		public function CheckBox( p_label:String= "", p_initialText:String="", p_index:int=0  )
		{
			fieldValue = new ASelectableContent( );
			fieldValue.display.tabIndex = index;
			fieldValue.buttonMode = true;

			change( );
			addChild(fieldValue);

			arrange();

			super( p_label, p_initialText, p_index);
			addEventListener( FocusEvent.FOCUS_IN , keyboarListener, false, 0, true );
			addEventListener( FocusEvent.FOCUS_OUT , keyboarListener, false, 0, true );
			addEventListener( MouseEvent.CLICK, changeContent, false, 0, true );
		}

		private function keyboarListener(e:FocusEvent):void{
			if (e.type == FocusEvent.FOCUS_OUT){
				if(stage){
					stage.removeEventListener(KeyboardEvent.KEY_DOWN, changeContent);
				}
			}else{
				if(stage){
					stage.addEventListener(KeyboardEvent.KEY_DOWN, changeContent);
				}
			}
		}

		public override function set initialValue(value:*):void{
			super.initialValue = value;
			change();
		}

		private function changeContent(e:Event):void{
			if (e is KeyboardEvent && (e as KeyboardEvent).keyCode != Keyboard.SPACE){
				return
			}
			value = value==true ? false : true;
			change();
		}

		public function change( ):void{
			if (fieldValue && fieldValue.display){
				fieldValue.display.graphics.clear();
				fieldValue.display.graphics.lineStyle(1,0,1);
				fieldValue.display.graphics.beginFill(0,0);
				fieldValue.display.graphics.drawRect(0,0,10,10);
				if (fieldValue.value){
					fieldValue.display.graphics.moveTo(2,2);
					fieldValue.display.graphics.lineTo(8,8);
					fieldValue.display.graphics.moveTo(8,2);
					fieldValue.display.graphics.lineTo(2,8);
				}
				fieldValue.display.graphics.endFill();
			}
		}

		public override function markAsInvalid(p_errors:Array=null):void{
			change()
		}

		public override function markAsValid():void{
			change();
		}

		public override function arrange():void
		{
			if (!fieldLabel || !fieldValue || !fieldValue.display){
				return;
			}
			Arrange.toRight([fieldValue,fieldLabel],{padding_x:padding});
			Arrange.centerY([fieldLabel,fieldValue]);
		}
		
		public override function destroy():void{
			if(stage){
				stage.removeEventListener(KeyboardEvent.KEY_DOWN, changeContent);
			}
			removeEventListener( FocusEvent.FOCUS_IN , keyboarListener);
			removeEventListener( FocusEvent.FOCUS_OUT , keyboarListener);
			removeEventListener( MouseEvent.CLICK, changeContent);
			super.destroy();
		}
	}
}