package saci.interfaces {
	
	import flash.events.IEventDispatcher;
	
	/**
	 * Interface para todos os elementos que precisam remover todos os listeners
	 * @author Nicholas Almeida
	 * @since	22/1/2009 19:14
	 */
	public interface IRemovableEventDispatcher extends IEventDispatcher{
		
		function removeAllEventListeners():void;
		
	}
	
}