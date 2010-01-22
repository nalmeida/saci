package redneck.form.validation.validators {
import redneck.form.validation.AValidator;
	public class MultipleEmails extends AValidator
	{
		public var compareValue : RegExp = /([\w-\.]+)@((?:[\w]+\.)+)([a-zA-Z]{2,4})/;
		public function MultipleEmails(p_index : int = 0){
			super(p_index);
		}
		public override function validate( value:* ):Boolean{
			super.error.value = value;
			if (value){
				var fields:Array = value.replace(";",",").split(",");
				var flag : Boolean = true
					flag =  fields.every( function ( item : String, ...rest ):Boolean{
					return compareValue.test( item );
				},null);
				return flag;
			}
			return false;
		}
	}
}