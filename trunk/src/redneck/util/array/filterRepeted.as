/**
 *	
 *	@author igor almeida
 *	@version 0.1
 *	
 **/
package redneck.util.array
{
	/**
	 *
	 *	Retorna um array com valores unicos no array
	 * 
	 *	@param arr	Array
	 *	@param func	Function function para fazer a comparação entre valores, 
	 *	se null, a conparação será feita com indexOf nativo da Array.
	 *	@return Array
	 * 
	 * */
	public function filterRepeted( arr:Array, func:Function = null ) : Array
	{
		var result : Array = new Array( );
		result.push( arr.shift( ) );
		for (var count :int = 0 ; count<arr.length; count++ )
		{
			var max : int = result.length
			var index : int = 0;
			while ( index<max )
			{
				var diff : Array = getDifference( result, arr , func );
				if (diff.length>0)
				{
					result.push( diff.shift() );
				}
				index++	;
			}
		}
		return result
	}
}