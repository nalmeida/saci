package redneck.form.validation {
	public interface IValidatorError {
		function get toReplace() : Object;
		function get value():*;
		function get errorMessage( ) : String;
		function get errorId( ) : *;
		function get message () : String;
	}
}
