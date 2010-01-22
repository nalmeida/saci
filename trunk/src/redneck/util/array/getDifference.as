/**
 *	
 *	@author igor almeida
 *	@version 0.2
 *	
 **/
package redneck.util.array
{
	/**
	 *
	 *	Return the unic elements in arr2
	 * 
	 *	@param arr1	Array
	 *	@param arr2	Array
	 *	@param func	Function function para fazer a comparação entre valores, 
	 *	se null, a conparação será feita com indexOf nativo da Array.
	 *	@return Array
	 * 
	 * */
	public function getDifference( arr1:Array , arr2:Array, func : Function = null) : Array
	{
		var result : Array = new Array();
		if ( arr2.length == 0  ) 
		{
			return arr1
		}
		if ( arr1.length == 0 )
		{
			return result;
		}
		for (var i:String in arr2)
		{
			var pt : * = arr2[i]
			if ( arr1.every( function ( value : *, ...args ) : Boolean {
						return ( func==null ? ( arr1.indexOf( pt ) == -1 ) :  func.apply( null ,[ value , pt] ) )
					})
			) result.push( pt )
		}
		return result
	}
}