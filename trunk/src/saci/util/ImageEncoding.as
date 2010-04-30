package saci.util
{
	import flash.display.BitmapData;
	import com.adobe.images.JPGEncoder;
	import flash.utils.ByteArray;
	import mx.utils.Base64Encoder;
	
	public class ImageEncoding extends Object
	{
	
		public function ImageEncoding()
		{
			super();
		}
		
		public static function bitmapToBase64(bmp:BitmapData, quality:uint = 100):String
		{
			var encodedImage:JPGEncoder = new JPGEncoder(quality);
			var byteImage:ByteArray = encodedImage.encode(bmp);
			var b64e:Base64Encoder = new Base64Encoder();
			b64e.encodeBytes(byteImage);
			return b64e.flush();
		}
		
	}

}