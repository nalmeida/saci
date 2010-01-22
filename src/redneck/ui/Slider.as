/** 
 * Slider 
 * 
 * @author igor almeida 
 * Thanks for Nicholas Almeida and Carneiro.
 * 
 * @version 1.1
 * @since 31.05.2007
 * 
 * @example
 * <code>
 * 
 * 	var sld:Slider = new Slider(bt,track);
 *		sld.seek = true;
 *		sld.addEventListener(Slider.EVENT_CHANGE,oChange);
 *
 *	function oChange(mE:Event){
 *		trace(mE.target.percent+"%");
 *		//trace(sld.percent+"%");
 *	}
 * </code>
 * 
 **/
package redneck.ui
{
	import flash.display.*;
	import flash.events.*;
	import flash.geom.*;
	import redneck.events.SliderEvent;
	
	/**
	*	Dispatched when a <code>percent</code> is changed.
	*	@eventType redneck.events.SliderEvent.ON_CHANGE
	*/
	[Event(name = "sliderOnChange", type = "redneck.events.SliderEvent")]
	/**
	*	Dispatched when the mouse is down on slider instance.
	*	@eventType redneck.events.SliderEvent.ON_PRESS
	*/
	[Event(name = "sliderOnPress", type = "redneck.events.SliderEvent")]
	/**
	*	Dispatched when the mouse is up.
	*	@eventType redneck.events.SliderEvent.ON_RELASE
	*/
	[Event(name="sliderOnRelease", type="redneck.events.SliderEvent")]
	/***/
	public class Slider extends EventDispatcher
	{
		private var bt:Sprite;
		private var track:Sprite;
		private var horizontal:Boolean = true;
		private var tracksize:Number;
		private var rectDrag:Rectangle;
		private var drag:Drag;
		private var _seekEnabled:Boolean;
		private var _wheelEnabled:Boolean;
		private var posProp : String;
		private var sizeProp : String;
		private var isEnabled : Boolean = true;
		/**
		 * 
		 * 
		 * @param _bt			button to drag
		 * @param _track		define the button slider limmits
		 * @param initPercent	initial percent to start
		 * @param seekEnabled	enable seek on trackbar
		 * @param isHorizontal	slider orientation
		 * 
		 **/
		public function Slider( _bt:Sprite, _track:Sprite, isHorizontal : Boolean = true ) : void
		{

			this.bt = _bt ;
			this.track = _track;
			this.horizontal =  isHorizontal
			refresh( );
			enable( );
		}
		/**
		* defines track bar seek
		* @param value Boolean
		**/
		public function set seek(value:Boolean):void
		{
			_seekEnabled = value;
			if (isEnabled){
				enable();
			}
		}
		/**
		* @return Boolean
		**/
		public function get seek():Boolean
		{
			return _seekEnabled;
		}
		/**
		* defines mouse wheel monitor;
		* @return Boolean
		**/
		public function set wheel(value:Boolean):void
		{
			_wheelEnabled = value;
			if (isEnabled){
				enable();
			}
		}
		/**
		* @return Boolean
		**/
		public function get wheel():Boolean
		{
			return _wheelEnabled;
		}
		/**
		 * 
		 * Caso o tamanho de algum item ou a posicao mudem
		 * (example: mudar a posicao y do track) é necessario
		 * executar esse método para recriar a area de drag. 
		 * 
		 * */
		public function refresh():void
		{
			var p : Number = percent;
			if (this.horizontal){
				this.tracksize = this.track.width - this.bt.width;
				this.bt.x = this.track.x;
				this.rectDrag = new Rectangle( 0 , 0 , tracksize , 0 );
				this.posProp = "x";
				this.sizeProp = "width";
			}
			else{
				tracksize = this.track.height - this.bt.height;
				this.bt.y = this.track.y;
				this.rectDrag = new Rectangle( 0 , 0 , 0, tracksize );
				this.posProp = "y";
				this.sizeProp = "height";
			}
			if( this.drag ){
				this.drag.off();
			}
			this.drag = new Drag( this.bt , this.rectDrag );
			percent = p;
		}
		/**
		 * @private
		 * 
		 * Start drag.
		 * @dispatches Slider.EVENT_PRESS
		 * 
		 * */
		private function onDrag( mE:MouseEvent ) : void
		{
			dispatchEvent( new SliderEvent(SliderEvent.ON_PRESS) );
			this.drag.on( );
			if (this.bt.stage){
				this.bt.stage.addEventListener( MouseEvent.MOUSE_UP , offDrag , false, 0, true);
				this.bt.stage.addEventListener( Event.MOUSE_LEAVE , offDrag , false, 0, true);
				this.bt.stage.addEventListener( Event.ENTER_FRAME, onTrack, false, 0, true );
			}
		}
		/**
		 * @private
		 * 
		 * Stop drag
		 * @dispatches Slider.EVENT_RELEASE
		 * 
		 * */
		private function offDrag( mE:Event ) : void
		{
			dispatchEvent( new SliderEvent(SliderEvent.ON_RELEASE) );
			if (this.drag){
				this.drag.off( );
			}
			if (this.bt && this.bt.stage){
				this.bt.stage.removeEventListener( MouseEvent.MOUSE_UP, offDrag );
				this.bt.stage.removeEventListener( Event.ENTER_FRAME, onTrack );
			}
		}
		/**
		 * @private
		 * 
		 * Update percent
		 * @dispatche	Slider.EVENT_PRESS
		 * 
		 * */
		private function onTrack(mE:Event):void
		{
			dispatchEvent( new SliderEvent(SliderEvent.ON_CHANGE) );
		}
		/**
		 * @private
		 * 
		 * Check the current percent 
		 * 
		 **/
		private function dragTo( mE:MouseEvent ) : void
		{
			var p:Number;
			if (horizontal){
				p = mE.localX * this.track.scaleX;
				this.bt.x = (rectDrag.x + p > this.rectDrag.x+this.rectDrag.width) ? this.rectDrag.x + this.rectDrag.width : rectDrag.x + p ;	
			}
			else{
				p = mE.localY * this.track.scaleY;
				this.bt.y = (rectDrag.y + p > this.rectDrag.y+this.rectDrag.height) ? this.rectDrag.y + this.rectDrag.height : rectDrag.y + p ;	
			} 
			onTrack( null );
		}
		/*
		* roll the slider over track
		*/
		private function wheellTo(mE:MouseEvent):void
		{
			move(mE.delta*-1);
		}
		/**
		 * 
		 * Get the current percent.
		 * 
		 * @return Number
		 * 
		 * */
		public function get percent() : Number
		{
			var p:Number = 0;
			if (this.posProp && this.bt && this.track){
				var nPos:Number =  this.bt[ this.posProp ] - this.track[ this.posProp ];
				p = Math.min( nPos/tracksize, 1);
				p = Math.max( nPos/tracksize, 0 );
			}
			return p;
		}
		/**
		 * 
		 * Set the percent. 
		 * this action will change the buttom position.
		 * 
		 * @param p Number
		 * 
		 * */
		public function set percent(p:Number) : void
		{
			if (this.posProp && this.bt && this.track){
				var nPos:Number = (p>1) ? 1 : (p<0) ? 0 : p;
				this.bt[ this.posProp ] = tracksize * nPos + this.track[ this.posProp ]; 
				onTrack( null );
			}
		}
		/**
		 * 
		 * Changes the buttom position.
		 * If amount is positive, will increase the position else decrease.
		 * 
		 * @param	amount	Number
		 * 
		 **/
		public function move( amount:Number = 3 ) : void
		{
			var moveToPosition:Number;
			moveToPosition = this.bt[ this.posProp ] + amount;
			this.bt[ this.posProp ] = ( moveToPosition <= this.track[ this.posProp ] ) ? this.track[ this.posProp ] : ( moveToPosition >= this.track[ this.posProp ] + tracksize ) ? this.track[ this.posProp ] + tracksize : moveToPosition;
			onTrack( null );
		}
		/**
		 *	
		 * Disabel events.
		 * 
		 **/
		public function disable():void
		{
			isEnabled = false;
			if ( this.bt && this.bt.stage ){
				this.bt.stage.removeEventListener( Event.MOUSE_LEAVE , offDrag );
				this.bt.stage.removeEventListener(Event.ENTER_FRAME, onTrack);
				this.bt.stage.removeEventListener(MouseEvent.MOUSE_UP, offDrag);
			}
			if(this.bt){	
				this.bt.removeEventListener(MouseEvent.MOUSE_WHEEL, wheellTo );
				this.bt.removeEventListener(MouseEvent.MOUSE_DOWN, onDrag );
			}
			if (track){
				this.track.removeEventListener(MouseEvent.MOUSE_DOWN, dragTo );
				this.track.removeEventListener(MouseEvent.MOUSE_WHEEL, wheellTo );
			}
		}
		/**
		 *	
		 * Enable mouse events.
		 * 
		 **/
		public function enable( ) : void
		{
			isEnabled = true;
			if ( seek ){
				this.track.addEventListener(MouseEvent.MOUSE_DOWN, dragTo, false, 0, true);
			}
			if ( wheel ){
				this.track.addEventListener( MouseEvent.MOUSE_WHEEL, wheellTo, false, 0, true );
				this.bt.addEventListener( MouseEvent.MOUSE_WHEEL, wheellTo, false, 0, true );
			}
			this.bt.addEventListener( MouseEvent.MOUSE_DOWN, onDrag, false, 0, true );
		}
		/**
		 * 
		 * destroy Slider instance
		 * 
		 **/
		public function destroy(e:*=null):void
		{
			disable();
			this.bt = null;
			this.track = null;
			this.rectDrag = null;
			if( this.drag ){
				this.drag.off();
				this.drag.destroy();
				this.drag = null;
			}
		}
	}
}