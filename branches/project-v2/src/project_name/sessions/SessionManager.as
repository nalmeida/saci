﻿package project_name.sessions {
	
    import project_name.data.DependencyParser;
    import project_name.data.ServerData;
    import project_name.data.ShortcutParser;
    import project_name.loader.SaciBulkLoader;
    import project_name.navigation.Navigation;
    import project_name.sessions.collections.DependencyItemVOCollection;
    import project_name.sessions.collections.SessionCollection;
    import project_name.sessions.vo.DependencyItemVO;
    import project_name.sessions.vo.SessionInfoVO;
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
     * @see project_name.sessions.Session
     * @see project_name.navigation.Navigation
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
		protected var _listenerManager:ListenerManager;
		protected var _navigation:Navigation;
		protected var _serverData:ServerData;
        
		protected var _xml:XML;
		protected var _isFinished:Boolean = false;

		protected var _shortcuts:Object = {};
		protected var _defaultSessionID:String;
		protected var _defaultSessionAddress:String;
		protected var _sessionCollection:SessionCollection;
		protected var _externalSessionURLs:Array = [];
		
		public function SessionManager():void {
			if (SessionManager._allowInstance !== true) {
				throw new Error("Use the singleton SessionManager.getInstance() instead of new SessionManager().");
			}
		}
		
		/**
		 * Lê os dados do XML e instancia as seções.
		 * @param	$xml
		 */
		public function parseXML($xml:XML, $shortcuts:Object):void {
			
			if ($xml == null) {
				throw new Error("[SessionManager._parseXml] ERROR: XML não está definido.");
				return;
			}
			
			_shortcuts = $shortcuts;
			_xml = $xml;
			
			/**
			 * cria as sessions e sub-sessions
			 */
			var i:int;
			for (i = 0; i < _xml.session.length(); i++) {
				_parseSessionsXml(_xml.session[i]);
			}
			trace("+++++ AFTER ALL SESSIONS +++++");
			
			/**
			 * define id da seção inicial (se etiver separado por pipeline,
			 * "|", usa como separador de array e usa um dos itens como defaultSession);
			 */
			_defaultSessionID = _xml.@defaultSessionId;
			if (_defaultSessionID.split("|").length > 1) {
				_defaultSessionID = _defaultSessionID.split("|")[Math.round(Math.random() * (_defaultSessionID.split("|").length-1))];
			}
			if(_sessionCollection.getById(_defaultSessionID) == null){
				throw new Error("defaultSessionId \""+_defaultSessionID+"\" não é uma seção válida.");
				return;
			} else {
				_defaultSessionAddress = (_sessionCollection.getByDeeplink(_defaultSessionAddress) != null) ? _defaultSessionAddress : _sessionCollection.getById(_defaultSessionID).info.deeplink;
			}
			_isFinished = true;
		}
		
		public function initNavigation():void {
			/**
			 * Se já houver algum link sendo chamado pela Navigation, tenta ir direto nele
			 */
			if (_sessionCollection.getByDeeplink(_defaultSessionAddress) != null) {
				_navigation.go(_sessionCollection.getByDeeplink(_defaultSessionAddress).info.deeplink);
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
			
			// register external session XML address
			var externalSession:String = _serverData.parseString(_serverData.parseString($xml.@src.toString(), _shortcuts));
			
			if (externalSession != "") {
				// external XML sessions
				trace(">> Found external XML: " + externalSession +" / parent: " + $parent);
				
			}else {
				// normal sessions nodes
				var dependencies:DependencyItemVOCollection = DependencyParser.parseXML($xml.dependencies[0], _shortcuts);

				if ($xml.@className.toString() == "") {
					sessionClass = Session;
				}else{
					sessionClass = getDefinitionByName(_serverData.parseString(_serverData.parseString($xml.@className.toString(), _shortcuts))) as Class;
					if ((sessionClass as Session) is Session) {
						throw new Error("A classe passada na seção \""+$xml.@id.toString()+"\" deve extender \"Session\".");
						return;
					}
				}
				
				// register sessions
				session = new sessionClass(new SessionInfoVO(
					_serverData.parseString(_serverData.parseString($xml.@id.toString(), _shortcuts)),
					_serverData.parseString(_serverData.parseString($xml.@deeplink.toString(), _shortcuts)),
					_serverData.parseString(_serverData.parseString($xml.@className.toString(), _shortcuts)),
					($xml.name().toString() == "content"),
					_serverData.parseString(_serverData.parseString($xml.@redirect.toString(), _shortcuts)),
					_serverData.parseString(_serverData.parseString($xml.@overlay.toString(), _shortcuts)),
					dependencies,
					$xml,
					new XMLList(_serverData.parseString(_serverData.parseString($xml.params.toString(), _shortcuts))),
					$parent
				));
				
				/**
				 * Adiciona o session ao collection da SessionManager
				 */
				_sessionCollection.addItem(session);
			}
			
			/**
			 * Recursão para sub-sessions
			 */
			var i:int;
			for (i = 0; i < $xml.session.length(); i++) {
				_parseSessionsXml($xml.session[i], session.info);
			}
			for (i = 0; i < $xml.content.length(); i++) {
				_parseSessionsXml($xml.content[i], session.info);
			}
		}
		
		/**
		 * Seção que será carregada no início (caso não seja chamado uma outra área)
		 */
		public function get defaultSessionAddress():String { return _defaultSessionAddress; }
		public function set defaultSessionAddress(value:String):void {
			_defaultSessionAddress = value;
		}

		/**
		 * Seção principal, vinda do XML
		 */
		public function get defaultSessionID():String { return _defaultSessionID; }
		
		/**
		 * XML original com as configurações das seções.
		 */
		public function get xml():XML { return _xml; }

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