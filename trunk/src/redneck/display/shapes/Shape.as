/**
* 
* @author igor almeida
* version 1.0
*
**/
package redneck.display.shapes
{
	import flash.display.*;
	[Bindable]
	public class Shape extends Sprite
	{
		/*controls wether the shape must be updated after any setter changes.*/
		public var autoRender : Boolean;
	
		/*fill*/
		internal var _fill : FillControl;
		public function get fill():FillControl{return _fill;}
	
		/*linefill insert*/
		internal var _line : LineFillControl;
		public function get line():LineFillControl{return _line;}

		/**shape coordenates**/
		internal var _area:*
		public function get area():*{return _area;}
		public function set area(value:*):void{_area = value;}
		/**
		*	
		*	Shape
		*	
		*	@param	p_area			Rectangle
		*	@param	p_autoRender	Boolean
		*	
		*	@see Box
		*	@see Circle
		*	@see Triangle
		*	
		**/
		public function Shape(p_area:*,p_autoRender:Boolean = true)
		{
			_fill = new FillControl( );
			_fill.onChange = check;
			
			_line = new LineFillControl( );
			_line.onChange = check;

			autoRender = p_autoRender;
			area = p_area
		}
		/**controll the autoRender updates*/
		internal function check():void{
			if (autoRender){
				render();
			}
		}
		/**
		*	
		*	Draw the graphic
		*
		*	@param	p_clearBefore Boolean
		*	
		*	@return Boolean
		*	
		**/
		public function render(p_clearBefore:Boolean = true):Boolean
		{
			if ( area )
			{
				/*drawing*/
				with(this.graphics){
					if (p_clearBefore){
						clear();
					}
					if ( line.stroke>0 && !isNaN(line.stroke) ){
						if ( !line.colors || (line.colors && line.colors.length<=1) ){
							lineStyle( line.stroke, line.colors ? line.colors[0] : 1, line.relativeAlphas ? line.relativeAlphas[0] : 1 ,line.pixelHinting, line.scaleMode, line.caps, line.joints,line. miterLimit);	
						}
						else if (line.colors && line.colors.length>1){
							lineStyle( line.stroke )
							lineGradientStyle( line.gradientType, line.colors, line.relativeAlphas, line.ratios, line.matrix, line.spreadMethod, line.interpolationMethod, line.focalPointRatio )
						}
					}
					if ( fill.colors && fill.colors.length>1 ){
						beginGradientFill( fill.gradientType, fill.colors, fill.relativeAlphas, fill.ratios, fill.matrix, fill.spreadMethod, fill.interpolationMethod, fill.focalPointRatio);
					}
					else if ( fill.colors && fill.colors.length<=1 ){
						beginFill( fill.colors[0], fill.relativeAlphas ? fill.relativeAlphas[0] : 1 );
					}
				}
				return true;
			}
			return false;
		}
		
	}
}

