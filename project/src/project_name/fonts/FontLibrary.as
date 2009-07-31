package project_name.fonts {
	import flash.text.Font;
	import flash.text.FontStyle;
	import flash.utils.Dictionary;
	
	/**
	 * ...
	 * @author Henrique Hohmann
	 * 
	 */
	public class FontLibrary {
		
		public static var pack:Dictionary;
		
		/**
		 * Inicializa e registra as fontes. 
		 * @param	p_data
		 */		
		public static function init(p_data:Object = null):Boolean {			
			
			Font.registerFont(lib_MyriadPro);
			Font.registerFont(lib_MyriadProLight);
			Font.registerFont(lib_MyriadProBlack);			
			
			// inicializa dicionário aonde conterá os nomes das fontes
			// fica a critério de cada um o nome
			pack = new Dictionary(true);
			pack["Myriad Pro"] = new lib_MyriadPro().fontName;
			pack["Myriad Pro Black"] = new lib_MyriadProBlack().fontName;
			pack["Myriad Pro Light"] = new lib_MyriadProLight().fontName;			
			
			return true;
		}
		
		/**
		 * Retorna o nome da Font
		 * @param	p_fontName
		 * @return 	retorna o nome da fonte
		 */
		public static function getFontName(p_fontName:String):String {
			if ( pack[p_fontName] != null ) {
				return pack[p_fontName];
			}
			return "_sans";
		}
		
	}
	
}