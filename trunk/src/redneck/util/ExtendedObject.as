package redneck.util
{
	import flash.utils.Proxy;
	import flash.utils.flash_proxy;
	import redneck.core.IDisposable;
	import flash.utils.Dictionary;
	import br.com.stimuli.string.printf;

	public dynamic class ExtendedObject extends Proxy implements IDisposable
	{
		protected var object : Dictionary;
		public var preventOverriding : Boolean = false;

		public function ExtendedObject()
		{
			super();
			object = new Dictionary( true );
		}
		/**
		*	
		*	adds a new property at override
		*	
		*	@param name		String	property name
		*	@param value	*
		*	
		**/
		override flash_proxy function setProperty(name:*, value:*):void{
			if (preventOverriding && object.hasOwnProperty( name ) ){
				trace("ExtendedObject::setProperty() this object has a property '"+name+"' already. If you want to replace it mark <code>preventOverriding</code> as <code>false</code>.");
				return;
			}
			object[name] = value;
			object.setPropertyIsEnumerable( name, true );
		}
		/**
		*	returns the desired property
		*	
		*	@return *
		*/
		override flash_proxy function getProperty(name:*):* {
			return object[ name ] is String ? printf( object[ name ], this ) : object[ name ];
		}
		/**
		*	call a especific property at object;
		*	
		*	@return *
		*/
		override flash_proxy function callProperty( methodName:*, ... args ):* {
			return object[methodName].apply(null,args);
		}
		/**
		*	inspired on Gabriel Laet's Parameters
		*	
		*	@param	p_index
		*	
		*	@return	int
		**/
		override flash_proxy function nextNameIndex( index:int ):int
		{
			return ( index < list.length ) ? index + 1 : 0;
		}
		/**
		*	inspired on Gabriel Laet's Parameters
		*	
		*	@param p_index
		* 	
		*	@return String
		**/
		override flash_proxy function nextName(index:int):String
		{
			return list[index-1];
		}
		/**
		*	@return Boolean
		**/
		public function hasOwnProperty( name:String ):Boolean{
			return object.hasOwnProperty( name );
		}
		/**
		 * 
		 * get all props names
		 * 
		 * @return Array
		 * 
		 * */	
		public function get list( ) : Array
		{
			var arr: Array = new Array();
			var prop:String;
			for ( prop in object ) {
				arr.push( prop );
			}
			return arr;
		}
		/**
		 * 
		 * just traces all props
		 * 
		 * */
		public function report() : String
		{
			var str : String = "[ExtendedObject:]";
			list.forEach( function (propName : String, ...rest):void{
				str += "\n" + propName + ":" + object[propName];
			} );
			return str;
		}
		/**
		* 	Injects a bunch o properties from a XMLList
		*	
		*	@param p_xml : XML
		*	
		*	@return ExtendedObject
		*	
		*/
		public function injectXML( p_xml : XMLList ):ExtendedObject{
			if (p_xml && p_xml.children()){
				for each(var item : XML in p_xml.children()){
					object[item.localName()] = resolveType(item.toString());
				}
			}
			return this;
		}
		/*returns a value forcing the data type*/
		private function resolveType( value:* ):*{
			if (value == "true" || value=="false"){
				return value == "true";
			}
			else if ( !isNaN(value) ){
				return Number(value);
			}
			return value
		}
		/**
		*	disposes this instance
		**/
		public function dispose( ...rest ):void{
			object = null;
		}
	}
}