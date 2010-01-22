package redneck.form.view.selectable
{
	import flash.events.*;
	import flash.display.*;
	import flash.text.*;
	import redneck.form.view.*;
	import redneck.arrange.*;
	import redneck.form.view.FieldView;
	import redneck.util.display.getPlaceHolder;
	public class ComboBox extends MultipleChoices
	{
		public var button : Sprite;
		public var currentValue : TextField;
		public var isOpened : Boolean;

		/**
		*	
		*	@param p_label
		*	@param p_initialText
		*	@param p_initialText
		*	
		*	@see FieldView;
		**/
		public function ComboBox( p_label:String= "", p_initialText:String="", p_index:int=0  ) : void{
			super( p_label, p_initialText, p_index);
			fieldsOrientation = FieldView.VERTICAL;
			createUI();
			close();
		}

		public function createUI():void{

			currentValue = addChild(new TextField()) as TextField;
			currentValue.selectable = false;
			currentValue.autoSize = TextFieldAutoSize.LEFT;
			currentValue.border = true;
			
			if ( (fieldValue as AMultiSelectableContent).selectedItem ){
				currentValue.text = (fieldValue as AMultiSelectableContent).selectedItem.label;
			}else if( (fieldValue as AMultiSelectableContent).options.length>0 ){
				currentValue.text = (fieldValue as AMultiSelectableContent).options[0].label;
			}else{
				currentValue.text = " ";
			}

			button = addChild( getPlaceHolder(15,15,0xffffff,1) ) as Sprite;
			button.addEventListener( MouseEvent.CLICK, changeStatus );
			arrange();
		}

		public function changeStatus(e:*=null):void{
			if (isOpened){
				close();
			}else{
				open();
			}
		}

		public override function change(e:Event):void{
			dispatchEvent(e.clone());
			if (currentValue){
				currentValue.text = (fieldValue as AMultiSelectableContent).selectedItem.label;
			}
			close( );
			arrange();
		}

		public function open(e:*=null):void{
			fieldValue.visible = true;
			if (parent){
				parent.swapChildren( this , parent.getChildAt( parent.numChildren-1 ) );
			}
			if(this.stage){
				this.stage.addEventListener(MouseEvent.MOUSE_UP,changeStatus);
			}
			if (button){
				button.mouseEnabled = false;
				button.mouseChildren = false;
			}
			isOpened = true;
		}

		public function close(e:*=null):void{
			if (fieldValue){
				fieldValue.visible = false;
			}
			if(this.stage){
				this.stage.removeEventListener(MouseEvent.MOUSE_UP,changeStatus);
			}
			if (button){
				button.mouseEnabled = true;
				button.mouseChildren = true;
			}
			isOpened = false;
		}

		public override function arrange():void{
			super.arrange();

			if (currentValue){

				Arrange.toBottom( [fieldLabel, currentValue] );
				Arrange.byLeft( [fieldLabel, currentValue] );

				Arrange.toRight( [currentValue, button], {padding_x:5} );
				Arrange.byTop( [currentValue, button] );

				Arrange.toBottom( [currentValue, fieldValue] );
			}
		}
	}
}