package saci.events {
	
	import flash.events.IEventDispatcher;
	import flash.utils.Dictionary;
	import saci.interfaces.IDestroyable;
	import saci.events.EventInfoVO;
	import saci.ui.SaciSprite;
	import saci.util.Logger;
	
	/**
	 * Classe estática (singleton) para controlar (adicionar e remover) eventos
	 * Agradecimento CASA framework (http://as3.casalib.org) pela função básica.
	 * @author Nicholas Almeida
	 * @since 22/1/2009 17:58
	 */
	public class ListenerManager implements IDestroyable{
		
		protected static var _arrEvents:Array;
		protected static var _arrLength:int;
		
		private static var _instance:ListenerManager;
		private static var _allowInstance:Boolean;
		
		/**
		 * Classe dinâmica não deve ser usada. Usar: ListenerManager.getInstance() para obter seu valor estático.
		 */
		public function ListenerManager():void {
			if (ListenerManager._allowInstance !== true) {
				throw new Error("Use the singleton ListenerManager.getInstance() instead of new ListenerManager().");
			}
		}
		
		/**
		 * Retorna a instância estática de ListenerManager
		 * @return	ListenerManager
		 */
		public static function getInstance():ListenerManager {
			if (ListenerManager._instance == null) {
				ListenerManager._allowInstance = true;
				ListenerManager._instance = new ListenerManager();
				ListenerManager._arrEvents = [];
				ListenerManager._allowInstance = false;
			}
			return ListenerManager._instance;
		}
		
		/**
		 * Adiciona o evento ao objeto e coloca ambos como um EventInfoVO no array que controla todos os eventos.
		 * @param	$dispatcher	Objeto que está despachando o evento
		 * @param	$type	Tipo do evento
		 * @param	$listener	Função que escuta o evento
		 * @param	$useCapture
		 * @param	$priority
		 * @param	$useWeakReference
		 */
		public function addEventListener($dispatcher:IEventDispatcher, $type:String, $listener:Function, $useCapture:Boolean = false, $priority:int = 0, $useWeakReference:Boolean = false):void {
			var tmpEvent:EventInfoVO = new EventInfoVO($dispatcher, $type, $listener, $useCapture, $priority, $useWeakReference);
			
			$dispatcher.addEventListener(tmpEvent.type, tmpEvent.listener, tmpEvent.useCapture, tmpEvent.priority, tmpEvent.useWeakReference);
			ListenerManager._arrEvents.push(tmpEvent);
		}
		
		/**
		 * Remove evento do objeto e remove seu EventInfoVO do array que controla todos os eventos.
		 * @param	$dispatcher	Objeto que está despachando o evento
		 * @param	$type	Tipo do evento
		 * @param	$listener	Função que escuta o evento
		 * @param	$useCapture
		 */
		public function removeEventListener($dispatcher:IEventDispatcher, $type:String, $listener:Function, $useCapture:Boolean = false):void {
			var tmpEvent:EventInfoVO = new EventInfoVO($dispatcher, $type, $listener, $useCapture);
			
			var eventsFound:int = 0;
			
			_arrLength = ListenerManager._arrEvents.length;
			while (_arrLength--) {
				if (ListenerManager._arrEvents[_arrLength].equals(tmpEvent)) {
					$dispatcher.removeEventListener(tmpEvent.type, tmpEvent.listener, tmpEvent.useCapture);
					ListenerManager._arrEvents.splice(_arrLength, 1);
					eventsFound++;
				}
			}
			if(eventsFound < 1) Logger.logWarning("[ListenerManager.removeEventListener]\nEvent type: \"" + tmpEvent.type + "\" listener: " + tmpEvent.listener + " for " + tmpEvent.dispatcher + " NOT FOUND.");
		}
		
		/**
		 * Retorna se o objeto está ou não no array que controla os eventos.
		 * @param	$dispatcher	Objeto que está despachando o evento
		 * @return	true se encontrar
		 */
		public function has($dispatcher:IEventDispatcher):Boolean {
			_arrLength = ListenerManager._arrEvents.length;
			while (_arrLength--) {
				if (ListenerManager._arrEvents[_arrLength].dispatcher === $dispatcher) {
					return true;
				}
			}
			return false;
		}
		
		/**
		 * Remove todos os eventos associados a um obejeto.
		 * @param	$dispatcher	Objeto que está despachando o evento
		 * @return
		 */
		public function removeAllEventListeners($dispatcher:IEventDispatcher):void {
			_arrLength = ListenerManager._arrEvents.length;
			while (_arrLength--) {
				var item:EventInfoVO = ListenerManager._arrEvents[_arrLength];
				if (item.dispatcher === $dispatcher) {
					item.dispatcher.removeEventListener(item.type, item.listener, item.useCapture);
				}
			}
		}
		
		/**
		 * Remove todos os eventos associados a todos os objetos do array e anula as propriedades estáticas.
		 * @return	true
		 */
		public function destroy():Boolean {
			
			_arrLength = ListenerManager._arrEvents.length;
			while (_arrLength--) {
				var item:EventInfoVO = ListenerManager._arrEvents[_arrLength];
				item.dispatcher.removeEventListener(item.type, item.listener, item.useCapture);
			}
			ListenerManager._arrEvents = null;
			ListenerManager._allowInstance = false;
			ListenerManager._instance == null;
			
			return true;
		}
		
	}
	
}
