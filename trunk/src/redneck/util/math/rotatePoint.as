package redneck.util.math
{
	/**
	*	
	*	@param value	Point
	*	@param angle	Number
	*	
	*	@return Point
	*
	*	
	**/
	import flash.geom.*;
	public function rotatePoint(value:Point,angle:Number):Point{
		var radius:Number = Math.sqrt(Math.pow(value.x, 2)+Math.pow(value.y, 2));
		var angle:Number = Math.atan2(value.y, value.x)+angle;
		return new Point(radius*Math.cos(angle), radius*Math.sin(angle));
	}
}

