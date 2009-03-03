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
		public static function randomize(array:Array = null):Array {
			
			var tempArray:Array = [];
			tempArray = array.slice();
			
			var resultArray:Array = new Array();
			while (tempArray.length > 0 && array.length > resultArray.length){
				var n:int = Math.floor(Math.random() * tempArray.length);
				resultArray.push(tempArray[n]);
				tempArray.splice(n,1);
			}
			//trace(”returning generated array: “+resultArray);
			return resultArray;
		} 
	}
	
}