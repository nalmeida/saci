package redneck.form.view.textinput {
	import flash.text.*;
	import redneck.form.view.*;
	public class AInputContent extends FieldContentBridge {
		public function AInputContent()
		{
			super();
			display = new TextField();
			addChild(display);
		}
		/**
		*	
		*	Returns the TextField content
		*	
		*	@return *
		*	
		**/
		public override function get value():*{
			return (display.text.length==0) ? null : display.text;
		}
		/**
		*	
		*	Injects a initial content on this TextField
		*	
		*	@param value	*
		*	
		**/
		public override function set value(value:*):void
		{
			display.text = value;
		}
	}
}

