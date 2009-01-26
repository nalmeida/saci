package saci.ui {
	
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import saci.util.Logger;
	
	import saci.interfaces.IDisplayable;
	import saci.interfaces.IDestroyable;
	import saci.interfaces.IRemovableEventDispatcher;
	
	import saci.util.DisplayUtil;
	import saci.events.ListenerManager;
	
	/**
	 * Classe de Sprite que implementa IDisplayable, IDestroyable e IRemovableEventDispatcher
	 * @author Nicholas Almeida
	 * @since 22/1/2009 18:03
	 */
	public class SaciSprite extends Sprite implements IDisplayable, IDestroyable, IRemovableEventDispatcher{
		
		protected var _listenerManager:ListenerManager;
		
		private var _mouseEnabledState:Boolean;
		private var _mouseChildrenState:Boolean;
		private var _enabled:Boolean;
		
		/**
		 * Cria uma nova instancia de SaciSprite.
		 */
		public function SaciSprite() {
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
		public function get enabled():Boolean{
			return _enabled;
		}
		
		/**
		 * Habilita o mouse e exibe o SaciSprite.
		 */
		public function show():void {
			enable();
			visible = true;
		}
		
		/**
		 * Desabilita o mouse e esconte o SaciSprite.
		 */
		public function hide():void {
			disable();
			visible = false;
		}
		
		/**
		 * Remove todos elementos visuais de dentro do SaciSprite. Se for um MovieClip, para ele e remove. Se estiver no ListenerManager, remove todos os eventos associados ao objeto e o remove.
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
			
			removeChilds(this);
			
			_listenerManager.removeAllEventListeners(this);
			_listenerManager = null;
			
			if (parent != null)
				parent.removeChild(this);
			
			return true;
		}
		
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