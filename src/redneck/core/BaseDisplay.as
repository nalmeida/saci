/**
*
*	@author igor almeida
*	@version 1
*   
**/
package redneck.core
{
	import flash.display.*;
	import redneck.events.*;
	import flash.events.Event;

	public class BaseDisplay extends Sprite implements IDisplay, IDisposable
	{
		public var isShow : Boolean;

		/*show callbacks*/
		public var onShow:Function;
		public var onShowArgs:* = invalid_hash_param;

		/*hide callbacks*/
		public var onHide:Function;
		public var onHideArgs:* = invalid_hash_param;

		/*onFinishShowing callbakcs*/
		public var onFinishShowing:Function;
		public var onFinishShowingArgs:* = invalid_hash_param;

		/*onFinishHiding callbacks*/
		public var onFinishHiding:Function;
		public var onFinishHidingArgs:* = invalid_hash_param;

		private const invalid_hash_param : String = "%%redneck_invalid_hash%%";

		public function BaseDisplay( )
		{
			super( );
		}
		/**
		 * 
		 *	Start showing this instance
		 *	
		 *	@see onShow
		 *	@see onShow
		 *	
		 * */
		public function show( ...rest ):void
		{
			callback( onShow, onShowArgs );
			dispatchEvent( new DisplayEvent( DisplayEvent.ON_SHOW ) );
		}
		/**
		 * 
		 * Start hiding this instance
		 *	
		 * @see onHide
		 * @see onHideArgs
		 * 
		 * */
		public function hide( ...rest ):void
		{
			callback( onHide, onHideArgs );
			dispatchEvent( new DisplayEvent( DisplayEvent.ON_HIDE ) );
		}
		/**
		* 
		*	Must be called when ths <code>show</code> finishes.
		*	
		*	@see onFinishShow
		*	@see onFinishShowArgs
		* 
		**/
		public function finishShowing( ...rest ):void
		{
			isShow = true;
			callback( onFinishShowing, onFinishShowingArgs );
			dispatchEvent( new DisplayEvent( DisplayEvent.ON_FINISH_SHOWING ) );
		}
		/**
		*	
		*	Must be called when ths <code>hide</code> finishes.
		*	
		*	@see onFinishShow
		*	@see onFinishShowArgs
		*	
		**/
		public function finishHiding( ...rest ):void
		{
			isShow = false;
			callback( onFinishHiding, onFinishHidingArgs );
			dispatchEvent( new DisplayEvent( DisplayEvent.ON_FINISH_HIDING ) );
		}
		/**
		*	
		* Clean the childs
		*	
		**/
		public function dispose( ...rest ):void
		{
			var child  :*
			if (this.numChildren>0){
				new Array( this.numChildren-1 ).forEach( function(item:*,...rest):void{
					child = this.hasOwnProperty("getChildAt") ? this.getChildAt(item) : null;
					if ( child is IDisposable ){
						item.dispose();
					}
				} );
			}
			child = null;
			dispatchEvent( new DisplayEvent( DisplayEvent.ON_DISPOSE ) );
		}
		/**
		*	@private
		*	
		*	Runs the desired callback if it exists
		*	
		*	@param	func	Function
		*	@param 	args	*
		*	
		*/
		private function callback( func:Function, args:* ):void
		{
			if( func!=null ){
				if( args ==  invalid_hash_param){
					func( );
				}
				else{
					func.apply( null, args );
				}
			}
		}
		/**
		*	
		*	Override to remochild to remove only if <code>contains</code> this <code>child</code>	
		*	
		*	@param	child	DisplayObject
		*	@return	DisplayObject
		*	
		**/
		public override function removeChild(child:DisplayObject):DisplayObject {
			if ( child && contains(child) ) {
				return super.removeChild(child);
			}
			return null;
		}
	}
}