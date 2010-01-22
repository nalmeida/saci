package redneck.form.view.selectable
{
	import flash.events.*;
	import redneck.form.view.*;
	import redneck.arrange.*;
	public class MultipleChoices extends MultiViews
	{
		/**
		*	
		*	@param p_label
		*	@param p_initialText
		*	@param p_initialText
		*	
		*	@see FieldView;
		**/
		public function MultipleChoices( p_label:String= "", p_initialText:String="", p_index:int=0  ) : void{
			super( p_label, p_initialText, p_index);

			fieldValue = new AMultiSelectableContent( );
			fieldValue.display.tabIndex = index;
			fieldValue.buttonMode = true;
			addChild(fieldValue);

			orientation = FieldView.VERTICAL
		}
		/**
		*	
		*	@param p_item
		*	
		*	@return MultipleChoices
		*	
		**/
		public function addOption( p_item : ASelectableItem ):MultipleChoices{
			if (p_item){
				(fieldValue as AMultiSelectableContent ).addItem( p_item );
				fieldValue.addEventListener( Event.SELECT, change, false, 0, true );
				if ( !(fieldValue as AMultiSelectableContent ).selectedItem && initialValue!=null && initialValue.length>0 ){
					(fieldValue as AMultiSelectableContent ).setSelected( initialValue );
				}
				arrange( );
				return this;
			}
			return null;
		}
		public function change(e:Event):void{
			dispatchEvent(e.clone())
		}
		/**
		*	
		*	arrange items
		*	
		**/
		public override function arrange():void{
			super.arrange();
			if ( fieldValue is AMultiSelectableContent && ( fieldValue as AMultiSelectableContent ).options ){
				if ( fieldsOrientation == FieldView.VERTICAL ){
					Arrange.toBottom( ( fieldValue as AMultiSelectableContent ).options , {padding_y:fieldsPadding});
				}
				else{
					Arrange.toRight( ( fieldValue as AMultiSelectableContent ).options , {padding_x:fieldsPadding});
				}
			}
		}

		public override function markAsInvalid(p_errors:Array=null):void{
			//TODO
		}

		public override function markAsValid():void{
			//TODO
		}

		public override function destroy():void{
			fieldValue.removeEventListener( Event.SELECT, change );
			super.destroy();
		}
	}
}