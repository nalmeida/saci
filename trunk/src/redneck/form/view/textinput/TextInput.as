/**
*
* @author igor almeida
* @version 1.1
*
**/
package redneck.form.view.textinput {
	import flash.text.*;
	import redneck.form.view.*;
	import flash.events.*;
	public class TextInput extends FieldView{
		/**
		* 
		* Default string text input.
		* 
		* @param	p_label
		* @param	p_initialText
		* @param	p_index
		* 
		**/
		public function TextInput( p_label:String="", p_initialText:String="", p_index:int=0 ):void{
			super(p_label,p_initialText,p_index);

			// creating default input content.
			fieldValue = new AInputContent( );
			fieldValue.display.tabIndex = index;
			with(fieldValue.display){
				type = TextFieldType.INPUT; 
				autoSize = TextFieldAutoSize.LEFT;
				border = true;
				borderColor = super.regularColor;
				defaultTextFormat = fmtRegular;
				width = 100;
				autoSize = TextFieldAutoSize.NONE
			}
			addChild(fieldValue);
			addEventListener( FocusEvent.FOCUS_IN , changeContent, false, 0, true );
			addEventListener( FocusEvent.FOCUS_OUT , changeContent, false, 0, true );
			initialValue = initialValue;
		}
		private function changeContent(e:FocusEvent):void{
			if(e.type == FocusEvent.FOCUS_IN){
				if (fieldValue.value == super.initialValue){
					fieldValue.value = "";
				}
			}else if ( e.type == FocusEvent.FOCUS_OUT ){
				if (fieldValue.value=="" && super.initialValue!=null ){
					fieldValue.value = super.initialValue;
				}
			}
		}
		public override function markAsInvalid(p_errors:Array=null):void{
			if(fieldValue.display){
				fieldValue.display.borderColor = errorColor;
				fieldValue.display.setTextFormat(fmtError);
			}
		}
		public override function markAsValid():void{
			if(fieldValue.display){
				fieldValue.display.borderColor = regularColor;
				fieldValue.display.setTextFormat(fmtRegular);
				fieldValue.display.defaultTextFormat = fmtRegular;
			}
		}
		public override function set fieldHeight(p_value:Number):void
		{
			super.fieldHeight = p_value;
			if (fieldValue.display){
				fieldValue.display.height = fieldHeight;
			}
		}
		public override function set fieldWidth(p_value:Number):void
		{
			super.fieldWidth = p_value;
			if(fieldValue.display){
				fieldValue.display.width = fieldWidth;
			}
		}
		public override function set fmtRegular(value:TextFormat):void
		{
			super.fmtRegular = value;
			if (fieldValue && fieldValue.display){
				fieldValue.display.defaultTextFormat = fmtRegular;
				fieldValue.display.text = fieldValue.display.text;
			}
		}
		public override function freeze():void{
			if(fieldValue.display){
				addEventListener( FocusEvent.FOCUS_IN , changeContent, false, 0, true );
				addEventListener( FocusEvent.FOCUS_OUT , changeContent, false, 0, true );
				fieldValue.display.type = TextFieldType.DYNAMIC
			}
			super.freeze()
		}
		public override function unfreeze():void{
			if(fieldValue.display){
				removeEventListener( FocusEvent.FOCUS_IN , changeContent);
				removeEventListener( FocusEvent.FOCUS_OUT , changeContent );
				fieldValue.display.type = TextFieldType.INPUT;
			}
			super.unfreeze();
		}
		public override function set regularColor(value:int):void
		{
			super.regularColor = value;
			if (fieldValue && fieldValue.display){
				fieldValue.display.borderColor = super.regularColor;
				fieldValue.display.defaultTextFormat = fmtRegular;
			}
		}
		public override function set errorColor(value:int):void
		{
			super.errorColor = value;
			if (fieldValue && fieldValue.display){
				fieldValue.display.setTextFormat(fmtError);
			}
		}
		public override function destroy():void{
			removeEventListener( FocusEvent.FOCUS_IN , changeContent);
			removeEventListener( FocusEvent.FOCUS_OUT , changeContent );
			super.destroy();
		}
	}
}