package redneck.form.validation.validators {
import redneck.form.validation.AValidator;
	public class IsFalse extends EqualTo
	{
		public function IsFalse(p_index : int = 0){
			super(p_index);
			compareValue = false;
		}
	}
}
