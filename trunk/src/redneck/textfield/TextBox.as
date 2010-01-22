/**
 * @see TextBreaker
 *
 * @author igor almeida
 * @version 1.2
 *
 */
package redneck.textfield {
	
	import flash.display.*;
	import flash.text.*;
	import flash.geom.*;
	import flash.display.*;

	public class TextBox extends Sprite {
		public var finalX:Number = 0;
		public var finalY:Number = 0;
		public var id : int;
		public var text : String
		public var next : TextBox;
		public var prev : TextBox;
		public var field : TextField;
		public var fmt : TextFormat;
		private var bounds : Rectangle;
		private var bmp : Bitmap;
		private var bmpdata : BitmapData;
		/**
		*	
		*	TextBox
		*	@see TextBreaker
		*	
		*	@param	p_text		String
		*	@param	p_bounds	Rectangle
		*	
		**/
		public function TextBox( p_text: String, p_bounds:Rectangle ):void
		{
			super();
			text = p_text;
			bounds = p_bounds;
			finalY = bounds.y;
			finalX = bounds.x;
		}
		/**
		*
		*	@see TextBreaker.TEXTFIELD
		*	@see TextBreaker.BITMAP
		*	
		*	@param	p_format			TextFormat
		*	@param	p_type				String
		*	@param	p_adjustPosition	Boolean If false use the finalX and finalY to apply this item in the equivalent position
		*	
		**/
		public function render ( p_format : TextFormat, p_type : String, p_adjustPosition:Boolean = true ):void{

			field = new TextField();
			field.autoSize = TextFieldAutoSize.LEFT;
			field.defaultTextFormat = p_format;
			field.text = text || "";
			addChild(field);

			if ( p_type != TextBreaker.TEXTFIELD ){

				bmpdata = new BitmapData( bounds.width+2, bounds.height+2, true, BitmapDataChannel.ALPHA )
				bmpdata.draw(field, null, null, null, null, true);
				bmp = new Bitmap( bmpdata, "auto", true );
				bmp.smoothing = true;
				addChild(bmp);
				
				if(field!=null && contains(field)){
					removeChild(field);
				}
			}
			if(p_adjustPosition){
				this.x = finalX;
				this.y = finalY;
			}
		}
		/**
		*	destroy
		**/
		public function dispose():void{
			if(field!=null && contains(field)){
				removeChild(field);
			}
			if (bmp!=null && contains(bmp)){
				removeChild(bmp);
			}
			if (bmpdata){
				bmpdata.dispose();
				bmpdata = null;
			}
			bounds = null;
		}
		/**
		* @return String
		**/
		public override function toString():String{
			return "TextBox id:"+id+" text:"+text;
		}
	}
}

