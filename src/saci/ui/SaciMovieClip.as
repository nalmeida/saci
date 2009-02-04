package saci.ui {
	
	import flash.text.*;
	import flash.display.*;
	import flash.events.*;
	import saci.util.Logger;
	
	import saci.interfaces.IDisplayable;
	import saci.interfaces.IDestroyable;
	import saci.interfaces.IRemovableEventDispatcher;
	
	import saci.util.DisplayUtil;
	import saci.events.ListenerManager;
	
	/**
	 * Classe de MovieClip que implementa IDisplayable, IDestroyable e IRemovableEventDispatcher. Também adiciona os métodos de playReverse.
	 * @author Nicholas Almeida
	 * @since 30/1/2009 18:11
	 * @see	http://as3.casalib.org
	 */
	public class SaciMovieClip extends MovieClip implements IDisplayable, IDestroyable, IRemovableEventDispatcher{
		
		protected var _isReversing:Boolean;
		protected var _listenerManager:ListenerManager;
		
		private var _mouseEnabledState:Boolean;
		private var _mouseChildrenState:Boolean;
		private var _enabled:Boolean;
		
		/**
		 * Cria uma nova instancia de SaciMovieClip.
		 */
		public function SaciMovieClip() {
			super();
			mouseChildrenState = mouseEnabledState = true
			_listenerManager = ListenerManager.getInstance();
		}
		
		/**
		 * Habilita o mouseChildren e o mouseEnabled para o estado em que estavam.
		 */
		public function enable():void {
			mouseChildren = mouseChildrenState;
			mouseEnabled = mouseEnabledState;
			_enabled = true;
		}
		
		/**
		 * Desabilita o mouseChildren e mouseEnabled
		 */
		public function disable():void {
			super.mouseChildren = 
			super.mouseEnabled = false;
			_enabled = false;
		}
		
		/**
		 * Retorna se o Objeto está ou não habilidado
		 */
		override public function get enabled():Boolean{
			return _enabled;
		}
		
		/**
		 * Habilita o mouse e exibe o SaciMovieClip.
		 */
		public function show():void {
			enable();
			visible = true;
		}
		
		/**
		 * Desabilita o mouse e esconte o SaciMovieClip.
		 */
		public function hide():void {
			disable();
			visible = false;
		}
		
		/**
		 * Remove todos elementos visuais de dentro do SaciMovieClip. Se for um MovieClip, para ele e remove. Se estiver no ListenerManager, remove todos os eventos associados ao objeto e o remove.
		 * @param	$who	
		 */
		public function removeChilds($who:DisplayObjectContainer):void {
			DisplayUtil.removeChilds($who);
		}
		
		/**
		 * Remove todos os eventos associados ao objeto.
		 */
		public function removeAllEventListeners():void{
			_listenerManager.removeAllEventListeners(this);
		}
		
		/**
		 * Remove todos os filhos, listeners associados e objeto da tela.
		 * @return	true
		 */
		public function destroy():Boolean {
			stop();
			
			removeChilds(this);
			
			_listenerManager.removeAllEventListeners(this);
			_listenerManager = null;
			
			if (parent != null)
				parent.removeChild(this);
			
			return true;
		}
		
	// Código de CasaReversibleMovieClip de CASA framework (http://as3.casalib.org).
	//{ region 
		/**
			Plays the timeline in reverse from current playhead position.
		*/
		public function playReverse():void {
			_playInReverse();
		}
		
		/**
			Sends the playhead to the specified frame on and reverses from that frame.
			
			@param frame: A number representing the frame number, or a string representing the label of the frame, to which the playhead is sent.
		*/
		public function gotoAndReverse(frame:Object):void {
			super.gotoAndStop(frame);
			_playInReverse();
		}
		
		/**
			@exclude
		*/
		override public function gotoAndPlay(frame:Object, scene:String = null):void {
			_stopReversing();
			super.gotoAndPlay(frame, scene);
		}
		
		/**
			@exclude
		*/
		override public function gotoAndStop(frame:Object, scene:String = null):void {
			_stopReversing();
			super.gotoAndStop(frame, scene);
		}
		
		/**
			@exclude
		*/
		override public function play():void {
			_stopReversing();
			super.play();
		}
		
		/**
			@exclude
		*/
		override public function stop():void {
			_stopReversing();
			super.stop();
		}
		
		/**
			Determines if the MovieClip is currently reversing {@code true}, or is stopped or playing {@code false}.
		*/
		public function get reversing():Boolean {
			return this._isReversing;
		}
		
		protected function _stopReversing():void {
			if (!_isReversing) {
				return;
			}
			
			_isReversing = false;
			_listenerManager.removeEventListener(this, Event.ENTER_FRAME, _gotoFrameBefore);
		}
		
		protected function _playInReverse():void {
			if (_isReversing)
				return;
			
			_isReversing = true;
			_listenerManager.addEventListener(this, Event.ENTER_FRAME, _gotoFrameBefore);
		}
		
		protected function _gotoFrameBefore(e:Event):void {
			if (currentFrame == 1) {
				super.gotoAndStop(totalFrames);
			} else {
				prevFrame();
			}
		}
		
	//} endregion
		
		/* SET & GET */
		
		public function set mouseEnabledState(value:Boolean):void{
			_mouseEnabledState = value;
		}
		
		public function get mouseEnabledState():Boolean{
			return _mouseEnabledState;
		}
		
		public function get mouseChildrenState():Boolean{
			return _mouseChildrenState;
		}
		
		public function set mouseChildrenState(value:Boolean):void{
			_mouseChildrenState = value;
		}
		
		
		/* OVERRRIDES */
		
		override public function dispatchEvent(e:Event):Boolean {
			if (hasEventListener(e.type) || e.bubbles) {
				return super.dispatchEvent(e);
			}
			return true;
		}
		
		override public function set mouseEnabled(value:Boolean):void{
			_mouseEnabledState = super.mouseEnabled = value;
		}
		
		override public function set mouseChildren(value:Boolean):void{
			_mouseChildrenState = super.mouseChildren = value;
		}
		
	}
	
}