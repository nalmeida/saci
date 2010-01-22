package redneck.display.shapes {
	/**
	* stores the command the draw the poly
	**/
	import flash.geom.*;
	internal class Command
	{
		public var type : String;
		public var x:Number;
		public var y:Number;
		public var point : Point;
		public function Command(p_type:String,p_x:Number,p_y:Number):void{
			type = p_type;
			x = p_x;
			y = p_y;
			point = new Point(x,y);
		}
		public function clone():Command{
			return new Command(this.type,this.x,this.y);
		}
	}
}

