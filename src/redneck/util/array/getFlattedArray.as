/**
 * 
 * @author igor almeida
 * @version 0.1
 * 
 * */
package redneck.util.array 
{
	public function getFlattedArray( arr : Array , recLevel:int = int.MAX_VALUE) : Array
	{
		var result : Array = new Array();
		if (arr.length == 0 || !arr ) {
			return result;
		}
		var max : int = arr.length;
		var count :int = 0
		var value : * ;
		while (count < max)
		{
			value = arr[count];
			if ( arr[ count ] is Array && recLevel > 0)
			{
				result = result.concat( getFlattedArray( value, recLevel-1 ) );
			}
			else
			{
				result.push( value );
			}
			count++;
		}
		return result;
	}
}