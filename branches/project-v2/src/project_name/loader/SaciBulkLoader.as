package project_name.loader {
	
	/**
	 * Extensão da BulkLoader com recursos específicos do site
	 * @author Marcelo Miranda Carneiro | Nicholas Almeida
	 * @version 0.1
	 * @since 4/2/2009 22:16
	 * @see http://code.google.com/p/bulk-loader/
	 */

	import br.com.stimuli.loading.BulkLoader;
	import br.com.stimuli.loading.loadingtypes.LoadingItem;
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.utils.setTimeout;
	import saci.events.ListenerManager;
	import saci.interfaces.IDestroyable;
	import saci.util.Logger;
	
	public class SaciBulkLoader extends EventDispatcher implements IDestroyable{
		
		/**
		 * Static stuff (singleton)
		 */
		static public const SHOW_LOADER:String = "show_loader";
		static public const HIDE_LOADER:String = "hide_loader";
		static public var _index:int = 0;
        static private var _globalInstance:SaciBulkLoader;
		
        public static function getInstance():SaciBulkLoader {
			if (_globalInstance == null) {
                _globalInstance = new SaciBulkLoader();
			}
			return _globalInstance;
		}
		
		/**
		 * Cynamic stuff
		 */
		private var _showLoaderIcon:Boolean = false;
		private var _bulk:BulkLoader;
		private var _logLevel:int;
		private var _listenerManager:ListenerManager;
		
        public function SaciBulkLoader():void {
			
			_listenerManager = ListenerManager.getInstance();
			
			_index++;
            _bulk = new BulkLoader("SaciBulkLoader_"+_index);
			logLevel = Logger.logLevel;
			_bulk.logFunction = Logger.log;
			_listenerManager.addEventListener(_bulk, ErrorEvent.ERROR, 	_onLoadError);
			_listenerManager.addEventListener(_bulk, Event.COMPLETE, _onLoadComplete);
		}

		/**
		 * Adiciona um novo item para carregar. Herdado da Bulk
		 * @param	$address
		 * @param	$obj
		 */
		public function add($address:String, $obj:Object):void {
			_bulk.add($address, $obj);
		}
		
		/**
		 * Pega um item de carregamento. Herdado da Bulk
		 * @param	$key
		 * @return
		 */
		public function get($key:*):LoadingItem {
			return _bulk.get($key);
		}
		
		/**
		 * Pega o item carregado. Herdado da Bulk
		 * @param	$key
		 * @return
		 */
		public function getContent($key:*):* {
			return _bulk.getContent($key);
		}
		
		/**
		 * 
		 * @param	$connection
		 */
		public function start($connection:int = -1):void {
			_bulk.start($connection);
			_showLoader();
		}
		
		/**
		 * Handler de erro
		 * @param	e
		 */
		private function _onLoadError(e:ErrorEvent):void {
			_bulk.removeFailedItems();
			_hideLoader();
		}

		/**
		 * Handler de sucesso
		 * @param	e
		 */
		private function _onLoadComplete(e:Event):void {
			_hideLoader();
		}
		
		/**
		 * Mostra o ícone do loader
		 */
		private function _showLoader():void {
			_showLoaderIcon = true;
			setTimeout(_showLoaderTimeout, 300);
		}

		/**
		 * Time out para mostrar o ícone do loader
		 */
		private function _showLoaderTimeout():void {
			if (_showLoaderIcon === true) {
                Logger.log("[SaciBulkLoader.showLoader]");
				dispatchEvent(new Event(SHOW_LOADER));
			}
		}
		
		/**
		 * Esconde o ícone do loader
		 */
		private function _hideLoader():void {
			if (_showLoaderIcon === true) {
                Logger.log("[SaciBulkLoader.hideLoader]");
				dispatchEvent(new Event(HIDE_LOADER));
			}
			_showLoaderIcon = false;
		}
		
		/**
		 * Destroy todos os listeners e para todos os carregamentos ativos
		 * @return
		 */
		public function destroy():Boolean {
			_bulk.pauseAll();
			_bulk.removeAll();
			_bulk.clear();
			_listenerManager.removeAllEventListeners(_bulk);
			_bulk = null;
			return true;
		}
		
		/**
		 * Verifica se já terminou de carregar os itens da fila. Herdado da Bulk
		 */
		public function get isFinished():Boolean { return _bulk.isFinished; }
		
		/**
		 * Verifica se está carregando. Herdado da Bulk
		 */
		public function get isLoading():Boolean { return _bulk.isRunning; }
		
		/**
		 * Instância da Bulk
		 */
		public function get bulk():BulkLoader { return _bulk; }
		
		/**
		 * LogLevel.
		 * @see saci.util.Logger#logLever
		 */
		public function get logLevel():int { return _logLevel; }
		public function set logLevel($value:int):void {
			switch($value) {
				case Logger.LOG_VERBOSE : 
					_logLevel = BulkLoader.LOG_INFO;
					break;
				case Logger.LOG_WARNINGS : 
					_logLevel = BulkLoader.LOG_WARNINGS;
					break;
				case Logger.LOG_ERRORS: 
					_logLevel = BulkLoader.LOG_ERRORS;
					break;
				default:
                    Logger.logWarning("[SaciBulkLoader.logLevel] $value não é válido. Nada será feito");
					return;
			}
			_bulk.logLevel = _logLevel;
		}
	}
}
