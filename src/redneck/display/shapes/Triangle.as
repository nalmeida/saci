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
	import redneck.util.math.*;
	
	[Bindable]
	
	public class Triangle extends Shape
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
		*	
		**/
		public function Triangle(p_area:*, p_autoRender:Boolean = true):void
		{
			super(p_area,p_autoRender);
		}
		/**
		*	
		*	Sets the current rectangle area
		*	
		*	@param value	Rectangle
		*	
		*/
		public var commandStack : Array;
		public override function set area(value:*):void
		{
			super.area = value;	
			commandStack = new Array;
			if(area is Rectangle){
				commandStack.push( new Command("moveTo",value.width*.5+value.x,value.y) );
				commandStack.push( new Command("lineTo",value.width,value.height) );
				commandStack.push( new Command("lineTo",value.x,value.height) );
				commandStack.push( new Command("lineTo",value.width*.5+value.x,value.y) );
			}
			else if (value is Object){
				super.area = value;	
			}
			else if (value is Array){
				super.area = null;
			}
		}
		/**
		*	
		*	Draw the graphic. 
		*	
		*	@see Shape.autoRender
		*	@see Box.render
		*	
		**/
		public override function render(p_clearBefore:Boolean = true):Boolean
		{
			if ( commandStack && commandStack.length>3 )
			{
				super.render(p_clearBefore);
				var rp : Point;
				commandStack.forEach( function(item:Command,...rest):void{
					graphics[item.type]( item.x, item.y);
				}, this );

				this.graphics.endFill();
				return true;
			}
			return false;
		}
	}
}