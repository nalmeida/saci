/*
*	@author: Igor Almeida
*	@version: 1.1;
*
*	@thanks mrdoob
*
*	*/
package redneck.util.display
{	
	import flash.display.*;
	public class Resize
	{
		/**
		* 
		* Returns the final scaled size to be applied on the object.
		* 
		* @param p_oW		Number	object width
		* @param p_oH		Number	object height
		* @param p_rW		Number	to scale width
		* @param p_rH		Number	to scale height
		* @param p_crop		Boolean
		* 
		* @return Object with "width" and "height" properties
		* 
		**/
		public static function getResizedResult( p_oW:Number, p_oH:Number,p_rW:Number, p_rH:Number, p_crop:Boolean = false ):Object{
			var result : Object = {}
			if (!p_crop){
				if ((p_oW / p_rW) < (p_oH / p_rH)){
					result.height = p_rH;
					result.width = p_oW * (p_rH / p_oH);
				}
				else{
					result.width = p_rW;
					result.height = p_oH * (p_rW / p_oW);
				}
			}
			else{
				if (( p_oW / p_rW) > (p_oH / p_rH)){
					result.height = p_rH;
					result.width = p_oW * (p_rH / p_oH);
				}
				else{
					result.width = p_rW;
					result.height = p_oH * (p_rW / p_oW);
				}
			}
			return result;
		}
		/**
		* 
		* Resize an object keeping the proportion
		* 
		* @param p_toResize			Any display Object less Stage
		* @param p_toReference		Any display Object and Stage
		* @param p_crop				Boolean
		* @param p_originalWidth	Number	p_toResize original width
		* @param p_originalHeight	Number	p_toResize original height
		* 
		**/
		public static function me( p_toResize:*, p_toReference:*, p_crop:Boolean = false, p_originalWidth : Number = NaN, p_originalHeight : Number = NaN ) : Boolean{
			if (p_toReference == null || p_toResize is Stage || p_toResize ==null){
				return false;
			}
			var ow : Number;
			var oh : Number;
			if (p_toResize.hasOwnProperty("width") && p_toResize.hasOwnProperty("height") ){
				ow = isNaN(p_originalWidth) ? p_originalWidth : p_toResize.width;
				oh = isNaN(p_originalHeight) ? p_originalHeight : p_toResize.height;
			}
			var rw : Number;
			var rh : Number;
			if ( p_toReference is Stage){
				rw = p_toReference.stageWidth;
				rh = p_toReference.stageHeight;
			} else if ( p_toReference.hasOwnProperty("width") && p_toReference.hasOwnProperty("height") ){
				rw = p_toReference.width;
				rh = p_toReference.height;
			} else{
				return false
			}
			var result : Object = getResizedResult( ow, oh, rw, rh, p_crop );
			p_toResize.width = result.width;
			p_toResize.height = result.height;
			return true;
		}
	}
}