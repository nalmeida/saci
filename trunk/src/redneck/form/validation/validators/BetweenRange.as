package redneck.form.validation.validators {
import redneck.form.validation.AValidator;
	public class BetweenRange extends AValidator
	{
		public var min : Number;
		public var max : Number;
		public function BetweenRange(p_index : int = 0){
			super(p_index);
		}
		public override function validate( value:* ):Boolean{
			super.error.value = value;
			super.error.toReplace["min"] = min;
			super.error.toReplace["max"] = max;
			if (value==null){
				return false
			}
			var v : int = value.hasOwnProperty("length") ? value.length : 0;
			return (v>min && v<max);
		}
	}
}
