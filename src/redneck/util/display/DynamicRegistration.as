/**
*
* Rotates and scales any sprite using a different register point.
* 
* @author igor almeida
* @version 1
* 
* Based at DynamicMovie from Oscar Treller
*
**/
package redneck.util.display
{	
	import flash.display.*;
	import flash.geom.*;
	public class DynamicRegistration
	{
		private var _display : DisplayObject;
		private var _register : Point;
		private var a:Point;
		private var b:Point;
		private var p:Point;
		public static const TOP : int = 1;
		public static const MIDDLE : int = 2;
		public static const BOTTOM : int = 4;
		public static const LEFT : int = 8;
		public static const RIGHT : int = 16;
		public static const CENTER : int = 32;
		private static const anchors : Array = [TOP,MIDDLE,BOTTOM,LEFT,RIGHT,CENTER];
		/**
		* 
		*	//
		*	
		*	@param p_scope	Sprite;
		*	
		**/
		public function DynamicRegistration( p_scope: DisplayObject ) : void
		{
			super();
			_display = p_scope;
			register = new Point( );
		}
		/**
		*	@return Sprite
		**/
		public function get display( ):DisplayObject
		{
			return _display;
		}
		/**
		* 
		*	Register a new point to affect the <code>display</code> on scales and rotation.
		* 
		*	@param p_obj	Point or any object with
		*	
		*	@see DynamicRegistration.TOP
		*	@see DynamicRegistration.LEFT
		*	@see DynamicRegistration.RIGHT
		*	@see DynamicRegistration.BOTTOM
		*	@see DynamicRegistration.MIDDLE
		*	@see DynamicRegistration.CENTER
		*	
		*	@usage 
		*	var d : DynamicRegistration = new DynamicRegistration( supermc );
		*		d.register = DynamicRegistration.RIGHT + DynamicRegistration.BOTTOM;
		*		//or d.register = DynamicRegistration.RIGHT
		*		//or d.register =  new Point(10,10)
		*		//or d.register =  {x:10,y:10};
		* 
		**/
		public function set register ( p_obj: * ) :void{
			if ( p_obj is Point ){
				_register = p_obj;
			}
			else if ( p_obj is Number ){
				anchors.forEach( function(item:int,...rest):void{
					if( (item & p_obj)  == item ){
						switch( item ){
							case TOP:
								_register.y = 0;
								break;
							case MIDDLE:
								_register.y = display.height*.5;
								break;
							case BOTTOM:
								_register.y = display.height;
								break;
							case LEFT:
								_register.x = 0;
								break;
							case CENTER:
								_register.x = display.width*.5;
								break;
							case RIGHT:
								_register.x = display.width;
								break;
						}
					}
				} )
			}
			else if (p_obj is Object){
				_register.x = p_obj.hasOwnProperty("x") ? p_obj.x : register.x;
				_register.y = p_obj.hasOwnProperty("y") ? p_obj.y : register.y;
			}
		}
		/**
		* @return Point
		**/
		public function get register():Point{
			return _register;
		}
		/**
		* @param value
		**/
		public function set x(value:Number):void
		{
			p = display.parent.globalToLocal(display.localToGlobal(register));
			display.x += value - p.x;
		}
		/**
		* @return Number
		**/
		public function get x():Number
		{
			p = display.parent.globalToLocal(display.localToGlobal(register));
			return p.x;
		}
		/**
		* @param value
		**/
		public function set y(value:Number):void
		{
			p = display.parent.globalToLocal(display.localToGlobal(register));
			display.y += value - p.y;
		}
		/**
		* @return Number
		**/
		public function get y():Number
		{
			p = display.parent.globalToLocal(display.localToGlobal(register));
			return p.y;
		}
		/**
		* @param value
		**/
		public function set scaleX(value:Number):void
		{
			this.update( "scaleX", value );
		}
		/**
		* @return Number
		**/
		public function get scaleX():Number
		{
			return display.scaleX;
		}
		/**
		* @param value
		**/
		public function set scaleY(value:Number):void
		{
			this.update( "scaleY", value );
		}
		/**
		* @return Number
		**/
		public function get scaleY():Number
		{
			return display.scaleY;
		}
		/**
		* @param value
		**/
		public function set rotation(value:Number):void
		{
			update("rotation", value);
		}
		/**
		* @return Number
		**/
		public function get rotation():Number
		{
			return display.rotation;
		}
		/**
		* @return Number
		**/
		public function get mouseX():Number
		{
			return Math.round(display.mouseX - register.x);
		}
		/**
		* @return Number
		**/
		public function get mouseY():Number
		{
			return Math.round(this.mouseY - register.y);
		}
		/**
		* @private
		**/
		private function update( prop:String, n:Number ):void{
			if (display.parent){
				a = display.parent.globalToLocal(display.localToGlobal(register));
				display[prop] = n;
				b = display.parent.globalToLocal(display.localToGlobal(register));
				this.x -= b.x - a.x;
				this.y -= b.y - a.y;
			}else{
				trace("DynamicRegistration::update() "+display+" has no parent.");
			}
		}
	}
}