package br.com.project.data {
	
	import br.com.project.loader.SaciBulkLoader;
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
		
		private static var _instance:Config;
		private static var _allowInstance:Boolean;
		private static const XML_LOADER_ID:String = "config-xml";
		
		private var _sessionManager:SessionManager;
		private var _serverData:ServerData;
		private var _listenerManager:ListenerManager;
		private var _loader:SaciBulkLoader;
		private var _mockXml:XML;
		private var _xml:XML;
		private var _isFinished:Boolean = false;
		private var _shortcuts:Object = {};
		
		public static function getInstance():Config {
			if (Config._instance == null) {
				Config._allowInstance = true;
				Config._instance = new Config();
				Config._allowInstance = false;
				
				// construtora
				Config._instance._serverData = ServerData.getInstance();
				Config._instance._listenerManager = ListenerManager.getInstance();
				Config._instance._sessionManager = SessionManager.getInstance();
			}
			return Config._instance;
		}
		
		public function Config():void {
			if (Config._allowInstance !== true) {
				throw new Error("Use the singleton Config.getInstance() instead of new Config().");
			}
		}
		
		/**
		 * Começa carregamento do xml com as configurações das seções.
		 * @param	$configXmlUrl
		 * @param	$mock
		 */
		public function load($configXmlUrl:String, $mock:XML = null):void {
			_mockXml = $mock;
			
            _loader = SaciBulkLoader.getInstance();
			_loader.add($configXmlUrl, { id:XML_LOADER_ID, preventCache:true } );
			_listenerManager.addEventListener(loader.bulk.get(XML_LOADER_ID), Event.COMPLETE, _onCompleteXmlLoad);
			_listenerManager.addEventListener(loader.bulk.get(XML_LOADER_ID), ErrorEvent.ERROR, _onErrorXmlLoad);
			_loader.start();
		}
		
		/**
		 * Handler de sucesso no carregamento.
		 * @param	e
		 */
		private function _onCompleteXmlLoad(e:Event):void{
			_listenerManager.removeAllEventListeners(loader.bulk.get(XML_LOADER_ID));
			_xml = loader.bulk.getXML(XML_LOADER_ID);

			Logger.log("[Config._onCompleteXmlLoad] loaded XML:\n" + _xml);
			
			_parseXml(_xml);
		}

		/**
		 * Handler de erro no carregamento. Usa o "xml fake" para preencher os dados.
		 * @param	e
		 */
		private function _onErrorXmlLoad(e:ErrorEvent):void {
			Logger.log("[Config._onErrorXmlLoad] Error loading XML, using mock up xml:\n" + _xml);
			_listenerManager.removeAllEventListeners(loader.bulk.get(XML_LOADER_ID));
			
			/**
			 * No caso de erro, carrega o xml fake
			 */
			if (_mockXml != null) {
				_parseXml(_mockXml);
			}
		}
		
		/**
		 * Lê os dados do XML e instancia as seções.
		 * @param	$xml
		 */
		protected function _parseXml($xml:XML):void {
			
			if ($xml == null) {
				throw new Error("[Config._parseXml] ERROR: XML não está definido.");
				return;
			}
			
			_xml = $xml;
			
			/**
			 * gera os "shortcuts"
			 */
			var i:int;
			for (i = 0; i < xml.global[0].children().length(); i++) {
				_shortcuts[xml.global[0].children()[i].name()] = xml.global[0].children()[i].@value;
				if (_serverData.get(xml.global[0].children()[i].name()) != null) {
					Logger.logWarning("O xml \"" + _loader.bulk.get(XML_LOADER_ID).url.url + "\" contém o atributo global \"" + xml.global[0].children()[i].name() + "\" que irá sobrepor o existente na ServerData.");
				}
			}
			
			_parseDependencies();
		}
		
		/**
		 * Lê o nó de cada seção para instancia-los recursivamente
		 * @param	$xml
		 * @param	$parent
		 */
		protected function _parseDependencies():void {
			
			if (xml.base.dependencies.item.length() === 0) {
				Logger.log("[Config._parseDependencies] Nenhuma dependência encontrada");
				_onCompleteDependenciesLoad();
				return;
			}
			
			var dependencies:DependencyItemVOCollection = new DependencyItemVOCollection();
			var dependencyXml:XML;
			var dependency:DependencyItemVO;
			var i:int;
			
			for (i = 0; i < xml.base.dependencies.item.length(); i++) {
				dependencyXml = xml.base.dependencies.item[i];
				
				dependencies.addItem(new DependencyItemVO(
					_serverData.parseString(_serverData.parseString(dependencyXml.@id.toString(), _shortcuts)),
					_serverData.parseString(_serverData.parseString(dependencyXml.@value.toString(), _shortcuts)),
					_serverData.parseString(_serverData.parseString(dependencyXml.@type.toString(), _shortcuts)),
					int(_serverData.parseString(_serverData.parseString(dependencyXml.@weight.toString(), _shortcuts))),
					_serverData.parseString(_serverData.parseString(dependencyXml.@version.toString(), _shortcuts))
				));
			}
			
			for (i = 0; i < dependencies.itens.length; i++) {
				dependency = dependencies.itens[i]
				_loader.add(dependency.value, {
					id: dependency.id,
					weight: dependency.weight
				});
			}
			
			_listenerManager.addEventListener(loader.bulk, Event.COMPLETE, _onCompleteDependenciesLoad);
			_listenerManager.addEventListener(loader.bulk, ErrorEvent.ERROR, _onErrorDependenciesLoad);
			
			_loader.start();
			
			dependencies = null;
			dependencyXml = null;
			i = NaN;
		}
		
		/**
		 * Handler de ERRO no carregamento das dependências
		 * @param	e
		 */
		private function _onErrorDependenciesLoad(e:Event):void{
			_listenerManager.removeAllEventListeners(loader.bulk);
			Logger.logError("[Config._onErrorDependenciesLoad]: " + e);
		}
		
		/**
		 * Handler de sucesso no carregamento das dependências
		 * @param	e
		 */
		private function _onCompleteDependenciesLoad(e:Event = null):void {
			if (_listenerManager.hasEventListener(loader.bulk, Event.COMPLETE, _onCompleteDependenciesLoad)) {
				_listenerManager.removeAllEventListeners(loader.bulk);
			}
			_sessionManager.parseXml();
			dispatchEvent(new Event(Event.COMPLETE));
			_isFinished = true;
		}
		
		public function get loader():SaciBulkLoader { return _loader; }
		
		/**
		 * XML original com as configurações das seções.
		 */
		public function get xml():XML { return _xml; }
		
		/**
		 * XML fake para usar em caso de erro / teste.
		 */
		public function get mockXml():XML { return _mockXml; }
		
		/**
		 * Se terminou de instanciar as seções
		 */
		public function get isFinished():Boolean { return _isFinished; }
		
		public function get shortcuts():Object { return _shortcuts; }
		
	}
	
}