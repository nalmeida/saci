package saci.util {
	
	/**
	 * Utilidades para Array
	 * @author Nicholas Almeida
	 * @since 3/3/2009 11:59
	 */
	public class ArrayUtil {
		
		
		/**
		 * Randomiza os elementos de um array
		 * @param	array
		 * @return
		 * @see http://interactivesection.wordpress.com/2008/01/16/random-array-generator-class-as3/
		 * @example
		 * <pre>
		 * 		var arr:Array = [1,2,3,4,5]
		 * 		var arrRnd:Array = ArrayUtil.randomize(arr);
		 *  	trace(arrRnd); // resultado possível:  5,3,4,2,1
		 * </pre>
		 */
		public static function randomize(array:Array):Array {
			return array.sort(function(...args):Number { return Math.round(Math.random() * 2) - 1; });
		} 
		
		/**
		 * Distribui os itens do array original em um novo array
		 * @example
		 * <pre>
		 * 		var distributed:Array = ArrayUtil.distribute([0,1,2], 7); 
		 * 		trace(distributed); // [0, null, null, 1, null, null, 2]
		 * </pre>
		 */
		public static function distribute(p_array:Array, p_length:uint = 5):Array{
			if(p_array && p_array.length > p_length){
				return p_array;
			}
			var array:Array = new Array(p_length),
				coef:Number = (array.length-p_array.length) / (p_array.length-1),
				index:Number = 0;
			for (var i:uint = 0, len:uint = p_array.length; i < len; i++){
				array[Math.round(i ? (index = index + 1 + coef) : 0)] = p_array[i];
			}
			return array;
		}
		
	}
	
}