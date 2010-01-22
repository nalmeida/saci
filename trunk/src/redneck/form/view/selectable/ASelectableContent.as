package redneck.form.view.selectable
{
	import redneck.form.view.FieldContentBridge;
	public class ASelectableContent extends FieldContentBridge
	{
		public function ASelectableContent()
		{
			super();
			display = new ASelectableItem();
			addChild(display);
		}

		public override function get value():*
		{
			return display.selected;
		}

		public override function set value(value:*):void
		{
			display.selected = value;
		}
	}
}

