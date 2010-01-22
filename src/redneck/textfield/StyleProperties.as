package redneck.textfield
{
	import flash.text.TextFormat;
	public class StyleProperties
	{
		public var _align : String = "left"
		public var _bold : * = false
		public var _color : * = 0
		public var _font : * = ""
		public var _italic : * = false
		public var _kerning : * = false
		public var _underline : * = false
		public var _leading : * = 0
		public var _size : * = 12
		private var _format : TextFormat
		public static const allowedProps : Array = ["align","bold","underline","color","font","italic","kerning","leading","size"];
		public function StyleProperties()
		{
			super();
			_format = new TextFormat();
		}
		
		public function set size(value:*):void
		{
			_size = Number(value);
		}
		public function get size():*
		{
			return Number(_size);
		}
		
		public function set leading(value:*):void
		{
			_leading = Number(value);
		}
		public function get leading():*
		{
			return Number(_leading);
		}
		
		public function set kerning(value:*):void
		{
			_kerning = Boolean(value);
		}
		public function get kerning():*
		{
			return Boolean(_kerning);
		}
		
		public function set italic(value:*):void
		{
			_italic = Boolean(value);
		}
		public function get italic():*
		{
			return Boolean(_italic);
		}
		
		public function set font(value:*):void
		{
			_font = String(value);
		}
		public function get font():*
		{
			return String(_font);
		}

		public function set color(value:*):void
		{
			_color = int(value);
		}
		public function get color():*
		{
			return int(_color);
		}
		
		public function set align(value:*):void
		{
			_align = String(value);
		}
		public function get align():*
		{
			return String(_align);
		}
		
		public function set bold(value:*):void
		{
			_bold = Boolean(value);
		}
		public function get bold():*
		{
			return Boolean(_bold);
		}
		
		public function set underline(value:*):void
		{
			_underline = Boolean(value);
		}
		public function get underline():*
		{
			return Boolean(_underline);
		}
		
		public static function fromObject(p_object:Object):StyleProperties{
			var result : StyleProperties = new StyleProperties();
			for (var prop :String in p_object){
				if (result.hasOwnProperty(prop)){
					result[prop] = p_object[prop];
				}
			}
			return result;
		}
		public function toString():String{
			var result : String = "StyleProperties:";
			for each(var prop : String in allowedProps){
				result += "\n" + prop + ": " + this[prop];
			}
			return result;
		}
		public function get textFormat():TextFormat{
			_format.align = align;
			_format.color = color;
			_format.font = font;
			_format.bold = bold;
			_format.italic = italic;
			_format.kerning = kerning;
			_format.leading = leading;
			_format.underline = underline;
			_format.size = size;
			return _format;
		}
	}
}