/**
 * 
 * @author igor
 * @version 0.1
 *	
 */
package redneck.util.array 
{
	/**
	 *
	 *	Insert data in a specific index.
	 *	
	 * 	@param arr	Array
	 *	@param index	int
	 *	@param value	*
	 *	@return Array
	 *	
	 * */
	public function insertAt( arr : Array, index : int, value : * ) : Array
	{
		var result : Array = new Array()
		if ( index >= arr.length )
		{
			result.push( value );
		}
		else
		{
			var tmp : Array = arr.splice( index, arr.length )
			tmp.shift();
			arr.push( value )
			result = arr.concat( tmp );
		}
		return result;
	}
}