package saci.locales 
{
	import flash.utils.Dictionary;
	
	/**
	 * ...
	 * @author ...
	 */
	public class Locales
	{
		private static var _instance:Locales;
		private static var _xml:XML;
		private static var _dictionary:Dictionary;
		
		public static function parse(p_xml:XML):void
		{
			_xml = p_xml;
			
			_dictionary = new Dictionary(true);
			
			var list:XMLList = _xml.children();
			var len:int = list.length();
			
			for ( var i:int = 0; i < len; i++ )
			{
				_dictionary[ String(list[i].@name) ] = list[i].@value;
			}
			
		}
		
		static public function get xml():XML 
		{ 
			return _xml; 
		}
		
		static public function set xml(value:XML):void 
		{
			_xml = value;
		}
		
		static public function get dictionary():Dictionary 
		{ 
			return _dictionary; 
		}
		
		static public function set dictionary(value:Dictionary):void 
		{
			_dictionary = value;
		}
		
		static public function getLocale( p_value:String ) : String
		{
			var output:String;
			output = _dictionary[ p_value ];
			if ( output == null ) output = p_value;
			return output;
		}	
		
	}
	
}