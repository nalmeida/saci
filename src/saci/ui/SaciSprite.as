﻿package saci.ui {
	
	import flash.display.*;
	import flash.text.*;
	import flash.events.*;
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
		
		private var _mouseEnabledState:Boolean = true;
		private var _mouseChildrenState:Boolean = true;
		private var _enabled:Boolean = true;
		
		/**
		 * Cria uma nova instancia de SaciSprite.
		 */
		public function SaciSprite() {
			super();
			_mouseChildrenState = _mouseEnabledState = true
			_listenerManager = ListenerManager.getInstance();
		}
		
		/**
		 * Habilita o mouseChildren e o mouseEnabled para o estado em que estavam.
		 */
		public function enable():void {
			mouseChildren = _mouseChildrenState;
			mouseEnabled = _mouseEnabledState;
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