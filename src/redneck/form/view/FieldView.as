package redneck.form.view {
	import flash.display.*;
	import flash.events.*;
	import flash.text.*;
	import redneck.arrange.Arrange;
	public class FieldView extends Sprite implements IFieldView {

		private var _index:int;
		private var _label:String;
		private var _initialValue:*;
		private var _value : *;
		private var _regularColor:int = 0x0;
		private var _errorColor:int= 0xff0000;
		private var _orientation : int = HORIZONTAL;
		private var _ignoreInitialValue : Boolean;
		private var _fieldWidth : Number
		private var _fieldHeight : Number
		private var _padding : Number = 0;
		public var _fieldValue : FieldContentBridge;

		public static const VERTICAL : int = 1
		public static const HORIZONTAL : int = 0;

		public var _fmtError : TextFormat;
		public var _fmtRegular : TextFormat;
		public var fieldLabel : TextField;
		/**
		*	@param p_label
		*	@param p_initialText
		*	@param p_index;
		**/
		public function FieldView( p_label:String= "", p_initialText:String="", p_index:int=0 )
		{
			super();

			fmtError = new TextFormat();
			fmtError.color = errorColor;
			
			fmtRegular = new TextFormat();
			fmtRegular.color = regularColor;
			
			fieldLabel = new TextField();
			fieldLabel.autoSize = TextFieldAutoSize.LEFT;
			addChild(fieldLabel);
			
			index = p_index;
			label = p_label;
			initialValue = p_initialText;
		}
		/**
		*	define a textformat to use in case of validation error
		**/
		public function set fmtError(value:TextFormat):void
		{
			_fmtError = value;
		}
		/**
		*	@return TextFormat
		**/
		public function get fmtError():TextFormat
		{
			return _fmtError;
		}
		/**
		*	define a textformat to use in case of validation error
		**/
		public function set fmtRegular(value:TextFormat):void
		{
			_fmtRegular = value;
		}
		/**
		*	@return TextFormat
		**/
		public function get fmtRegular():TextFormat
		{
			return _fmtRegular;
		}
		/**
		*	@return FieldContentBridge
		**/
		public function get fieldValue():FieldContentBridge{
			return _fieldValue;
		}
		/**
		*	@param	value	FieldContentBridge
		**/
		public function set fieldValue( value:FieldContentBridge ):void{
			_fieldValue = value;
			arrange();
		}
		/**
		*	
		*	Defines the tabIndex
		*	
		*	@param value int
		*	
		**/
		public function set index(value:int):void
		{
			_index = value;
			if ( fieldValue ){
				fieldValue.display.tabIndex = index
			}
		}
		/**
		*	@return int
		**/
		public function get index():int
		{
			return _index;
		}
		/**
		*	
		*	Defines a label for this view
		*	
		*	@param value String
		*	
		**/
		public function set label(value:String):void
		{
			_label = value;
			if (fieldLabel){
				fieldLabel.text = label;
				arrange();
			}
		}
		/**
		*	@return String
		**/
		public function get label():String
		{
			return _label;
		}
		/**
		*	@return *
		**/
		public function get initialValue( ):*
		{
			return _initialValue;
		}
		/**
		*	
		*	Value to init this view.
		*	
		*	@param value	*
		*	
		**/
		public function set initialValue(value:*):void
		{
			if (fieldValue){
				fieldValue.value = value;
			}
			_initialValue = value;
		}
		/**
		*	
		*	if true the initialValue will be considered invalid during the validation
		*	
		*	@param value Boolean
		*	@see initialValue
		**/
		public function set ignoreInitialValue(value:Boolean):void
		{
			_ignoreInitialValue = value;
		}
		/**
		*	@return Boolean
		**/
		public function get ignoreInitialValue():Boolean
		{
			return _ignoreInitialValue;
		}
		/**
		*	
		*	Apply this value on this view;
		*	
		*	@param value *
		*	
		**/
		public function set value(value:*):void
		{
			_value = value;
			if ( fieldValue ){
				fieldValue.value = _value;
			}
		}
		/**
		*	
		*	View value
		*	
		*	@return *
		*	
		**/
		public function get value():*
		{
			if (fieldValue){
				return (ignoreInitialValue && initialValue == fieldValue.value) ? null : fieldValue.value;
			}
			return (ignoreInitialValue && initialValue == _value) ? null : _value;
		}
		/**	
		*	
		*	This color will be applyed on <code>fmtRegular</code>
		*	
		*	@param value int
		*	
		**/
		public function set regularColor(value:int):void
		{
			_regularColor = value;
			fmtRegular.color = regularColor;
		}
		/**
		*	@return int
		**/
		public function get regularColor():int
		{
			return _regularColor;
		}
		/**	
		*	
		*	This color will be applyed on <code>fmtError</code>
		*	
		*	@param value int
		*	
		**/
		public function set errorColor(value:int):void
		{
			_errorColor = value;
			fmtError.color = errorColor;
		}
		/**
		*	@return int
		**/
		public function get errorColor():int
		{
			return _errorColor;
		}
		/**
		*	
		*	Way to layout
		*	
		*	@see FieldView.VERTICAL
		*	@see FieldView.HORIZONTAL
		*	@see arrange
		*	@return int
		*	
		**/
		public function set orientation(value:int):void
		{
			_orientation = value;
			arrange();
		}
		/**
		*	@return int	
		**/
		public function get orientation():int
		{
			return _orientation;
		}
		/**
		*	
		*	Performed when Form runs the submit.
		*	This method is to protect changes during the submit.
		*	
		**/
		
		public function freeze():void
		{
			mouseChildren = false;
			mouseEnabled = false;
		}
		/**
		*	
		*	Performed when Form after runs the submit.
		*	This method is to release all views to be changed again.
		*	
		**/
		public function unfreeze():void{
			mouseChildren = true;
			mouseEnabled = true;
		}
		/**
		*	
		*	Performed when an error is found on Field
		*	
		*	@see Field
		*	
		**/
		public function markAsInvalid(p_errors:Array=null):void{}
		/**
		*	
		*	Performed when any error is found on Field
		*	
		*	@see Field
		*	
		**/
		public function markAsValid():void{}
		/**
		*	
		*	Destroys and remove fieldValue and fieldLabel
		*	
		**/
		public function destroy():void{
			if(fieldValue){
				fieldValue.destroy();
				if (contains(fieldValue)){
					removeChild(fieldValue)
				}
				fieldValue = null;
			}
			if(fieldLabel){
				if(contains(fieldLabel)){
					removeChild(fieldLabel);
				}
				fieldLabel = null
			}
		}
		/**
		*	Define the width of this view.
		**/
		public function set fieldHeight(value:Number):void
		{
			_fieldHeight = value;
		}
		/**
		*	@return Number
		**/
		public function get fieldHeight():Number
		{
			return _fieldHeight;
		}
		/**
		*	Define the width of this view.
		**/
		public function set fieldWidth(value:Number):void
		{
			_fieldWidth = value;
		}
		/**
		*	@return Number
		**/
		public function get fieldWidth():Number
		{
			return _fieldWidth;
		}
		/**
		*	
		*	Padding when layouting
		*	
		*	@param value Number
		*	@see arrange
		*	
		**/
		
		public function set padding(value:Number):void
		{
			_padding = value;
			arrange();
		}
		/**
		*	
		*	Padding when layouting
		*	
		*	@return Number
		*	@see arrange
		*	
		**/
		public function get padding():Number
		{
			return _padding;
		}
		/**
		*
		*	Changes view layout.
		*	When VERTICAL the fieldValue will be placed under the fieldLabel, but if HORIZONTAL just beside
		*	
		*	@see Arrange
		*	@see FieldView.VERTICAL
		*	@see FieldView.HORIZONTAL
		*	
		**/
		public function arrange():void
		{
			if (!fieldLabel || !fieldValue || !fieldValue.display){
				return;
			}
			if ( orientation == VERTICAL ){
				Arrange.toBottom([fieldLabel,fieldValue],{padding_y:padding});
				Arrange.byLeft([fieldLabel,fieldValue]);
			}else{
				Arrange.toRight([fieldLabel,fieldValue],{padding_x:padding});
			}
		}
	}
}