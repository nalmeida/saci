/**
 * 
 *	@author igor
 *	@version 0.1
 *	
 */
package redneck.util.array 
{
	/**
	 * 
	 *	Faz uma copia do array
	 *	
	 *	@param arr Array
	 * 	@param recLevel int	recursive level
	 *	@return Array
	 * 
	 * */
	public function cloneArray( arr : Array, recLevel : int = int.MAX_VALUE)  : Array
	{
		var result: Array = new Array()
		if ( recLevel < 0 ) {
			return result;
		}
		result = arr.map(  function( value: * , ...args ) : *
		{
			return value is Array ? cloneArray( value, recLevel-1 ) : value;
		} ) 
		return result;
	}
}