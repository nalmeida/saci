package saci.util {
	
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.MovieClip;
	import saci.events.ListenerManager;
	import saci.interfaces.IDestroyable;
	
	/**
	 * Classe com utilidades para elementos visuais como SaciSprite, Sprite, Movieclip, etc.
	 * @author Nicholas Almeida
	 * @since	22/1/2009 19:37
	 */
	public class DisplayUtil {
		
		/**
		 * Remove todos elementos visuais de dentro do SaciSprite. Se for um MovieClip, para ele e remove. Se estiver no ListenerManager, remove todos os eventos associados ao objeto e o remove.
		 * Agradecimento a Igor Almeida (redneck framework) (http://ialmeida.com) pela função básica.
		 * @param	$who	
		 * @see http://ialmeida.com
		 */
		public static function removeChilds($who:DisplayObjectContainer):void {
			var _listenerManager:ListenerManager = ListenerManager.getInstance();
			if (!$who.numChildren ) return; 
			var count:int = $who.numChildren;
			while( count-- ){
				var obj:DisplayObject = $who.getChildAt(count);
				if (obj == null) {
					continue;
				}
				if (obj is MovieClip && MovieClip(obj).totalFrames>1 ){
					MovieClip(obj).stop();
				} else if( (obj is DisplayObjectContainer) ) {
					removeChilds( DisplayObjectContainer( obj )  );
				}
				
				if (obj is IDestroyable) { // Se o objeto tem o método destroy.
					(obj as IDestroyable).destroy();
				} else {
					if (_listenerManager.has(obj)){ // Se está listado na ListenerManager
						_listenerManager.removeAllEventListeners(obj);
					}
					$who.removeChild(obj);
				}
			}	
		}
		
	}
	
}