/**
*
* This class was wrote to help managing styles in your project.
* Currently it just work with TextFormat (not StyleSheet).
* 
* @author igor almeida
* @version 1.0
*
**/
package redneck.textfield
{
	import flash.utils.*;
	import flash.text.*;
	public class Style extends Object
	{
		private var _fontList : Dictionary;
		private var _styleList : Dictionary
		private var _name : String;
		private static var _styleInstances : Dictionary = new Dictionary(true)
		private static var _counter : int;
		public function Style(p_name:String)
		{
			super();
			_name = p_name;
			_fontList = new Dictionary(true)
			_styleList = new Dictionary(true);
			_styleInstances[_name] = this;
			_counter++;
		}
		public function get name():String
		{
			return _name;
		}
		/**
		* 
		* every Style is registred on a static instace and can be used from any different scope.
		* 
		* @return Style
		* 
		**/
		public static function getStyleInstance(p_name:String):Style{
			return _styleInstances[p_name];
		}
		/**
		* 
		* This method register a new font on flash.
		* 
		* @param p_font		*	Class instance (Font intanciated on na lybrary or swc) or String with the class name or system font;
		* @param p_alias	*	alias to register this font
		* 
		* @see flash.utils.Font;
		* @return Style;
		* 
		* @usage
		*	
		*	[Embed(source="DINENGSC.TTF", fontName="DINEngschrift")]
		*	private var dine:Class;
		*	
		*	var st : Style = new Style("redneck");
		*		st.addFont("Verdana", "verdana");
		* 		st.addFont("Cooper Std", "copper");
		*		st.addFont(dine, "redneck");
		* 
		**/
		public function addFont(p_font:*, p_alias:String):Style{
			if (p_alias!=null){
				if(_fontList[p_alias]){
					return null;
				}	
			}
			var theClass: Class;
			if (p_font is String){
				try{
					theClass = getDefinitionByName( p_font ) as Class;
				}catch(err:Error){
					trace("[redneck.textfield.Style: there is no class with name '"+p_font+"'! Probably this is a system font.]");
					_fontList[ p_alias ] = p_font;
					return this;
				}
			}else if ( p_font is Class ){
				theClass = p_font;
			}
			if (theClass!=null){
				try{
					Font.registerFont( theClass );
					_fontList[ p_alias ] = new theClass();
				}
				catch(err:Error){
					return this;
				}
			}
			return this;
		}
		/**
		* 
		* Return a list with all font names
		* 
		* @return Array
		* 
		**/
		public function listFontNames():Array{
			var result :Array = new Array();
			for each( var n : * in _fontList ){
				result.push( getFontName( n ) );
			}
			return result;
		}
		/**
		*
		* Return a list with all registred fonts.
		* 
		* @return Array
		* 
		**/
		public function listFonts():Array{
			var result :Array = new Array();
			for each( var n : * in _fontList ){
				result.push( n );
			}
			return result;
		}
		/**
		* 
		* return a list with all font alias
		* 
		* @return Array
		* 
		**/
		public function listFontAlias():Array{
			var result:Array = new Array();
			for (var n :String in _fontList){
				result.push( n );
			}
			return result;
		}
		/**
		* 
		* Return the registred font with a scpecific alias.
		* 
		* @param p_alias	String
		* 
		* @return *	Font or String (if is a system font);
		* 
		**/
		public function getFont(p_alias:String):*{
			return _fontList[p_alias]
		}
		/**
		* Return the real font name by alias.
		* 
		* @return String;
		* 
		* @usage
		* st = new Style("redneck");
		* st.addFont("Verdana", "alias").addStyle("header", {color:0xff0000, size:25, font:alias });
		* 
		**/
		public function getFontName(p_alias:String):String{
			var f : * = getFont(p_alias);
			return f ? f.hasOwnProperty( "fontName" ) ? f.fontName : f : p_alias;
		}
		/**
		* 
		* Register a new style
		* 
		* A tip to define your "font" is: you don't need necessarily 
		* to "pre-register" (@see addFont) if you are using default system fonts;
		* 
		* @param p_name		String
		* @param p_format	TextFormat or Object or StyleProperties
		* 
		* @see StyleProperties
		* @see StyleProperties.allowedProps
		* 
		* @usage
		* st = new Style("redneck");
		* st.addFont("Cooper Std", "cooper").addStyle("header", {color:0xff0000, size:25, font:"cooper" });
		* 
		* // you dont need to register default system fonts
		* st.addStyle("content", {color:0, size:20, font:"Arial" });
		* 
		**/
		public function addStyle(p_name:String, p_format:*):Style{
			if (p_format==null || p_name==null){
				return null;
			}
			if (p_format is TextFormat){
				_styleList[p_name] = p_format;
			}
			else if ( p_format is StyleProperties ){
				_styleList[p_name] = p_format.textFormat;
			}
			else if ( p_format is Object ){
				_styleList[p_name] = StyleProperties.fromObject(p_format).textFormat;
			}
			if (_styleList[p_name].font  && getFontName(_styleList[p_name].font)){
				_styleList[p_name].font = getFontName(_styleList[p_name].font);
			}
			return this;
		}
		/**
		* 
		* Return a list with all styles
		* 
		* @return Array
		* 
		**/
		public function listStyles():Array
		{
			var result : Array = []
			for each( var s : TextFormat in _styleList ){
				result.push(s)
			}
			return result;
		}
		/**
		* 
		* Return a specific style
		* 
		* @param p_nane	String	
		* 
		* @return TextFormat
		* 
		**/
		public function getStyle(p_nane:String):TextFormat{
			return _styleList[p_nane];
		}
		/**
		* 
		* Remove style;
		* 
		* @return Boolean;
		* 
		**/
		public function removeStyle(p_name:String):Boolean{
			if (_styleList[p_name]){
				_styleList[p_name] = null
				delete _styleList[p_name];
				return true
			}
			return false
		}
		/**
		* 
		* Return a TextField with a TextFormat applied
		* 
		* @param p_alias	String	style alias
		* 
		* @return TextField
		* 
		* @usage
		* st = new Style("redneck");
		* st.addFont("Verdana", "verdana").addStyle("header", {color:0xff0000, size:25, font:st.getFontName("verdana") });
		* var txt : TextField = addChild( st.getStyledField( "header" ) ) as TextField;
		* txt.text =  "igor";
		* 
		**/
		public function getStyledField(p_name:String, p_embed : Boolean = false, p_autoSize:String = "left" ):TextField{
			if (p_name ==null) {
				return null
			}
			var result : TextField = new TextField();
			var format : TextFormat = getStyle(p_name);
			if (format==null){
				trace("[com.redneck.textfield.Style: a new TextFormat will be create to avoid errors, but the '"+p_name+"' doesn't exist.]")
			}
			result.defaultTextFormat =  format || new TextFormat();
			if (p_embed){
				result.embedFonts = true;
			}
			if ( p_autoSize ){
				result.autoSize = p_autoSize;
			}
			return result;
		}
		/**
		* @private parse nome
		**/
		private static function valueFromXML( p_node: * , p_prop: String ) : * {
			return p_node.hasOwnProperty(p_prop) ? p_node[ p_prop ] : p_node.attribute( p_prop ).toString();
		}
		/**
		*
		* This is just a shortcut to create an Style based on XML model;
		* 
		* @see styles_xml_schema.txt
		* @see addFont
		* @see addStyle
		* 
		* @return Style
		* 
		**/
		public static function fromXML(p_xml:XML):Style{
			if (p_xml == null){
				return null
			}
			var result : Style = new Style( valueFromXML(p_xml, "name") || "redneck_"+_counter );
			var index:*
			var n : *
			if (p_xml.fonts && p_xml.fonts.font){
				var a : String
				var f : String;
				for (index in p_xml.fonts.font){
					n = p_xml.fonts.font[index];
					a = valueFromXML(n , "alias") || valueFromXML(n , "id") || valueFromXML(n , "name");
					f = n.toString();
					result.addFont( f, a );
				}
			}
			if (p_xml.styles && p_xml.styles.style){
				var sName : String;
				for( index in p_xml.styles.style ){
					n = p_xml.styles.style[index];
					sName = valueFromXML( n,  "name" ) || valueFromXML( n,  "id" ) || valueFromXML( n,  "alias" );
					if (sName.length<1){
						trace("[com.textfield.Style : skiping style, 'alias' attribute/node is obligatory]" , n);
						continue;
					}
					var sProp : StyleProperties = new StyleProperties();
					var prop : String;
					var v : *;
					for each( prop in StyleProperties.allowedProps){
						v = valueFromXML( n, prop );
						if (v){
							v = v.toString();
						}
						if ( v > 0 || v.length>0){
							if ( prop == "font" ){
								v = result.getFontName( v ) || v ;
							}
							sProp[prop] = v;
						}
					}
					result.addStyle( sName, sProp );
				}
			}
			return result;
		}
	}
}