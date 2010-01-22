package redneck.util.display {
	import flash.display.*;
	import flash.geom.*;
	public function getBitmap( p_display: DisplayObject, pixelSnapping:String = "auto", smoothing:Boolean = true ) : Bitmap
	{
		if (!p_display)return null;
		var bound : Rectangle = p_display.getBounds( p_display );
		var bmp : Bitmap  = new Bitmap( getBitmapData( p_display ), pixelSnapping, smoothing );
			bmp.x += bound.x;
			bmp.y += bound.y;
		return bmp;
	}
}

