package project_name.data {
	
	/**
	 * Parser de shortcuts
     * @author Marcelo Miranda Carneiro
	 * @version 0.1
	 * @since 17/2/2009 14:59
     * @see project_name.data.ServerData#parseString
	 */

	 import saci.util.Logger;
	
	public class ShortcutParser {
		
		static private var _serverData:ServerData = ServerData.getInstance();
		
		/**
		 * Gera os "shortcuts"
		 * @param	$xml
		 * @return
		 */
		static public function parseXML($xml:XML):Object {
			if ($xml == null) return { };
			var i:int;
			var shortcutObject:Object = {};
			for (i = 0; i < $xml.children().length(); i++) {
				shortcutObject[$xml.children()[i].name()] = _serverData.parseString($xml.children()[i].@value);
				if (_serverData.get($xml.children()[i].name()) != null) {
					Logger.logWarning("[ShortcutParser.parseXML] O xml contém o atributo global \"" + $xml.children()[i].name() + "\" que irá sobrepor o existente na ServerData.");
				}
			}
			return shortcutObject;
		}
		
	}
	
}
