package redneck.form.validation {
	import br.com.stimuli.string.printf
	import redneck.form.validation.IValidatorError;
	public class AValidatorError implements IValidatorError {
		private var _errorMessage : String;
		private var _errorId : *;
		private var _value : *
		private var _toReplace: Object
		public function AValidatorError()
		{
			super();
			_toReplace = {}
		}
		public function get toReplace():Object
		{
			_toReplace["value"] = value;
			return _toReplace;
		}
		public function set value(p_value:*):void
		{
			_value = p_value;
		}
		public function get value():*
		{
			return _value;
		}
		public function set errorMessage(value:String):void
		{
			_errorMessage = value;
		}
		public function get errorMessage( ) : String{
			return printf(_errorMessage,toReplace);
		}
		public function set errorId(value:*):void
		{
			_errorId = value;
		}
		public function get errorId():*
		{
			return _errorId;
		}
		public function get message () : String{
			return errorMessage ||  errorId;
		}
		public function toString():String{
			return "[AValidatorError errorId:"+errorId+" errorMessage:"+errorMessage+"]";
		}
	}
}

