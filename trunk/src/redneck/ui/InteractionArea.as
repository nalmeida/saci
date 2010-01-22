/**
* @author igor almeida
* @version 1.0
**/
package redneck.ui {
	
	import flash.display.*;
	import flash.geom.*;
	import flash.events.*;
	
	[Event(name="rollOver", type="flash.events.MouseEvent")]
	[Event(name="rollOut", type="flash.events.MouseEvent")]
	
	public class InteractionArea extends EventDispatcher {

		public var rollOver : Function;
		public var rollOut : Function;
		public var isOver : Boolean

		private var _scope : DisplayObjectContainer;
		private var _bounds : Rectangle;
		private var _debug : Boolean;
		private var point : Point;
		private var scopeBounds : Rectangle;
		private var hit : Sprite;

		private const outEvent:MouseEvent = new MouseEvent( MouseEvent.ROLL_OUT );
		private const overEvent:MouseEvent = new MouseEvent( MouseEvent.ROLL_OVER );
		
		/**
		*	
		*	Check the mouse collision in a specific bound.
		*	
		*	@param p_scope
		*	@param p_bounds
		*	
		*	@return InteractionArea
		*	
		*	@usage
		*	var a  : * = addChild(getPlaceHolder(20,20));
		*		a.x = 200;
		*		a.y = 200;
		*		
		*	var i : InteractionArea = new InteractionArea();
		*		i.rollOver = function():void{
		*			trace("over")
		*		}
		*		i.rollOut = function():void{
		*			trace("out")
		*		}
		*		i.create( a, new Rectangle(10,10,100,100), true ).start();
		*	
		**/
		public function create( p_scope:DisplayObjectContainer, p_bounds:Rectangle, p_showDebug:Boolean = false ):InteractionArea{
			
			_scope = p_scope;
			_bounds = p_bounds;
			
			if (!scope.parent){
				return null;
			}
			
			point = new Point;
			scope.addEventListener( Event.REMOVED_FROM_STAGE, stop, false, 0, true );
			
			if (p_showDebug){
				debug = true;
			}

			return this;
		}
		
		public function set debug(value:Boolean):void
		{
			_debug = value;
			if (debug){
				addDebug();
			}
			else{
				removeDebug()
			}
		}
		
		public function get debug():Boolean
		{
			return _debug;
		}

		public function get scope():DisplayObjectContainer{return _scope;}
		public function get bounds():Rectangle{return _bounds;}

		public function start(e:*=null):void{
			if (scope.parent){
				scope.addEventListener( Event.ENTER_FRAME, checkCollision, false, 0, true );
			}
		}

		public function stop(e:*=null):void{
			if (scope){
				scope.removeEventListener( Event.ENTER_FRAME, checkCollision );
			}
		}

		private function checkCollision(e:Event):void{

			if (!scope && scope.parent){
				trace("[InteractionArea] stoped because the context was removed.")
				destroy();
				return;
			}

			scopeBounds = scope.getBounds( scope.parent );
			scopeBounds.x += bounds.x;
			scopeBounds.y += bounds.y;
			scopeBounds.width = bounds.width;
			scopeBounds.height = bounds.height;

			point.x = scope.parent.mouseX;
			point.y = scope.parent.mouseY;

			if (scopeBounds.containsPoint( point )){
				isOver = true;
				dispatchEvent( overEvent );
				if ( rollOver!=null ){
					rollOver.apply(null);
				}
			}else{
				isOver = false;
				dispatchEvent( outEvent );
				if ( rollOut!=null ){
					rollOut.apply(null);
				}
			}

			if (debug){
				draw();
			}
		}
		
		private function removeDebug():void{
			if (hit && scope && scope.parent && scope.parent.contains(hit)){
				scope.parent.removeChild(hit);
				hit.graphics.clear();
				hit = null;
			}
		}
		
		private function addDebug():void{
			if (!hit && scope && scope.parent){
				hit = scope.parent.addChild( new Sprite ) as Sprite;
			}
		}
		
		private function draw():void{
	
			hit.x = scopeBounds.x;
			hit.y = scopeBounds.y;

			with(hit.graphics){
				clear();
				beginFill( (isOver ? 0x00FF00 : 0xff0000), .5 );
				drawRect( 0, 0, scopeBounds.width, scopeBounds.height );
				endFill();
			}
		}
		
		public function destroy():void{
			stop();
			if (scope){
				scope.removeEventListener( Event.REMOVED_FROM_STAGE, stop );
			}
			removeDebug();
			rollOut = null;
			rollOut = null;
		}
	}
}