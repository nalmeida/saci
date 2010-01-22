/**
 *	
 *	@author igor almeida
 *	@version 0.1
 */
package redneck.util.array
{
	/**
	 *	
	 *	Remove um item especifico do array e retorn um novo Array sem <code>item</code>
	 *	
	 *	@param arr			Array
	 *	@param item			*
	 *	@param compareFunction	Function essa função deve ter uma assinatura que 
	 *	recebe o objeto matriz e o para comparar e ela deve retornar um boolean da comparacao
	 *	@return Array
	 *	
	 */
	public function removeItem( arr : Array, item : *, compareFunction : Function = null ) : Array
	{
		if ( arr.length==0 )
		{
			   return [ ]
		}
		var count : int = arr.length
		var index : int = -1;
		while ( count-- )
		{
			   if ( compareFunction == null )
			   {
					   if ( arr[ count ] === item )
					   {
							   index = count;
							   break;
					   }
			   }
			   else if ( compareFunction.apply( null, [ arr[count], item ] ) )
			   {
					   index = count;
					   break;
			   }
		}
		if (index >-1)
		{
			   if ( index == 0 )
			   {
				   arr.shift();
			   }
			   else if (index == arr.length - 1) {
				   arr.pop();
			   } else  {
				   arr.splice( index,1 );
			   }
		}
		return arr;
   }
}