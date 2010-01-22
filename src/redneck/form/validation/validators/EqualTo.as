package redneck.form.validation.validators {
import redneck.form.validation.AValidator;
	public class EqualTo extends AValidator
	{
		public var compareValue : *;
		public function EqualTo(p_index : int = 0){
			super(p_index);
		}
		public override function validate( value:* ):Boolean{
			super.error.value = value;
			super.error.toReplace["compareValue"] = compareValue;
			return value==null ? false : (value==compareValue);
		}
	}
}
