package redneck.form.validation {
	public interface IValidator {
		function get index ( ) : int;
		function get isValid ( ) : Boolean;
		function get error ( ) :AValidatorError;
		function validate( value:* ) : Boolean;
	}
}
