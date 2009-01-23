package saci.events {
	
	import flash.events.IEventDispatcher;
	
	/**
	 * VO (Value Object) que contém informações sobre um evento.
	 * @author Nicholas Almeida
	 * @since 22/1/2009 17:55
	 */
	public class EventInfoVO {
	
		public var dispatcher:IEventDispatcher;
		public var type:String;
		public var listener:Function;
		public var useCapture:Boolean;
		public var priority:int;
		public var useWeakReference:Boolean;
		
		/**
		 * Cria um VO com informações sobre um evento
		 * @param	$dispatcher	Objeto que está despachando o evento
		 * @param	$type	Tipo do evento
		 * @param	$listener	Função que escuta o evento
		 * @param	$useCapture
		 * @param	$priority
		 * @param	$useWeakReference
		 */
		public function EventInfoVO($dispatcher:IEventDispatcher, $type:String, $listener:Function, $useCapture:Boolean, $priority:int = 0, $useWeakReference:Boolean = false):void {
			dispatcher = $dispatcher;
			type = $type;
			listener = $listener;
			useCapture = $useCapture;
			priority = $priority;
			useWeakReference = $useWeakReference;
		}
		
		/**
		 * Retorna true ou false se o evento recebido é idêntico ao próprio evento quando comparados: dispatcher, type, listener e useCapture
		 * @param	$eventInfo
		 * @return	
		 */
		public function equals($eventInfo:EventInfoVO):Boolean {
			return (dispatcher === $eventInfo.dispatcher && type === $eventInfo.type && listener === $eventInfo.listener && useCapture === $eventInfo.useCapture);
		}
		
	}
	
}