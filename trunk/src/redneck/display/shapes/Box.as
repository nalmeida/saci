/**
* 
* @author igor almeida
* version 2.0
*
**/
package redneck.display.shapes
{
	import flash.geom.*;
	import flash.display.*;
	import redneck.display.shapes.Shape;
	[Bindable]
	public class Box extends Shape
	{
		
		/*box*/
		internal var _corners : Number;
		internal var _cornerTL : Number;
		internal var _cornerTR : Number;
		internal var _cornerBL : Number;
		internal var _cornerBR : Number;

		/*@private*/
		private var theta:Number;
		private var angle:Number;
		private var cx:Number;
		private var cy:Number;
		private var px:Number;
		private var py:Number;
		private var commandStack:Array;
		/**
		*	
		*	Draws a Rectangle
		*	
		*	@param	p_area			Rectangle
		*	@param	p_autoRender	Boolean
		*	
		*	@example:
		*	
		*	var r : Box = new Box ( new Rectangle(0,0,100,100) )
		*		r.fill.colors = [0x0,0xfff];
		*		r.fill.alphas = [0,1];
		*		r.line.stroke = 3
		*		r.line.colors = [0x999,0xffffff];
		*		r.corners = 10;
		*		r.cornerTL = 0;
		*	
		*	addChild( r )
		*	
		**/
		public function Box(p_area:*, p_autoRender:Boolean = true):void
		{
			super(p_area,p_autoRender);

			/*corners setting */
			_cornerBR =
			_cornerBL =
			_cornerTR =
			_cornerTL = 
			_corners = 0;
		}
		/**
		*
		*	Sets all corners to <code>value</code>
		*	
		*	@value	Number
		*	
		*	@see Box.cornerBR
		*	@see Box.cornerBL
		*	@see Box.cornerTL
		*	@see Box.cornerTR
		*	
		**/
		public function get corners():Number{return _corners;}
		public function set corners(value:Number):void
		{
			value = isNaN(value) ? 0 : value;
			_corners = value*.5;
			_cornerBR = _corners;
			_cornerBL = _corners;
			_cornerTR = _corners;
			_cornerTL = _corners;
			if (autoRender){
				render( );
			}
		}
		/**
		*	change the round angle to the Top Left corner
		*	@param value	Number
		*/
		public function get cornerTL():Number{return _cornerTL;}
		public function set cornerTL(value:Number):void
		{
			value = isNaN(value) ? 0 : value;
			_cornerTL = value;
			if (autoRender){
				render( );
			}
		}
		/**
		*	change the round angle to the Top Right corner
		*	@param value	Number
		*/
		public function get cornerTR():Number{return _cornerTR;}
		public function set cornerTR(value:Number):void
		{
			value = isNaN(value) ? 0 : value;
			_cornerTR = value;
			if (autoRender){
				render( );
			}
		}
		/**
		*	change the round angle to the Botton Right corner
		*	@param value	Number
		*/
		public function get cornerBR():Number{return _cornerBR;}
		public function set cornerBR(value:Number):void
		{
			value = isNaN(value) ? 0 : value;
			_cornerBR = value;
			if (autoRender){
				render( );
			}
		}
		/**
		*	change the round angle to the Botton Left corner
		*	@param value	Number
		*/
		public function get cornerBL():Number{return _cornerBL;}
		public function set cornerBL(value:Number):void
		{
			value = isNaN(value) ? 0 : value;
			_cornerBL = value;
			if (autoRender){
				render( );
			}
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
		*		var r : Box = addChild ( new Box( new Rectangle(0,0,10,10), false ) );
		*			r.fill.colors = [0]
		*			// untill now, nothing will happen
		*			r.render();
		*	
		*	To have your <code>Box</code> being updated as fast as you change their properties, turns the <code>Shape.autoRender</code> to <code>true</code>
		*	
		*	@return Boolean
		*	
		**/
		public override function render(p_clearBefore:Boolean = true):Boolean
		{
			if ( area && (area.width+area.height)>0)
			{
				super.render(p_clearBefore);
				with(this.graphics){
					if ((cornerTL+cornerTR+cornerBR+cornerBL+corners)==0){
						drawRect(area.x,area.y,area.width,area.height);
					}
					else{
						drawRounded( );
					}
					endFill();	
				}
				return true;
			}
			return false;
		}
		/**
		*	
		*	Adaptation for Degrafa framework
		*	
		**/
		private function drawRounded():void
		{
			commandStack = new Array
			// theta = 45 degrees in radians
			theta = Math.PI/4;
			
			// draw top line
			commandStack.push({type:"m", x:area.x+cornerTL, y:area.y});
			commandStack.push({type:"l", x:area.x+area.width-cornerTR, y:area.y});
			
			//angle is currently 90 degrees
			angle = -Math.PI/2;

			// draw tr corner in two parts
			cx = area.x+area.width-cornerTR+(Math.cos(angle+(theta/2))*cornerTR/Math.cos(theta/2));
			cy = area.y+cornerTR+(Math.sin(angle+(theta/2))*cornerTR/Math.cos(theta/2));
			px = area.x+area.width-cornerTR+(Math.cos(angle+theta)*cornerTR);
			py = area.y+cornerTR+(Math.sin(angle+theta)*cornerTR);
			commandStack.push({type:"c",cx:cx,
			cy:cy,
			x1:px,
			y1:py});

			angle += theta;
			cx = area.x+area.width-cornerTR+(Math.cos(angle+(theta/2))*cornerTR/Math.cos(theta/2));
			cy = area.y+cornerTR+(Math.sin(angle+(theta/2))*cornerTR/Math.cos(theta/2));
			px = area.x+area.width-cornerTR+(Math.cos(angle+theta)*cornerTR);
			py = area.y+cornerTR+(Math.sin(angle+theta)*cornerTR);
			commandStack.push({type:"c",cx:cx,
			cy:cy,
			x1:px,
			y1:py});

			// draw right line
			commandStack.push({type:"l", x:area.x+area.width,y:area.y+area.height-cornerBR});

			// draw br corner
			angle += theta;
			cx = area.x+area.width-cornerBR+(Math.cos(angle+(theta/2))*cornerBR/Math.cos(theta/2));
			cy = area.y+area.height-cornerBR+(Math.sin(angle+(theta/2))*cornerBR/Math.cos(theta/2));
			px = area.x+area.width-cornerBR+(Math.cos(angle+theta)*cornerBR);
			py = area.y+area.height-cornerBR+(Math.sin(angle+theta)*cornerBR);
			commandStack.push({type:"c",cx:cx,
			cy:cy,
			x1:px,
			y1:py});

			angle += theta;
			cx = area.x+area.width-cornerBR+(Math.cos(angle+(theta/2))*cornerBR/Math.cos(theta/2));
			cy = area.y+area.height-cornerBR+(Math.sin(angle+(theta/2))*cornerBR/Math.cos(theta/2));
			px = area.x+area.width-cornerBR+(Math.cos(angle+theta)*cornerBR);
			py = area.y+area.height-cornerBR+(Math.sin(angle+theta)*cornerBR);
			commandStack.push({type:"c",cx:cx,
			cy:cy,
			x1:px,
			y1:py});
			
			// draw bottom line
			commandStack.push({type:"l", x:area.x+cornerBL,y:area.y+area.height});
			
			// draw bl corner
			angle += theta;
			cx = area.x+cornerBL+(Math.cos(angle+(theta/2))*cornerBL/Math.cos(theta/2));
			cy = area.y+area.height-cornerBL+(Math.sin(angle+(theta/2))*cornerBL/Math.cos(theta/2));
			px = area.x+cornerBL+(Math.cos(angle+theta)*cornerBL);
			py = area.y+area.height-cornerBL+(Math.sin(angle+theta)*cornerBL);
			commandStack.push({type:"c",cx:cx,
			cy:cy,
			x1:px,
			y1:py});

			angle += theta;
			cx = area.x+cornerBL+(Math.cos(angle+(theta/2))*cornerBL/Math.cos(theta/2));
			cy = area.y+area.height-cornerBL+(Math.sin(angle+(theta/2))*cornerBL/Math.cos(theta/2));
			px = area.x+cornerBL+(Math.cos(angle+theta)*cornerBL);
			py = area.y+area.height-cornerBL+(Math.sin(angle+theta)*cornerBL);
			commandStack.push({type:"c",cx:cx,
			cy:cy,
			x1:px,
			y1:py});
			
			// draw left line
			commandStack.push({type:"l", x:area.x,y:area.y+cornerTL});
			
			// draw tl corner
			angle += theta;
			cx = area.x+cornerTL+(Math.cos(angle+(theta/2))*cornerTL/Math.cos(theta/2));
			cy = area.y+cornerTL+(Math.sin(angle+(theta/2))*cornerTL/Math.cos(theta/2));
			px = area.x+cornerTL+(Math.cos(angle+theta)*cornerTL);
			py = area.y+cornerTL+(Math.sin(angle+theta)*cornerTL);
			commandStack.push({type:"c",cx:cx,
			cy:cy,
			x1:px,
			y1:py});
			
			angle += theta;

			cx = area.x+cornerTL+(Math.cos(angle+(theta/2))*cornerTL/Math.cos(theta/2));
			cy = area.y+cornerTL+(Math.sin(angle+(theta/2))*cornerTL/Math.cos(theta/2));
			px = area.x+cornerTL+(Math.cos(angle+theta)*cornerTL);
			py = area.y+cornerTL+(Math.sin(angle+theta)*cornerTL);
			commandStack.push({type:"c",cx:cx,
			cy:cy,
			x1:px,
			y1:py});
			
			var item:Object;
			for each (item in commandStack){
				switch(item.type){
					case "m":
						this.graphics.moveTo(item.x,item.y);
						break;
					case "l":
						this.graphics.lineTo(item.x,item.y);
						break;
					case "c":
						this.graphics.curveTo(item.cx,item.cy,item.x1,item.y1);
						break;
				}
			}
		}
	}
}