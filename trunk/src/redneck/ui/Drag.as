/**
* Drag 
* Thanks to Nicholas Almeida (http://www.nicholasalmeida.com) to test and fix some bugs.
* @author Igor Almeida [contato@ialmeida.com]
* @version 0.3
* @since 19.02.2007
* @usage
* 	<code>
*	// box is a sprite/moviclip added on stage.
*	
*	var dragArea:Rectangle = new Rectangle(0,0,100.8,0);
*	var d:Drag = new Drag(box, dragArea);
*
*	box.addEventListener(MouseEvent.MOUSE_DOWN, goDrag);
*	box.stage.addEventListener(MouseEvent.MOUSE_UP, outDrag);
*
*	function outDrag(e:MouseEvent):void{
*		d.off();
*	}
*
*	function goDrag(e:MouseEvent):void{
*		d.on();
*	}
*	</code>
*/
package redneck.ui
{
	import flash.events.MouseEvent;
	public class Drag
	{
		import flash.events.Event;
		import flash.geom.Rectangle;
		import flash.geom.Point;
		import flash.display.Sprite;

		private var obj:*;
		private var rect:Rectangle;
		private var bounds:Rectangle;
		private var offset:Point;
		private var h:Sprite;
		/**
		 *	Drag 
		 * 
		 *	@param who Object to be dragged
		 *	@param area
		 * 
		 **/
		public function Drag( _who:*, _area:Rectangle )
		{
			this.obj = _who;
			this.rect = _area;

			if ( !this.obj.stage ){
				this.obj.addEventListener(Event.ADDED_TO_STAGE, refresh, false, 0, true);
			}
			else{
				refresh();
			}
		}
		/**
		 * 
		 * Permite passar um novo Rectangle como area de drag.
		 * 
		 *	@param newRect	Rectangle
		 * 
		 **/
		public function refresh( newRect:*=null ) : void
		{
			if ( newRect == Event && this.obj.hasEventListener( Event.ADDED_TO_STAGE ) ) {
				this.obj.removeEventListener( Event.ADDED_TO_STAGE, refresh );
			}
			if ( newRect is Rectangle ){
				this.rect = newRect as Rectangle;
			}
			this.bounds = this.obj.getRect( this.obj.parent );
			this.bounds.x -= this.obj.x;
			this.bounds.y -= this.obj.y;
			this.rect.x += this.obj.x;
			this.rect.y += this.obj.y;
		}
		/**
		 * 
		 * stop drag when flash lose the focus. 
		 * 
		 * */
		private function forceStop( e : Event ) : void
		{
			off();
		}
		/**
		 * 
		 * Starts object drag.
		 * 
		 **/
		public function on():void
		{
			this.offset = new Point( this.obj.mouseX , this.obj.mouseY );
			this.obj.addEventListener(Event.ENTER_FRAME, checkPosition, false, 0, true);
			if ( this.obj.stage) {
				this.obj.stage.addEventListener( Event.MOUSE_LEAVE, forceStop, false, 0, true );
			}
		}
		/**
		 * 
	 	 *	Stop drag.
	 	 * 
		 **/
		public function off() : void
		{
			if ( this.obj.stage) {
				this.obj.stage.removeEventListener( Event.MOUSE_LEAVE, forceStop );
			}
			this.obj.removeEventListener(Event.ENTER_FRAME, checkPosition);	
			this.offset = new Point();
		}
		/**
		 * 
		 * Esse metodo é só uma forma de ajuda para debug, pois ele
		 * desenha um retangulo mostrando a area onde o drag vai atuar.
		 * 
		 * @param	c	int	color to draw the drag area. if -1 hide, else draw the drag area.
		 * 
		 */
		public function help(c:int):void
		{
			if ( c==-1 && h!=null )
			{
				h.graphics.clear();
				if (this.obj.stage !=null && this.obj.stage.contains( h ) ){
					this.obj.stage.removeChild( h );
				}
				h = null;
			}
			else{
				if ( this.obj.stage != null ){
					if ( !h ){
						 h = new Sprite( );
					}
					h.graphics.clear(); 
					h.graphics.beginFill( c,.2 );
					h.graphics.drawRect( this.rect.x,this.rect.y,this.rect.width,this.rect.height );
					h.graphics.endFill( );
					h.mouseEnabled = false;
					h.mouseChildren = false;
					h.x = this.bounds.x;
					h.y = this.bounds.y;
					if ( !this.obj.parent.contains ( h ) ){
						this.obj.parent.addChild( h );
					}
				}	
			}
		}
		/**
		 * @private 
		 * 
		 * check the mouse position and change the object position.
		 * 
		 **/
		private function checkPosition(e:Event) : void
		{
			var x:Number = this.obj.parent.mouseX-this.offset.x;
			var y:Number = this.obj.parent.mouseY-this.offset.y;
			this.obj.x = (x-bounds.x<this.rect.x) ? this.rect.x : ((x-bounds.x)>this.rect.width+this.rect.x) ? this.rect.x+this.rect.width : x-bounds.x;
			this.obj.y = (y-bounds.y<this.rect.y) ? this.rect.y : ((y-bounds.y)>this.rect.height+this.rect.y) ? this.rect.y+this.rect.height : y-bounds.y;
		}
		public function destroy(e:*=null):void{
			off();
			help(-1)
			this.obj = null;
			this.rect = null;
			this.bounds = null
			this.offset = null;
		}
	}
}