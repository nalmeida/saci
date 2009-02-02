package saci.util {
	
	import flash.net.navigateToURL;
    import flash.net.URLRequest;
	import flash.utils.setTimeout;
	import flash.external.ExternalInterface;
	import saci.util.DocumentUtil;
	
	/**
	 * Classe para chamar URL's externas ou javascript.
	 * @author Nicholas Almeida
	 * @since 2/2/2009 15:23
	 * @example
	 * <pre>
	 * 		URL.call("http://www.google.com", "_blank");
	 * 		URL.javascript("alert", 123);
	 * 		URL.analytics("/flash/");
	 * </pre>
	 */
	public class URL {
		
		private static var _arrURLQueue:Array = [];
		private static var _trackerFunction:String = "pageTracker._trackPageview";
		
		/**
		 * Chama uma URL
		 * @param	$url URL
		 * @param	$target	target
		 */
        public static function call($url:String, $target:String = "_self"):void {
			_arrURLQueue.push( { url: $url, target: $target } );
			_start();
        }
		
		/**
		 * Chama um javascript
		 * @param	$javascriptFunction Função javascript
		 * @param	... statements	Parâmetros
		 */
		public static function javascript($javascriptFunction:String, ... statements):void {
			_arrURLQueue.push( { js: $javascriptFunction, args: statements } );
			_start();
		}
		
		/**
		 * Chama a função javascript definida pela trackerFunction. Por padrão "pageTracker._trackPageview"
		 * @param	$analyticsString O que se deseja marcar no ana;ytics
		 */
		public static function analytics($analyticsString:String):void {
			javascript(trackerFunction, ($analyticsString));
		}
		
		/**
		 * Executa a fila de chamadas a cada 300 milisegundos
		 */
		private static function _run():void {
			
			var j:String = _arrURLQueue[0].js;
			var a:Array = _arrURLQueue[0].args;
			
			var u:String = _arrURLQueue[0].url;
			var t:String = _arrURLQueue[0].target;
			
			var args:Array = [];
			
			if (DocumentUtil.isWeb()) {
				if (j) { // Javascript request
					if (ExternalInterface.available) {
						args[args.length] = j;
						var i:int;
						for (i = 0; i < a.length; i++) {
							args[args.length] = a[i];
						}
						ExternalInterface.call.apply(null, args);
					} else {
						Logger.logError("[URL._run] ExternalInterface not avaliable. " + j + "(" + a + ")");
					}
				} else { // URL request
					navigateToURL(new URLRequest(u), t);
				}
			} else {
				if (j) {
					if (j === trackerFunction) {
						a.splice(0, 0, "\"");
						a[a.length] = "\"";
						a = [a.join("")];
					}
					Logger.log("[URL._run] Running LOCAL. Javascript" + j + "(" + a + ")");
				} else {
					Logger.log("[URL._run] Running LOCAL. URL: \"" + u + "\" target: \"" + t + "\"");					
				}
			}
			_arrURLQueue.shift();
		}
		
		/**
		 * Inicia a fila
		 */
		private static function _start():void {
			setTimeout(_run, _arrURLQueue.length * 300);
		}
		
		static public function get trackerFunction():String { return _trackerFunction; }
		
		static public function set trackerFunction(value:String):void {
			_trackerFunction = value;
			Logger.log("[URL.trackerFunction] _trackerFunction: " + _trackerFunction);
		}
		
	}
	
}