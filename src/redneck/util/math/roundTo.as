package redneck.util.math{
	/**
	*	
	*	@param	number		Number
	*	@param	digitis		Number
	*	
	*	@return Number
	**/
	public function roundTo(input:Number, digits:Number):Number{
		return Math.round(input*Math.pow(10, digits))/Math.pow(10, digits);
	}
}

