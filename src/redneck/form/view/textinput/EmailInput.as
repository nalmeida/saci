package redneck.form.view.textinput {
	import flash.text.*;
	import redneck.form.view.*;
	public class EmailInput extends TextInput{
		/**
		* Default string text input.
		* 
		* @param	p_label
		* @param	p_initialText
		* @param	p_index
		* 
		**/
		public function EmailInput( p_label:String="", p_initialText:String="", p_index:int=0 ):void{
			super(p_label,p_initialText,p_index);
			fieldValue.display.restrict = "0-9a-z.@\\-\\";
		}
	}
}

