/**
 * 
 * @author igor almeida
 * @version 0.3
 * 
 * */
package redneck.project.language 
{
	import br.com.stimuli.string.printf;
	
	import flash.events.EventDispatcher;
	import flash.utils.Dictionary;
	import flash.events.Event;
	public class CopyDeck extends EventDispatcher
	{
		private var dictionary : Dictionary;
		private var dictionaryIndex : Array;
		public var stringReplace : Object;
		public var currentLocale: String;
		public var index : int;
		public function CopyDeck() : void
		{
			dictionary = new Dictionary ( true );
			dictionaryIndex = [];
		}
		/**
		 * 
		 * Set the current locale
		 * 
		 * @param	p_locale	String
		 * 
		 * */
		public function setLocale ( p_locale : String ) : void
		{
			if (currentLocale!=p_locale){
				dispatchEvent ( new Event( Event.CHANGE ) );
			}
			currentLocale = p_locale;
		}
		/**
		 * 
		 * register dictionary
		 * 
		 * @param	locale			String	language name
		 * @param	p_dictionary	XML		data provider
		 * @param	p_contains		XML		another locale
		 *	
		 * @return	Boolean	
		 * 
		 * */
		public function addDictionary ( p_locale: String, p_dictionary:XML, p_contains:String=null ) : Boolean
		{
			if( dictionary[ p_locale ] ){
				trace("[CopyDeck] you already have a dictionary registred with locale '"+p_locale+"'.")
				return false;
			}
			dictionary[ p_locale ] = new Copy( p_dictionary, p_contains);
			dictionary[ p_locale ].name = p_locale;
			dictionary[ p_locale ].index = index;
			index++;
			return true;
		}
		/**
		*	
		*	Returns a list with all dictionary locales registered
		*	
		*	@return Array
		*	
		**/
		public function listDictionaries() : Array {
			var result : Array = [];
			var c : Copy;
			for each( c in dictionary ){result.push( c );}
			result = result.sortOn( "index" , Array.NUMERIC );
			result.forEach( function(item:Copy, index:int, array:Array):void{array[index] = item.name;});
			return result;
		}
		/**
		 * 
		 * Get a text from specific copydeck.
		 * If the <code>key</code> doesn't exist. the <code>key</code> will be returned.
		 * 
		 * @param key		String
		 * @param replaceble	Object
		 *	
		 * @return String
		 * 
		 * */
		public function getText ( key:String, p_replaceble : Object = null ) : String
		{
			if ( !dictionary [ currentLocale ] ){
				return "--<invalid_locale>--"+key+"--";
			}

			var str : String = dictionary[ currentLocale ].getText( key ) || "--"+key+"--";
				str = printf( str , p_replaceble || stringReplace );

			return str;
		}
		/**
		*	
		*	@param p_locale	String
		*	@return CopyDeck
		*	
		**/
		public function getDictionary( p_locale:String ):CopyDeck{
			return dictionary[p_locale];
		}
		/**
		*	
		*	Register a new text
		*	
		*	@param p_key		*
		*	@param p_value		*
		*	@param p_override	Boolean
		*	
		*	@return Boolean
		*	
		**/
		public function addText( p_key:*, p_value:*, p_override:Boolean = false ):Boolean{
			if ( !p_key || !p_value ){
				return false;
			}
			if ( !dictionary [ currentLocale ] ){
				return false;
			}
			if ( dictionary [ currentLocale ].hasItem( p_key ) && p_override==false ){
				return false;
			}
			dictionary [ currentLocale ].addText( p_key, p_value );
			return true
		}
	}
}
import redneck.project.language.*;
import flash.xml.*;
import redneck.project.log.*
import redneck.events.*;
internal class Copy extends Object
{
	public var contains : String;
	public var xml : XML;
	public var index : int;
	public var name : String;
	private var content : Object
	public function Copy( p_xml:XML, p_contains:String=null )
	{
		super();
		xml = p_xml;
		contains = p_contains;
		content = {};
		var n : *;
		for each( n in xml.item ){
			if ( n && n.@name ){
				if (content[ n.@name.toString() ]){
					log("duplicated name: '"+n.@name+"'.", LogEvent.ERROR);
				}
				else{
					content[ n.@name.toString() ] = n.toString();
				}
			}else{
				log("skipped content! attribute 'name' missing.", LogEvent.ERROR);
			}
		}
	}
	/**
	*	
	*	Returns the current text for <code>p_key</code>
	*	
	*	@param	p_key
	*	
	*	@return	String
	*	
	**/
	public function getText( p_key:String ):String{
		var result : String;
		if (p_key){
			result = content[ p_key ] || null;
			if (result==null && ( contains!=null && contains.length>0) ){
				result = language( contains ).getText( p_key );
			}
		}
		return result;
	}
	/**
	*	
	*	Returns if has a copy registered with <code>p_key</code>;
	*	 
	*	@param p_key	String
	*	
	*	@return Boolean
	*	
	**/
	public function hasItem(p_key:String):Boolean{
		return content.hasOwnProperty( p_key );
	}
	/**
	*	
	*	Add a new text
	*	
	*	@param	p_key
	*	@param	p_value
	*	
	*	@return Boolean
	*	
	**/
	public function addText(p_key:*, p_value:*):Boolean{
		if ( !p_key || !p_value ){
			return false;
		}
		content[ p_key ] = p_value;
		return true;
	}
	/**
	*	
	*	Just to help debugging 
	*	
	*	@return String
	*	
	**/
	public function toString():String{
		return "[Copy] name:"+name+" index:"+index;
	}
}