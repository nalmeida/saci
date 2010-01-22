package redneck.form.view.textinput {

	import flash.text.*;
	import redneck.form.view.*;
	import flash.events.*;
	import redneck.arrange.*;

	public class MultipleInputs extends MultiViews{
		public var fields : Array
		public var separator : String = "-";
		/**
		* 
		* @param	p_label
		* @param	p_initialText
		* @param	p_index
		* 
		**/
		public function MultipleInputs( p_label:String="", p_initialText:String="", p_index:int=0 ):void{
			super( p_label, p_initialText, p_index );
			orientation = FieldView.VERTICAL;
			fieldsOrientation = FieldView.HORIZONTAL;
			fields = [];
		}
		/**
		*	
		*	Register as much FieldView as you want
		*	
		*	@param p_field FieldView
		*	@see FieldView
		**/
		public function addView( p_field : FieldView ) : void{
			if (p_field){
				fields.push( addChild(p_field) as FieldView );
				lastIndex = fields.length-1 + index;
				p_field.index = lastIndex;
				arrange( );
			}
		}
		/**
		*	
		*	Concatenate all values with <code>separator</code>
		*	
		*	@return *
		*	
		**/
		public override function get value():*
		{
			var result : Array = [];
			fields.forEach( function( item:FieldView, ...rest ):void{
				result.push(item.value);
			}, null );
			return result.join(separator);
		}
		/**
		*	
		*	Performs this method in all fields
		*	
		**/
		public override function markAsInvalid(p_errors:Array=null):void{
			fields.forEach( function( item:FieldView, ...rest ):void{
				item.markAsInvalid();
			}, null );
		}
		/**
		*	
		*	Performs this method in all fields
		*	
		**/
		
		public override function markAsValid():void{
			fields.forEach( function( item:FieldView, ...rest ):void{
				item.markAsValid();
			}, null );
		}
		/**
		*	
		*	destroy all fieds
		*	
		**/
		
		public override function destroy():void{
			super.destroy();
			fields.forEach( function( item:FieldView, ...rest ):void{
				if (item){
					item.destroy();
					if ( contains( item ) ){
						removeChild( item )
						item = null;
					}	
				}
			}, null );
		}
		/**
		*	Arranging fields layout
		*	
		*	@see orientation
		*	@sse fieldsOrientation
		*	@see Arrange
		*	
		**/
		public override function arrange():void
		{
			if (!fieldLabel || !fields || fields.length==0 ){
				return;
			}
			if ( orientation == FieldView.VERTICAL ){
				Arrange.toBottom([fieldLabel, fields[0]], {padding_y:padding});
				Arrange.byLeft([fieldLabel, fields[0]] );
			}else{
				Arrange.toRight([fieldLabel, fields[0]], {padding_x:padding});
			}
			if ( fieldsOrientation == FieldView.VERTICAL ){
				Arrange.toBottom( fields, {padding_y:fieldsPadding});
			}else{
				Arrange.byTop( fields );
				Arrange.toRight( fields, {padding_x:fieldsPadding});
			}
		}
	}
}

