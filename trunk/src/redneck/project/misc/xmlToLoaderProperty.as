package redneck.project.misc
{
	import br.com.stimuli.loading.BulkLoader;
	import br.com.stimuli.string.printf;

	import flash.net.URLRequestHeader;

	import redneck.util.isStandAlone;
	import redneck.util.valueFromXML;
	
	/**
	 * 
	 *	Cria um object no modelo permitido pela <code>BulkLoader.add</code>
	 *	para carregar todas as dependencias.
	 * 
	 *	@param name String
	 *	@return Object
	 * 
	 **/
	public function xmlToLoaderProperty( xmlNode : XML )  : Object
	{
		var obj:Object = {};
		var node : XML = xmlNode;
		var p : String;
		var value : *;
		
		obj.path = valueFromXML(node, "url");

		for (var prop:String in BulkLoader.GENERAL_AVAILABLE_PROPS )
		{
			value = valueFromXML(node, BulkLoader.GENERAL_AVAILABLE_PROPS[ prop ] )
			if ( value )
			{
				p  = BulkLoader.GENERAL_AVAILABLE_PROPS[ prop ].toString();
				obj [ BulkLoader.GENERAL_AVAILABLE_PROPS[ prop ] ] = forceType( p, value );
			}
			value = null;
		}
		if ( node.hasOwnProperty( "headers" ) )
		{
			var headers : Array =  new Array();
			var headerName : String
			var headerValue : String
			var header : URLRequestHeader
			for each (var headerNode:XML in node.headers.children() )
			{
				headerName = String( headerNode.name( ) );
				headerValue = String( headerNode[0] ) ;
				header = new URLRequestHeader( headerName, headerValue ) ;
				headers.push(header);
			}
			obj [ BulkLoader.HEADERS ] = headers;
		}
		if ( valueFromXML(node,BulkLoader.PAUSED_AT_START) )
		{
			obj [ BulkLoader.PAUSED_AT_START ] = forceType( BulkLoader.PAUSED_AT_START, valueFromXML(node,BulkLoader.PAUSED_AT_START) );
		}
		if ( valueFromXML(node,BulkLoader.CAN_BEGIN_PLAYING ) )
		{
			obj [ BulkLoader.CAN_BEGIN_PLAYING ] = forceType( BulkLoader.CAN_BEGIN_PLAYING, valueFromXML(node,BulkLoader.CAN_BEGIN_PLAYING) );
		}
		if ( valueFromXML(node, BulkLoader.CHECK_POLICY_FILE ) )
		{
			obj [ BulkLoader.CHECK_POLICY_FILE ] = forceType( BulkLoader.CHECK_POLICY_FILE , valueFromXML(node, BulkLoader.CHECK_POLICY_FILE ) );
		}
		if ( valueFromXML(node,BulkLoader.CONTEXT) && valueFromXML(node,BulkLoader.CONTEXT) == "true" )
		{
			obj[ BulkLoader.CONTEXT ] = true;
		} 
		if ( valueFromXML(node, BulkLoader.PREVENT_CACHING) ){
			obj[ BulkLoader.PREVENT_CACHING ] = !isStandAlone();	
		}
		return obj;
	}
}
import br.com.stimuli.loading.BulkLoader;
/**
 * 
 * Forca a tipagem de uma variavel baseada nos tipos já
 * existentes da bulkloader.
 * 
 * @param	prop	String	property to find	
 * @param	value	*		data to be forced
 * @return *
 * 
 * */
internal const INT_TYPES : Array = new Array(BulkLoader.MAX_TRIES, BulkLoader.PRIORITY);
internal const NUMBER_TYPES : Array = new Array( BulkLoader.WEIGHT );
internal const BOOLEAN_TYPES : Array = new Array(BulkLoader.PREVENT_CACHING, BulkLoader.PAUSED_AT_START, BulkLoader.CHECK_POLICY_FILE, BulkLoader.CONTEXT, BulkLoader.CAN_BEGIN_PLAYING);
internal function forceType(prop:String, value:* ) : *
{
	if ( INT_TYPES.indexOf( prop ) > -1 )
	{
		value = int( value );
	}
	else if ( NUMBER_TYPES.indexOf( prop ) > -1 )
	{
		value = Number( String( value ) );
	}
	else if ( BOOLEAN_TYPES.indexOf( prop ) > -1 )
	{
		value = Boolean( String( value ) );
	}
	else
	{
		value  = String( value )
	}
	return value;
}