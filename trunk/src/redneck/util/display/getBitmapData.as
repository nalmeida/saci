package redneck.util.display {
	import flash.display.*
	import flash.geom.*;
	public function getBitmapData( display: DisplayObject, transparent:Boolean = true, color:int = BitmapDataChannel.ALPHA) : BitmapData
	{
		if (!display)return null;

		var bounds:Rectangle = display.getBounds( display );

		var mt : Matrix = new Matrix;
			mt.tx = -bounds.x;
			mt.ty = -bounds.y;

		var b : BitmapData = new BitmapData( bounds.width,bounds.height, transparent, color );
			b.draw( display, mt )

		return b;
	}
}