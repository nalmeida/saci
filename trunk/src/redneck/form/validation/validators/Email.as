package redneck.form.validation.validators {
import redneck.form.validation.AValidator;
	public class Email extends AValidator
	{
		public var compareValue : RegExp = /([\w-\.]+)@((?:[\w]+\.)+)([a-zA-Z]{2,4})/;
		public function Email(p_index : int = 0){
			super(p_index);
		}
		public override function validate( value:* ):Boolean{
			super.error.value = value;
			return value==null ? false : compareValue.test( value );
		}
	}
}