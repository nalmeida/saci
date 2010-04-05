package saci.util {
	
	import flash.display.DisplayObjectContainer;
	
	/**
	 * Classe de Log que permite mostrar ou esconder os traces configurando uma a Logger.init
	 * @author Nicholas Almeida
	 * @since 20/1/2009 15:13
	 * @example 
	 * <pre>
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
        public static const LOG_STACK:int = 4;
		
		private static const LINE_STACK:String   = "###%s#################################################";
		private static const LINE_ERROR:String   = "***%s*************************************************";
		private static const LINE_WARNING:String = "---%s-----------------------------------------------";
		
		private static var _logLevel:int;
		private static var _runonce:Object = {stackMsg:false};
		
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
			if (_logLevel >= LOG_ERRORS) 
				traceFunction("\n"+Logger.LINE_ERROR.replace("%s", " ERROR ") + "\n" +str + "\n" + Logger.LINE_ERROR.replace("%s", "*******"));
		}
		
		/**
		 * Faz o log de um stack trace
		 * @param	str	Valor que se deseja fazer log
		 */
		public static function logStack(str:*):void {
			if (_logLevel >= LOG_STACK) {
				if(!_runonce.stackMsg){
					_runonce.stackMsg = true;
					logWarning("Remember: stack traces slows down flash application. Delete \"logStack\" messages or set logLevel value less than 4.");
				}
				try{
					throw new Error(Logger.LINE_STACK.replace("%s", " STACK ") + "\n" +str + "\n" + Logger.LINE_STACK.replace("%s", "#######"));
				}catch(e:Error){
					traceFunction("\n"+e.getStackTrace().replace(/^Error:\s+/i, "").replace(/\t+at.*Logger.*[0-9]+\]/, "")+"\n\n#######\n");
				}
				
			}
		}
		
		/**
		 * Faz o log de um AVISO se logLevel for LOG_WARNINGS ou LOG_VERBOSE.
		 * @param	str	Valor que se deseja fazer log
		 */
		public static function logWarning(str:*):void {
			if (_logLevel >= LOG_WARNINGS) 
				traceFunction("\n"+Logger.LINE_WARNING.replace("%s", " WARNING ") + "\n" +str + "\n" + Logger.LINE_WARNING.replace("%s", "---------"));
		}
		
		/**
		 * Faz o log se logLevel for LOG_WARNINGS ou LOG_VERBOSE.
		 * @param	str	Valor que se deseja fazer log
		 */
		public static function log(str:*):void {
			if (_logLevel >= LOG_VERBOSE) 
				traceFunction(str);
		}
		
		
		// Setters and Getters
		
		static public function get logLevel():int { return _logLevel; }
		
		static public function set logLevel(value:int):void {
			_logLevel = value;
		}
	
	}
	
}