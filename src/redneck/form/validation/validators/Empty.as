package redneck.form.validation.validators {
import redneck.form.validation.AValidator;
	public class Empty extends AValidator
	{
		public var compareValue : Array = ["",null,NaN];
		public function Empty(p_index : int = 0){
			super(p_index);
		}
		public override function validate( value:* ):Boolean{
			super.error.value = value;
			return value==null ? false : (compareValue.indexOf(value)==-1);
		}
	}
}
