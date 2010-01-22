/**
 *
 * Retorna um array de com todos os "parents" de um DisplayObject
 *  
 * @author igor almeida
 * @since 06.01.2009
 * @version 0.0.1
 * 
 * */
package redneck.util.display
{
	import flash.display.DisplayObject;
	public function viewDisplayDNA( who : DisplayObject, recLevel : int = int.MAX_VALUE ) : Array
	{
		var result : Array = new Array ();
		do{
			result.push( who );
			if ( who == who.root ){
				recLevel = 0;
			}else{
				recLevel--;
			}
			who = who.parent;
		}while( recLevel>0 );
		return result.reverse();
	}
}