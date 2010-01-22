/**
* @author igor almeida
* @version 0.2
**/
package redneck.form.field {
	import redneck.form.validation.*;
	import redneck.form.view.*;
	import redneck.form.validation.AValidatorError;
	public class Field {
		private var _view : FieldView;
		private var _isValid : Boolean;
		private var _validators : Array;
		private var _errors : Array;
		private var _value : *;
		private var _name : String;
		private var _index : int;
		private var _onlyClient : Boolean;
		/* the defaultErrorMessage will be just used whether any form validation has passed and the field was obligatory */
		public var defaultErrorMessage : AValidatorError
		/* define if this field is a obligatory field */
		public var obligatory : Boolean;
		/**
		*	
		*	Creates a new field
		*	
		*	@param p_name	String	field name. This property will like a property name when the form will be submmited.
		*	@param p_value	*		initial value
		*	@param p_index	int		this index will be the reference when the form start the all fields validation.
		*	
		**/
		public function Field( p_name : String, p_index :int = 0, p_value:* = null )
		{
			super();
			_validators = [];
			_errors = [];
			_name = p_name;
			_index = p_index;
			value = p_value;
			_isValid = (obligatory==true);
			defaultErrorMessage = new AValidatorError();
			defaultErrorMessage.errorMessage = name + " is invalid!";
		}
		/**
		*	field name.
		*	@return  String
		**/
		public function get name():String
		{
			return _name;
		}
		/**
		*	field index
		*	@return int
		**/
		public function get index():int
		{
			return _index;
		}
		/**
		*	defines if this field will be sent or not
		**/
		public function set onlyClient(value:Boolean):void
		{
			_onlyClient = value;
		}
		/**
		*	@return Boolean;
		**/
		public function get onlyClient():Boolean
		{
			return _onlyClient;
		}
		/**	
		*	Inject a new view que control the value of the field.	
		*	@param p_view	IView
		**/
		public function set view( p_view: FieldView):void{
			var s : * = value;
			_view = p_view;
		}
		/**
		*	returns the current field view.
		*	@return IView
		**/
		public function get view():FieldView
		{
			return _view;
		}
		/**
		*	Return the result for this field validation.
		*	@return Boolean
		**/
		public function get isValid():Boolean
		{
			return _isValid;
		}
		public function addValidator( p_validator : IValidator):Boolean
		{
			if(p_validator){
				_validators.push(p_validator);
				_validators = _validators.sortOn( "index", Array.NUMERIC );
				return true;
			}
			return false;
		}
		/**
		*	return the current validators
		*	@return Array
		**/
		public function get validators():Array
		{
			return _validators;
		}
		/**
		*	return all erros for this field.
		*	@sse AValidatorError
		*	@return Array
		**/
		public function get errors():Array
		{
			return _errors;
		}
		/**
		*	set the value of the field.
		**/
		public function set value(value:*):void
		{
			_value = value;
		}
		/**
		*	return this field value.
		*	@return *
		**/
		public function get value():*
		{
			return view ? view.value : _value;
		}
		/**
		*	run trough all validators and check da data consistency.
		*	@return Boolean
		**/
		public function validate():Boolean
		{
			_errors = [];
			if ( obligatory ){
				if (validators.length==0 && value==null){
					 errors.push(defaultErrorMessage);
				}else{
					validators.forEach( function ( item:IValidator, ...rest ) : void{
						var result : Boolean = item.validate(value);
						if (!result){
							errors.push( item.error );
						}
					} );
				}
			}
			_isValid = errors.length==0
			if (view){
				if (isValid){
					view.markAsValid();
				}else{
					view.markAsInvalid(errors);
				}	
			}
			return _isValid;
		}
		/**
		*	return to form the value on GET pattern
		*	@return String
		*	@example fieldName=redneck@farm.com
		**/
		public function parsedValue():String{
			if( isValid ){
				return name+"="+String(value);
			}
			return "";
		}
		public function destroy():void{
			if(view){
				_view.destroy();
				_view = null;
			}			
			_validators = null;
			_errors = null;
		}
		public function toString():String{
			return "[Field name:" + name + " value:" + value +"]";
		}
	}
}

