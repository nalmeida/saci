package saci.util {
	
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.Stage;
	import flash.display.StageScaleMode;
	import flash.display.StageAlign;
	import flash.events.Event;
	import flash.display.StageDisplayState;
	
	/**
	 * Classe estática que gerencia o root e o stage da documentClass.
	 * @author Nicholas Almeida
	 * @since	23/1/2009 17:19
	 * @example
	 
			listenerManager = ListenerManager.getInstance();
			
			DocumentUtil.setDocument(this);
			trace("DocumentUtil.isWeb: " + DocumentUtil.isWeb());
			
			listenerManager.addEventListener(DocumentUtil.stage, Event.RESIZE, _onResizeStage);
			
			...
			
			private function _onResizeStage(e:Event):void{
				trace(DocumentUtil.halfWidth);
				trace(DocumentUtil.halfHeight);
			}
			
	 */
	public class DocumentUtil {
		
		public static var documentClass:DisplayObjectContainer;
		
		public static var stage:Stage;
		public static var root:DisplayObject;
		
		public static var minWidth:Number = -1;
		public static var maxWidth:Number = -1;
		public static var minHeight:Number = -1;
		public static var maxHeight:Number = -1;
		
		/**
		 * Atribui a documentClass, root stage a DocumentUtil. Também atribui como padrão o scaleMode com o "noScale" e align como "topLeft".
		 * @param	$documentClass	Classe principal, geralmente a Main
		 */
		public static function setDocument($documentClass:DisplayObjectContainer):void {
			if (DocumentUtil.documentClass != null) {
				throw new Error("[DocumentUtil.setDocument] DocumentUtil.setDocument already set. You CAN NOT set it twice!");
			}
			
			DocumentUtil.documentClass = $documentClass;
			DocumentUtil.stage = documentClass.stage;
			DocumentUtil.root = documentClass.root;
			
			DocumentUtil.stage.scaleMode = StageScaleMode.NO_SCALE;
			DocumentUtil.stage.align = StageAlign.TOP_LEFT;
		}
		
		/**
		 * Retorna se o SWF está rodando sob o protocolo http.
		 * @return true se estiver rodando sob o protocolo http.
		 */
		public static function isWeb():Boolean {
			return DocumentUtil.stage.loaderInfo.url.substr(0, 4) == 'http';
		}
		
		/**
		 * Retorna uma variável passada por flashvars para o SWF.
		 * @param	$variable	Nome da variável
		 * @return	variável como string ou null
		 */
		public static function getFlashVar($variable:String):String {
			return DocumentUtil.stage.loaderInfo.parameters[$variable];
		}
		
		/**
		* Fullscreen
		*/
		public static function toggleFullscreen():void
		{
			switch (stage.displayState)
			{
				case StageDisplayState.NORMAL:
					stage.displayState = StageDisplayState.FULL_SCREEN;
					break;
				
				case StageDisplayState.FULL_SCREEN:
					stage.displayState = StageDisplayState.NORMAL;
					break;
				
			}
		}
		
		/**
		 * Retorna a largura do stage. Se tiver um maxWidth e o stage.width for maior, retorna o maxWidth. Se tiver um minWidth e o stage.width for menor, retorna o minWidth.
		 */
		public static function get width():Number {
			var n:Number = DocumentUtil.stage.stageWidth;
			if (DocumentUtil.maxWidth != -1) {
				if (n > DocumentUtil.maxWidth) n = DocumentUtil.maxWidth;
			}
			if (DocumentUtil.minWidth != -1) {
				if (n < DocumentUtil.minWidth) n = DocumentUtil.minWidth;
			}
			return n;
		}
		
		/**
		 * Retorna a metade de width.
		 */
		public static function get halfWidth():Number {
			return DocumentUtil.width * .5;
		}
		
		/**
		 * Retorna a altura do stage. Se tiver um maxHeight e o stage.height for maior, retorna o maxHeight. Se tiver um minHeight e o stage.height for menor, retorna o minHeight
		 */
		public static function get height():Number {
			var n:Number = DocumentUtil.stage.stageHeight;
			if (DocumentUtil.maxHeight != -1) {
				if (n > DocumentUtil.maxHeight) n = DocumentUtil.maxHeight;
			}
			if (DocumentUtil.minHeight != -1) {
				if (n < DocumentUtil.minHeight) n = DocumentUtil.minHeight;
			}
			return n;
		}	
		
		/**
		 * Retorna a metade de height.
		 */
		public static function get halfHeight():Number {
			return DocumentUtil.height * .5;
		}
	}
	
}