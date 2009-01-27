package saci.util {
	
		
	import flash.display.DisplayObjectContainer;
	import saci.ui.SaciSprite;
	import flash.text.TextField;
	
	/**
	 * Classe de Log que permite mostrar ou esconder os traces configurando uma a Logger.init
	 * @author Nicholas Almeida
	 * @since 20/1/2009 15:13
	 * @example 
	 * <pre>
	 * import saci.ui.SaciSprite;
	 * import saci.util.Logger;
	 * 
	 * Logger.init(Logger.LOG_VERBOSE);
	 * Logger.logError("error text");
	 * Logger.logWarning("warning text");
	 * Logger.log("info text");
	 * </pre>
	 * @see saci.ui.Console
	 */
	
	public class Logger {
		
        public static const LOG_ERRORS:int = 1;
        public static const LOG_WARNINGS:int = 2;
        public static const LOG_VERBOSE:int = 3;
		
		private static const LINE_ERROR:String   = "***%s*************************************************";
		private static const LINE_WARNING:String = "---%s-----------------------------------------------";
		
		private static var _logLevel:int;
		
		public static var traceFunction:Function;
		
		/**
		 * Inicia a Logger 
		 * @param	$logLevel Nível de log desejado
		 * @param	$traceFunction	Função que irá receber a os textos do log. Por padrão, trace
		 */
		public static function init($logLevel:int = 0, $traceFunction:Function = null):void {
			Logger.traceFunction = $traceFunction == null ? trace : $traceFunction;
			Logger._logLevel = $logLevel;
		}
		
		/**
		 * Faz o log de um ERRO se logLevel for LOG_ERRORS, LOG_WARNINGS ou LOG_VERBOSE.
		 * @param	str	Valor que se deseja fazer log
		 */
		public static function logError(str:*):void {
			if (_logLevel > 0) 
				traceFunction(Logger.LINE_ERROR.replace("%s", " ERROR ") + "\n" +str + "\n" + Logger.LINE_ERROR.replace("%s", "*******"));
		}
		
		/**
		 * Faz o log de um AVISO se logLevel for LOG_WARNINGS ou LOG_VERBOSE.
		 * @param	str	Valor que se deseja fazer log
		 */
		public static function logWarning(str:*):void {
			if (_logLevel > 1) 
				traceFunction(Logger.LINE_WARNING.replace("%s", " WARNING ") + "\n" +str + "\n" + Logger.LINE_WARNING.replace("%s", "---------"));
		}
		
		/**
		 * Faz o log se logLevel for LOG_WARNINGS ou LOG_VERBOSE.
		 * @param	str	Valor que se deseja fazer log
		 */
		public static function log(str:*):void {
			if (_logLevel > 2) 
				traceFunction(str);
		}
		
		
		// Setters and Getters
		
		static public function get logLevel():int { return _logLevel; }
		
		static public function set logLevel(value:int):void {
			_logLevel = value;
		}
	
	}
	
}