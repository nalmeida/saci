/**
* 
* @author igor almeida
* version 1.0
*
**/
package redneck.display.shapes
{
	import flash.geom.*;
	import flash.display.*;
	import redneck.display.shapes.Shape;
	public class Circle extends Shape
	{
		/**
		*	
		*	Draws a Circle
		*	
		*	@param	p_area			Rectangle
		*	@param	p_autoRender	Boolean
		*	
		*	@example:
		*	
		*	var r : Circle = new Circle ( new Rectangle(0,0,100,100) )
		*		r.fill.colors = [0x0,0xfff];
		*	
		*	addChild( r )
		*	
		*	var r : Circle = new Circle( new Rectangle(0,0,100,60) );
		*		r.fill.colors = [0xff0000];
		*	
		**/
		public function Circle(p_area:*, p_autoRender:Boolean = true):void
		{
			super(p_area,p_autoRender);
			fill.gradientType = GradientType.RADIAL;
		}
		/**
		*	
		*	Sets the current rectangle area
		*	
		*	@param value	Rectangle
		*	
		*/
		public override function set area(value:*):void
		{
			super.area = value;
			if (area){
				fill.gradientWidth = isNaN(fill.gradientWidth) ? area.width : fill.gradientWidth;
				fill.gradientHeight = isNaN(fill.gradientHeight) ? area.height : fill.gradientHeight;

				line.gradientWidth = isNaN(line.gradientWidth) ? area.width : line.gradientWidth;
				line.gradientHeight = isNaN(line.gradientHeight) ? area.height : line.gradientHeight;

				if (autoRender){
					render();
				}
			}
		}
		/**
		*	
		*	Draw the graphic. 
		*	
		*	@see Shape.autoRender
		*	
		*	@param	p_clearBefore Boolean
		*	
		*	@example
		*	
		*		var r : Circle = addChild ( new Circle( new Rectangle(0,0,10,10), false ) );
		*			r.fill.colors = [0]
		*			// untill now, nothing will happen
		*			r.render();
		*	
		*	To have your <code>Circle</code> being updated as fast as you change their properties, turns the <code>Shape.autoRender</code> to <code>true</code>
		*	
		*	@return Boolean
		*	
		**/
		public override function render(p_clearBefore:Boolean = true):Boolean
		{
			if ( area!=null && (area is Rectangle) && (area.width+area.height)>0)
			{
				super.render(p_clearBefore);
				with(this.graphics){
					if (area.width==area.height){
						drawCircle( area.x+area.width*.5, area.y+area.width*.5, area.height*.5 );
					}
					else{
						drawEllipse( area.x, area.y, area.width, area.height );
					}
					endFill();
				}
				return true;
			}
			return false;
		}
	}
}