package saci.fonts {
	import flash.text.Font;
	import flash.text.FontStyle;
	import flash.utils.Dictionary;
	
	/**
	 * ...
	 * @author Henrique Hohmann
	 * 
	 */
	public class FontLibrary {
		
		private static var _pack:Dictionary;
		
		/*
		FontLibrary.parseJSON([{
			"name": "Myriad",
			"types": {
				"regular": lib_MyriadPro,
				"bold": lib_MyriadProBlack,
				"light": lib_MyriadProLight
			}
		}]);
		*/
		public static function parseJSON(rawData:Array):Boolean {
			var rawDataLength:int = rawData.length;
			for (var i:int = 0; i < rawDataLength; i++) {
				for (var name:String in rawData[i].types) {
					addFont(rawData[i].name, name, rawData[i].types[name]);
				}
			}
			return true;
		}
		
		
		/**
		 * Registers the font and records font data to later use.
		 * @param	id Name of the font (later use)
		 * @param	type Type of the font (regular, italic, condensed bold, etc.)
		 * @param	font Class of the font
		 */
		public static function addFont(id:String, type:String, font:Class):void {
			if (pack == null) {
				_pack = new Dictionary(true);
			}
			if (_pack[id] == null) {
				_pack[id] = [];
			}
			
			Font.registerFont(font);
			
			_pack[id].push({
				fullName: new (font as Class)().fontName,
				type: type
			});
		}
		
		/**
		 * Get the original font name
		 * @param	id
		 * @return 	returns font name
		 */
		public static function getFontName(id:String, type:String):String {
			if ( _pack[id] != null) {
				var fontLength:int = _pack[id].length;
				for (var i:int = 0; i < fontLength; i++) {
					if (_pack[id][i] != null && _pack[id][i].type === type) {
						return _pack[id][i].fullName;
					}
				}
			}
			return "_sans";
		}
		
		static public function get pack():Dictionary { return _pack; }
		
	}
	
}