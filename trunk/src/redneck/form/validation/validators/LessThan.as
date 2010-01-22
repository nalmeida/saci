package redneck.form.validation.validators {
import redneck.form.validation.AValidator;
	public class LessThan extends AValidator
	{
		public var compareValue : Number;
		public function LessThan(p_index : int = 0){
			super(p_index);
		}
		public override function validate( value:* ):Boolean{
			super.error.value = value;
			super.error.toReplace["compareValue"] = compareValue;
			if ( value ==null ){
				return false
			}
			var v : int = value.hasOwnProperty("length") ? value.length : 0;
			return v<compareValue
		}
	}
}
