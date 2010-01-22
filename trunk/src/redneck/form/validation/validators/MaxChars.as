package redneck.form.validation.validators {
import redneck.form.validation.AValidator;
	public class MaxChars extends AValidator
	{
		public var compareValue : Number;
		public function MaxChars(p_index : int = 0){
			super(p_index);
		}
		public override function validate( value:* ):Boolean{
			super.error.value = value;
			super.error.toReplace["compareValue"] = compareValue;
			return value==null ? false : (value.length < compareValue);
		}
	}
}
