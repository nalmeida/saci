package saci.interfaces {
	
	import flash.display.DisplayObjectContainer;
	
	/**
	 * Interface para todos os elementos de tela.
	 * @author Nicholas Almeida
	 * @since	22/1/2009 19:13
	 */
	public interface IDisplayable {
		
		function removeChilds($who:DisplayObjectContainer):void
		
		function enable():void
		function disable():void
		
		function show():void
		function hide():void
		
		function get enabled():Boolean
		
		function get mouseEnabledState():Boolean
		function set mouseEnabledState(value:Boolean):void 
		
		function get mouseChildrenState():Boolean
		function set mouseChildrenState(value:Boolean):void 
		
	}
	
}