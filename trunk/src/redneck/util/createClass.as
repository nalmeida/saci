package redneck.util
{
	import flash.utils.getDefinitionByName;
	
	/**
	 * 
	 * Create the refeered class;
	 * 
	 * @return Class
	 * 
	 * */
	public function createClass( name:String ) : *
	{
		var theClass: Class = getDefinitionByName( name ) as Class;
        return new theClass( );
	}
}