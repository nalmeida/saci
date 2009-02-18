package br.com.project.data {
	
	import br.com.project.loader.SaciBulkLoader;
	import br.com.project.sessions.Base;
	import br.com.project.sessions.collections.DependencyItemVOCollection;
	import br.com.project.sessions.SessionManager;
	import br.com.project.sessions.vo.DependencyItemVO;
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import saci.events.ListenerManager;
	import br.com.stimuli.loading.BulkLoader;
	import saci.util.Logger;
	
	/**
	 * ...
	 * @author Nicholas Almeida
	 */
	public class Config extends EventDispatcher{
		
		static private const XML_LOADER_ID:String = "config-xml";
		static private var _instance:Config;
		static private var _allowInstance:Boolean;
		
		static public function getInstance():Config {
			if (Config._instance == null) {
				Config._allowInstance = true;
				Config._instance = new Config();
				Config._allowInstance = false;
				
				// construtora
				Config._instance._listenerManager = ListenerManager.getInstance();
				Config._instance._sessionManager = SessionManager.getInstance();
				Config._instance._base = Base.getInstance();
				Config._instance._loader = SaciBulkLoader.getInstance();
			}
			return Config._instance;
		}
		
		private var _base:Base;
		private var _sessionManager:SessionManager;
		private var _listenerManager:ListenerManager;
		private var _loader:SaciBulkLoader;
		
		private var _mockXML:XML;
		private var _xml:XML;
		private var _shortcuts:Object = { };
		
		public function Config():void {
			if (Config._allowInstance !== true) {
				throw new Error("Use the singleton Config.getInstance() instead of new Config().");
			}
		}
		
		/**
		 * Começa carregamento do xml com as configurações das seções.
		 * @param	$configXMLUrl
		 * @param	$mock
		 */
		public function loadDataFromXML($configXMLUrl:String, $mock:XML = null):void {
			_mockXML = $mock;
			
			_loader.add($configXMLUrl, { id:XML_LOADER_ID, preventCache:true, maxTries:3 } );
			_listenerManager.addEventListener(loader.bulk.get(XML_LOADER_ID), Event.COMPLETE, _onCompleteXMLLoad);
			_listenerManager.addEventListener(loader.bulk.get(XML_LOADER_ID), ErrorEvent.ERROR, _onErrorXMLLoad);
			_loader.start();
			
			//TODOFBIZ: --- [Config.loadDataFromXML] USE MOCK FLAG
		}
		
		/**
		 * Handler de sucesso no carregamento.
		 * @private
		 */
		private function _onCompleteXMLLoad(e:Event):void{
			_listenerManager.removeEventListener(loader.bulk.get(XML_LOADER_ID), Event.COMPLETE, _onCompleteXMLLoad);
			_listenerManager.removeEventListener(loader.bulk.get(XML_LOADER_ID), ErrorEvent.ERROR, _onErrorXMLLoad);
			_xml = loader.bulk.getXML(XML_LOADER_ID);

			Logger.log("[Config._onCompleteXMLLoad] loaded XML:\n" + _xml);
			
			_buildXML(_xml);
		}

		/**
		 * Handler de erro no carregamento. Usa o "xml fake" para preencher os dados.
		 * @private
		 */
		private function _onErrorXMLLoad(e:ErrorEvent):void {
			Logger.log("[Config._onErrorXMLLoad] Error loading XML, using mock-up xml:\n" + _mockXML);
			_listenerManager.removeEventListener(loader.bulk.get(XML_LOADER_ID), Event.COMPLETE, _onCompleteXMLLoad);
			_listenerManager.removeEventListener(loader.bulk.get(XML_LOADER_ID), ErrorEvent.ERROR, _onErrorXMLLoad);
			
			/**
			 * No caso de erro, carrega o xml fake
			 */
			if (_mockXML != null) {
				_buildXML(_mockXML);
			}
		}
		
		/**
		 * Lê os dados do XML e instancia as seções.
		 * @param	$xml
		 */
		protected function _buildXML($xml:XML):void {
			
			if ($xml == null) {
				throw new Error("[Config._parseXML] ERROR: XML não está definido.");
				return;
			}
			_shortcuts = ShortcutParser.parseXML(xml.global[0] as XML);			
			_base.parseXML($xml.base[0] as XML, _shortcuts);
			_sessionManager.parseXML($xml.sessions[0] as XML, _shortcuts);
			
			_listenerManager.addEventListener(_base, Event.COMPLETE, _onComplete);
			_listenerManager.addEventListener(_base, ErrorEvent.ERROR, _onError);
		}
		
		private function _onComplete($e:Event):void{
			dispatchEvent($e);
		}
		private function _onError($e:ErrorEvent):void{
			Logger.logError("[Config._onError] Erro ao construir as áreas: "+$e);
			dispatchEvent($e);
		}
		
		//{ getters / setters
		
		/**
		 * Instância global da SaciBulkLoader
		 */
		public function get loader():SaciBulkLoader { return _loader; }
		
		/**
		 * XML original com as configurações das seções.
		 */
		public function get xml():XML { return _xml; }
		
		/**
		 * XML fake para usar em caso de erro / teste.
		 */
		public function get mockXML():XML { return _mockXML; }
		//}
		
	}
	
}