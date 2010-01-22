package redneck.form.view {

	import flash.text.*;
	import redneck.form.view.*;
	import flash.events.*;

	import redneck.arrange.Arrange;
	import redneck.form.view.selectable.AMultiSelectableContent;
	public class MultiViews extends FieldView{
		private var _lastIndex : int;
		private var _fieldsOrientation : int = FieldView.HORIZONTAL;
		private var _fieldsPadding : Number = 0;
		/**
		* 
		* @param	p_label
		* @param	p_initialText
		* @param	p_index
		* 
		**/
		public function MultiViews( p_label:String="", p_initialText:String="", p_index:int=0 ):void{
			super( p_label, p_initialText, p_index );
		}
		/**
		*	Returns the last index of the last registered view
		*	@see addView
		*	@return Number
		**/
		public function get lastIndex():Number
		{
			return _lastIndex;
		}
		/**
		*	Returns the last index of the last registered view
		*	@see addView
		*	@return Number
		**/
		public function set lastIndex(value:Number):void
		{
		 	_lastIndex = value ;
		}
		/**
		*	
		*	The current FieldView.orientation is related to the label 
		*	and all fields, and fieldsOrientation is related just to all registered fields.
		*	
		*	@param value int
		*	
		**/
		public function set fieldsOrientation(value:int):void
		{
			_fieldsOrientation = value;
		}
		/**
		*	@return int
		**/
		public function get fieldsOrientation():int
		{
			return _fieldsOrientation;
		}
		/**
		*	
		*	
		*	@return Number
		*	
		**/
		public function set fieldsPadding(value:Number):void
		{
			_fieldsPadding = value;
		}
		/**
		*	@return Number
		**/
		public function get fieldsPadding():Number
		{
			return _fieldsPadding;
		}
	}
}

