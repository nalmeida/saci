package saci.util {
	
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.MovieClip;
	import saci.events.ListenerManager;
	import saci.interfaces.IDestroyable;
	import flash.geom.Rectangle;
	
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
		
		/**
		 * Para todos os movieclips e seus filhos.
		 * @param	$who
		 */
		public static function stopAllChilds($who:DisplayObjectContainer):void {
			if (!$who.numChildren ) return; 
			var count:int = $who.numChildren;
			while( count-- ){
				var obj:DisplayObject = $who.getChildAt(count);
				if (obj == null) {
					continue;
				}
				if (obj is MovieClip && MovieClip(obj).totalFrames>1 ){
					MovieClip(obj).stop();
				} 
				if( (obj is DisplayObjectContainer) ) {
					stopAllChilds( DisplayObjectContainer( obj )  );
				}
			}	
		}
		
		/**
		 * Dá play em todos os movieclips e seus filhos.
		 * @param	$who
		 */
		public static function playAllChilds($who:DisplayObjectContainer):void {
			if (!$who.numChildren ) return; 
			var count:int = $who.numChildren;
			while( count-- ){
				var obj:DisplayObject = $who.getChildAt(count);
				if (obj == null) {
					continue;
				}
				if (obj is MovieClip && MovieClip(obj).totalFrames>1 ){
					MovieClip(obj).play();
				} 
				if( (obj is DisplayObjectContainer) ) {
					playAllChilds( DisplayObjectContainer( obj )  );
				}
			}	
		}
		
		public static function swapToHightestIndex($scope:DisplayObjectContainer, $who:DisplayObject):uint {
			
			var highest:uint = 0;
			
			for (var i:uint = 0; i < $scope.numChildren ; i++) {
				var mc:* = $scope.getChildAt(i);
				
				if ($scope.getChildIndex(mc) > highest) highest = $scope.getChildIndex(mc);
			}
			
			if ($scope.getChildIndex($who) < highest) {
				$scope.swapChildrenAt($scope.getChildIndex($who), highest);
			}
			
			return highest;
		}
		
		/**
		 * Faz um "scale" proporcional de um objeto
		 * @param	$object
		 * @param	$width
		 * @param	$height
		 * @param	$proportion "smaller" mantém a menor proporção, "bigger" mantém a maior proporção
		 */
		public static function scaleProportionally($object:DisplayObject, $width:Number, $height:Number, $proportion:String = "smaller"):void {
			
			var proportion:String = $proportion;
			var object:DisplayObject = $object;
			
			var objectAspectRatio:Number;
			var holderAspectRatio:Number;
			var objectWidth:Number;
			var objectHeight:Number;
			
			objectWidth = $width;
			objectHeight = $height;
			
			objectAspectRatio = object.width / object.height;
			holderAspectRatio = objectWidth / objectHeight;
			
			if(proportion == "smaller") {
				if ( holderAspectRatio >= objectAspectRatio ) {
					object.width = (objectHeight * objectAspectRatio);
					object.height = objectHeight;
				} else {
					object.width = objectWidth;
					object.height = (objectWidth / objectAspectRatio)				
				}
			} else if (proportion == "bigger") {
				if ( holderAspectRatio >= objectAspectRatio ) {
					object.width = objectWidth;
					object.height = (objectWidth / objectAspectRatio)				
				} else {
					object.width = (objectHeight * objectAspectRatio);
					object.height = objectHeight;
				}
			}
		}
		
		/**
		 * duplicateDisplayObject
		 * creates a duplicate of the DisplayObject passed. similar to duplicateMovieClip in AVM1.
		 * @param target the display object to duplicate
		 * @param autoAdd if true, adds the duplicate to the display list in which target was located
		 * @return a duplicate instance of target
		 * @see http://www.kirupa.com/forum/showthread.php?p=1939827
		 */
		public static function duplicateDisplayObject(target:DisplayObject):DisplayObject {
			// create duplicate
			var targetClass:Class = Object(target).constructor;
			var duplicate:DisplayObject = new targetClass();
			
			// duplicate properties
			duplicate.transform = target.transform;
			duplicate.filters = target.filters;
			duplicate.cacheAsBitmap = target.cacheAsBitmap;
			duplicate.opaqueBackground = target.opaqueBackground;
			if (target.scale9Grid) {
				var rect:Rectangle = target.scale9Grid;
				// WAS Flash 9 bug where returned scale9Grid is 20x larger than assigned
				// rect.x /= 20, rect.y /= 20, rect.width /= 20, rect.height /= 20;
				duplicate.scale9Grid = rect;
			}
			
			return duplicate;
		}
		
	}
	
}