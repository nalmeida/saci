package redneck.form.validation.validators {
import redneck.form.validation.AValidator;
	public class IsTrue extends EqualTo
	{
		public function IsTrue(p_index : int = 0){
			super(p_index);
			compareValue = true;
		}
	}
}
