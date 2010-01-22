/**
 *	
 *	@author igor almeida
 *	@version 0.1
 */
package redneck.util.array
{
	/**
	 *	
	 *	Verifica se um item esta dentro do array.
	 *	
	 *	@param arr			Array
	 *	@param item			*
	 *	@param compareFunction	Function essa função deve ter uma assinatura que 
	 *	recebe o objeto matriz e o para comparar e ela deve retornar um boolean da comparacao
	 *	@return Boolean
	 *	
	 */
	public function hasItem( arr : Array, item : *, compareFunction : Function = null ) : Boolean
	{
	   if ( arr.length==0 )
	   {
		   return false;
	   }
	   var count : int = arr.length
	   var index : int = -1;
	   while ( count-- )
	   {
			if ( compareFunction == null )
			{
				if ( arr[ count ] === item )
				{
				   return true;
				}
			}
			else if ( compareFunction.apply( null, [ arr[count], item ] ) )
			{
				   return true;
			}
		}
		return false;
	}
}