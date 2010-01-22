package redneck.form.validation {
	public class AValidator implements IValidator{
		private var _index : int;
		private var _isValid : Boolean;
		private var _error : AValidatorError;
		public function AValidator(p_index : int = 0)
		{
			super();
			_index = p_index;
			error = new AValidatorError();
		}
		public function get index ( ):int{
			return _index;
		}
		public function get isValid ( ):Boolean{
			return _isValid;
		}
		public function set error(value:AValidatorError):void
		{
			_error = value;
		}
		public function get error( ):AValidatorError{
			return _error;
		}
		public function validate( value:* ):Boolean{
			return true;
		}
	}
}
