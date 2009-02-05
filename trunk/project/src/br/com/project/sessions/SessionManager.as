package br.com.project.sessions {
	
	import br.com.project.data.ServerData;
    import br.com.project.loader.SaciBulkLoader;
	import br.com.project.navigation.Navigation;
	import br.com.project.sessions.collections.DependencyItemVOCollection;
	import br.com.project.sessions.collections.SessionCollection;
	import br.com.project.sessions.vo.DependencyItemVO;
	import br.com.project.sessions.vo.SessionInfoVO;
	import br.com.stimuli.loading.BulkLoader;
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.utils.getDefinitionByName;
	import flash.utils.setTimeout;
	import flash.xml.XMLNode;
	import saci.events.ListenerManager;
	import saci.util.DocumentUtil;
	import saci.util.Logger;
	
	/**
	 * Gerencia o carregamento e instanciamento das seções.
	 * @author Marcelo Miranda Carneiro | Nicholas Pires de Almeida
	 * @version 0.1
	 * @since 4/2/2009 22:17
	 * @see br.com.project.sessions.Session
	 * @see br.com.project.navigation.Navigation
	 */
	public class SessionManager {
		
		/**
		 * Static stuff (singleton)
		 */
		static private const LOADER_ID:String = "sessions-xml";
		static private var _instance:SessionManager;
		static private var _allowInstance:Boolean;
       
		static public function getInstance():SessionManager {
			if (SessionManager._instance == null) {
				SessionManager._allowInstance = true;
				SessionManager._instance = new SessionManager();
				SessionManager._allowInstance = false;
				
				// construtora
				SessionManager._instance._sessionCollection = new SessionCollection();
				SessionManager._instance._navigation = Navigation.getInstance();
				SessionManager._instance._serverData = ServerData.getInstance();
				SessionManager._instance._listenerManager = ListenerManager.getInstance();
			}
			return SessionManager._instance;
		}
		
		/**
		 * Dynamic stuff
		 */
		private var _listenerManager:ListenerManager;
		private var _navigation:Navigation;
		private var _serverData:ServerData;
        
		private var _loader:SaciBulkLoader;
		private var _mockXml:XML;
		private var _xml:XML;
		private var _isFinished:Boolean = false;

		private var _shortcuts:Object = {};
		private var _defaultSessionAddress:String;
		private var _useDeeplink:Boolean; //TODOFBIZ: --- [SessionManager._useDeeplink] implementar a useDeepLink
		private var _sessionCollection:SessionCollection;
		
		public function SessionManager():void {
			if (SessionManager._allowInstance !== true) {
				throw new Error("Use the singleton SessionManager.getInstance() instead of new SessionManager().");
			}
		}
		
		/**
		 * Começa carregamento do xml com as configurações das seções.
		 * @param	$sessionsXmlUrl
		 * @param	$mock
		 */
		public function load($sessionsXmlUrl:String, $mock:XML = null):void {
			_mockXml = $mock;
			
            _loader = SaciBulkLoader.getInstance();
			_loader.add($sessionsXmlUrl, { id:LOADER_ID, preventCache:true } );
			_listenerManager.addEventListener(loader.bulk.get(LOADER_ID), Event.COMPLETE, _onCompleteXmlLoad);
			_listenerManager.addEventListener(loader.bulk.get(LOADER_ID), ErrorEvent.ERROR, _onErrorXmlLoad);
			_loader.start();
		}
		
		/**
		 * Handler de sucesso no carregamento.
		 * @param	e
		 */
		private function _onCompleteXmlLoad(e:Event):void{
			_listenerManager.removeAllEventListeners(loader.bulk.get(LOADER_ID));
			_xml = loader.bulk.getXML(LOADER_ID);

			Logger.log("[SessionManager._onCompleteXmlLoad] loaded XML:\n" + _xml);
			
			_parseXml(_xml);
		}

		/**
		 * Handler de erro no carregamento. Usa o "xml fake" para preencher os dados.
		 * @param	e
		 */
		private function _onErrorXmlLoad(e:ErrorEvent):void {
			
			Logger.log("[SessionManager._onErrorXmlLoad] Error loading XML, using mock up xml:\n" + _xml);
			
			_listenerManager.removeAllEventListeners(loader.bulk.get(LOADER_ID));
			
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
				throw new Error("[SessionManager._parseXml] ERROR: XML não está definido.");
				return;
			}
			
			_xml = $xml;
			_useDeeplink = (xml.sessions.@useDeeplink == "true");
			
			/**
			 * gera os "shortcuts"
			 */
			var i:int;
			for (i = 0; i < xml.global[0].children().length(); i++) {
				_shortcuts[xml.global[0].children()[i].name()] = xml.global[0].children()[i].@value;
				if (_serverData.get(xml.global[0].children()[i].name()) != null) {
					Logger.logWarning("O xml \"" + _loader.bulk.get(LOADER_ID).url.url + "\" contém o atributo global \"" + xml.global[0].children()[i].name() + "\" que irá sobrepor o existente na ServerData.");
				}
			}
			
			/**
			 * cria as sessions e sub-sessions
			 */
			for (i = 0; i < xml.sessions[0].session.length(); i++) {
				_parseSessionsXml(xml.sessions[0].session[i]);
			}
			
			
			_defaultSessionAddress = (_sessionCollection.getByDeeplink(_defaultSessionAddress) != null) ? _defaultSessionAddress : _sessionCollection.getById(xml.sessions.@defaultSessionId).info.deeplink;
			_isFinished = true;
			if (_sessionCollection.getByDeeplink(_defaultSessionAddress) != null) {
				_navigation.go(_sessionCollection.getByDeeplink(_defaultSessionAddress).info.id);
			}else {
				throw new Error("Não foi possível encontrar uma seção com o id:" + _defaultSessionAddress);
			}
		}
		
		/**
		 * Lê o nó de cada seção para instancia-los recursivamente
		 * @param	$xml
		 * @param	$parent
		 */
		protected function _parseSessionsXml($xml:XML, $parent:SessionInfoVO = null):void {
			
			var sessionClass:Class;
			var	session:Session;
			var dependencies:DependencyItemVOCollection = new DependencyItemVOCollection();
			var dependencyXml:XML;
			var i:int;
			
			for (i = 0; i < $xml.dependencies.item.length(); i++) {
				dependencyXml = $xml.dependencies.item[i];
				dependencies.addItem(new DependencyItemVO(
					_serverData.parseString(_serverData.parseString(dependencyXml.@id.toString(), _shortcuts)),
					_serverData.parseString(_serverData.parseString(dependencyXml.@value.toString(), _shortcuts)),
					_serverData.parseString(_serverData.parseString(dependencyXml.@type.toString(), _shortcuts)),
					int(_serverData.parseString(_serverData.parseString(dependencyXml.@weight.toString(), _shortcuts))),
					_serverData.parseString(_serverData.parseString(dependencyXml.@version.toString(), _shortcuts))
				));
			}

			sessionClass = getDefinitionByName(_serverData.parseString(_serverData.parseString($xml.@className.toString(), _shortcuts))) as Class;
			if ((sessionClass as Session) is Session) {
				throw new Error("A classe passada na seção \""+$xml.@id.toString()+"\" deve extender \"Session\".");
				return;
			}
			
			// register sessions
			session = new sessionClass(new SessionInfoVO(
				_serverData.parseString(_serverData.parseString($xml.@id.toString(), _shortcuts)),
				_serverData.parseString(_serverData.parseString($xml.@deeplink.toString(), _shortcuts)),
				_serverData.parseString(_serverData.parseString($xml.@className.toString(), _shortcuts)),
				_serverData.parseString(_serverData.parseString($xml.@initMethod.toString(), _shortcuts)),
				dependencies,
				$xml,
				new XMLList(_serverData.parseString(_serverData.parseString($xml.params.toString(), _shortcuts))),
				$parent
			));
			
			/**
			 * Adiciona o session ao collection da SessionManager
			 */
			_sessionCollection.addItem(session);
			
			
			/**
			 * Recursão para sub-sessions
			 */
			for (i = 0; i < $xml.session.length(); i++) {
				_parseSessionsXml($xml.session[i], session.info);
			}
			
			session = null;
			dependencies = null;
			dependencyXml = null;
			i = NaN;
		}
		
		public function get loader():SaciBulkLoader { return _loader; }
		public function get useDeeplink():Boolean { return _useDeeplink; }
		public function set useDeeplink(value:Boolean):void {
			_useDeeplink = value;
		}
		
		/**
		 * Seção que será carregada no início (caso não seja chamado uma outra área)
		 */
		public function get defaultSessionAddress():String { return _defaultSessionAddress; }
		public function set defaultSessionAddress(value:String):void {
			_defaultSessionAddress = value;
		}
		/**
		 * XML original com as configurações das seções.
		 */
		public function get xml():XML { return _xml; }

		/**
		 * XML fake para usar em caso de erro / teste.
		 */
		public function get mockXml():XML { return _mockXml; }
		
		/**
		 * Coleção das seções.
		 */
		public function get sessionCollection():SessionCollection { return _sessionCollection; }
        
		/**
		 * Se terminou de instanciar as seções
		 */
		public function get isFinished():Boolean { return _isFinished; }
	}
}
