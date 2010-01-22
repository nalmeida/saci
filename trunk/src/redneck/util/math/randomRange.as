package redneck.util.math {
	function randomRange(min:Number, max:Number):Number{
		var result : Number;
		result = Math.random()*max;
		result = Math.max(min,result);
		return result;
	}
}

