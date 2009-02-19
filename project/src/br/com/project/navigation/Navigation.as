package br.com.project.navigation {
	
	/**
	 * Usada para navegação entre seções.
	 * @author Marcelo Miranda Carneiro | Nicholas Almeida
	 * @version 0.1
	 * @since 4/2/2009 22:16
     * @see br.com.project.sessions.Session
     * @see br.com.project.sessions.SessionManager
	 */
	
    import br.com.project.sessions.collections.SessionCollection;
    import br.com.project.sessions.Session;
    import br.com.project.sessions.SessionManager;
	import com.asual.swfaddress.SWFAddress;
	import com.asual.swfaddress.SWFAddressEvent;
	import flash.events.Event;
	import saci.events.ListenerManager;
	import saci.util.Logger;
	import saci.util.URL;
	
	public class Navigation {
		
		/**
		 * Static stuff (singleton)
		 */
		private static var _instance:Navigation;
		private static var _allowInstance:Boolean;

		public static function getInstance():Navigation {
			if (Navigation._instance == null) {
				Navigation._allowInstance = true;
				Navigation._instance = new Navigation();
				Navigation._allowInstance = false;
				
				// construtora
				Navigation._instance._sessionManager = SessionManager.getInstance();
				Navigation._instance._listenerManager = ListenerManager.getInstance();
				SWFAddress.addEventListener(SWFAddressEvent.CHANGE, Navigation._instance._onChange);
			}
			return Navigation._instance;
		}

		/**
		 * Dynamic stuff
		 */
		private var _listenerManager:ListenerManager;
		private var _sessionManager:SessionManager;
		
		private var _currentLink:String;
		private var _currentSession:Session;
		private var _lastLink:String;
		private var _lastSession:Session;

		public function Navigation():void {
			if (Navigation._allowInstance !== true) {
				throw new Error("Use the singleton Navigation.getInstance() instead of new Navigation().");
			}
		}
		
		/**
		 * Chama uma seção pela SWFAddress.
		 * @param	$deeplink deeplink da seção ([Session].info.deeplink)
		 */
		public function go($deeplink:String):void {
			
			$deeplink = resolveDeepLinkFormat($deeplink);
			/**
			 * Se não for um deeplink "válido" não faz nada (comparado pelas seções -- [Session].info.deeplink)
			 */
			if (isValidDeeplink($deeplink) === false || $deeplink == null) {
				Logger.logWarning("[Navigation.go] Ivalid Deeplink: " + $deeplink);
				if ($deeplink != _sessionManager.sessionCollection.getById(_sessionManager.defaultSessionID).info.deeplink) {
					go(_sessionManager.sessionCollection.getById(_sessionManager.defaultSessionID).info.deeplink);
				}
				return;
			}

			/**
			 * Define as propriedades com currentLink / lastLink (string do deeplink) e currentSession / lastSession (classe Session)
			 */
			_lastSession = _currentSession;
			_lastLink = _currentLink;

			_currentLink = (_sessionManager.sessionCollection.getByDeeplink($deeplink).info.redirectId != null) ? _sessionManager.sessionCollection.getById(_sessionManager.sessionCollection.getByDeeplink($deeplink).info.redirectId).info.deeplink : $deeplink;
			_currentSession = _sessionManager.sessionCollection.getByDeeplink(_currentLink);
			
			/**
			 * Para primeira seção, quando na finalização do carregamento for chamar
			 * a navigation.go, a SWFAddress não vai fazer nada na onChange, pois a
			 * área inicial foi "ignorada", força a abertura da seção.
			 */
			if (_currentLink == SWFAddress.getValue() && _currentSession.loaded === false) {
				_buildSession();
				return;
			}
			
			SWFAddress.setValue(_currentLink);
		}
		
		/**
		 * Chama um link externo.
		 * @param	$deeplink Como será contabilizado no analytics
		 * @param	$url
		 * @param	$target
		 */
		public function goExternal($deeplink:String, $url:String, $target:String):void {

			sendToAnalytics($deeplink);
			URL.call($url, $target);
		}
		
		public function sendToAnalytics($deeplink:String):void {
			Logger.log("Sending to Analytics: " + $deeplink);
			URL.analytics($deeplink);
		}
		
		/**
		 * Evento despachado pelo SWFAddress
		 * @param	e
		 */
		private function _onChange(e:SWFAddressEvent):void{
			if (e.value == "/") return;
			
			var value:String = resolveDeepLinkFormat(e.value);
			Logger.log("[Navigation._onChange] value: " + value);
			
			if (_currentLink != value) {
				if (_sessionManager.sessionCollection.getByDeeplink(value) != null) {
					go(value);
				}
			}
			
			/**
			 * Quando uma seção é chamada diretamente pelo endereço,
			 * o xml com as configurações não foi carregado, define a defaultSession
			 * para ser lançada quando o carregamento e instanciamentofor finalizado.
			 */
			if (_sessionManager.isFinished === false) {
				_sessionManager.defaultSessionAddress = value;
				return;
			}
			_buildSession();
		}
		
		public function resolveDeepLinkFormat($deeplink:String):String {
			if ($deeplink == null) return "";
			if ($deeplink.slice(0, 1) != "/") {
				$deeplink = "/" + $deeplink;
			}
			
			if ($deeplink.slice( -1) != "/") {
				$deeplink += "/";
			}
			return $deeplink;
		}
		
		/**
		 * Constrói a seção
		 */
		private function _buildSession():void {
			
			sendToAnalytics(_currentLink);
			
			var sameLevelSessions:SessionCollection = _sessionManager.sessionCollection.getSameLevelById(_currentSession.info.id);
			var openSessionAfter:Boolean = false;
			
			/**
			 * Se a seção for nula, não faz nada.
			 */
			if (_currentSession != null) {
				
				var i:int;
				/**
				 * Pega seções do mesmo nível + ativas.
				 */
				for (i = 0; i < sameLevelSessions.itens.length; i++) {
					if(
						sameLevelSessions.itens[i].active === true
						&& sameLevelSessions.itens[i] != _currentSession
						&& sameLevelSessions.itens[i] != _currentSession.parentSession
						&& _currentSession.info.overlay !== true
					){
						openSessionAfter = true;
						/**
						 * Adiciona o handler para abrir a seção chamada quando a seção atual for totalmente fechada.
						 */
						if (SessionCollection.isSubSection(_lastSession, _currentSession) === true) {
							_listenerManager.addEventListener(_lastSession, Session.COMPLETE_END_TRANSTITION, _openAfterTransition);
						}else {
							_listenerManager.addEventListener(sameLevelSessions.itens[i].highestParentSession, Session.COMPLETE_END_TRANSTITION, _openAfterTransition);
						}
						sameLevelSessions.itens[i].close();
					}
				}
				/**
				 * Se não houver ativa, simplesmente abre a seção chamada.
				 */
				if(openSessionAfter == false){
					_currentSession.open();
				}
			}
		}
		
		/**
		 * Event despachado para abrir a seção chamada quando a seção atual for totalmente fechada.
		 * @param	$e
		 */
		private function _openAfterTransition($e:Event):void {
			_listenerManager.removeEventListener($e.target as Session, Session.COMPLETE_END_TRANSTITION, _openAfterTransition);
			if (_currentSession.active === false) {
				_currentSession.open();
			}
		}
		
		/**
		 * Verifica se o id passado é uma seção válida.
		 * @param	$sessionDeeplink
		 * @return
		 */
		public function isValidDeeplink($sessionDeeplink:String):Boolean {
			var validDeeplink:Session = _sessionManager.sessionCollection.getByDeeplink($sessionDeeplink);
			return (validDeeplink != null) ? true : false;
		}
		
		/**
		 * Lista todos os deeplinks do site
		 */
		public function listValidDeeplinks():void {
			Logger.log("[Navigation.listValidDeeplinks] arrValidDeeplinks:\n");
			for (var i:int = 0; i < _sessionManager.sessionCollection.itens.length; i++) {
				Logger.log(_sessionManager.sessionCollection.itens[i].deeplink);
			}
		}
		
		/**
		 * Endereço atual (no formato do deeplink: /seção/sub-seção/.../
		 */
		public function get currentLink():String { return _currentLink; }
		
		/**
		 * Instância da seção atual (class Session)
		 */
		public function get currentSession():Session { return _currentSession; }
		
		/**
		 * Último endereço acessado (no formato do deeplink: /seção/sub-seção/.../
		 */
		public function get lastLink():String { return _lastLink; }

		/**
		 * Última seção acessada (class Session)
		 */
		public function get lastSession():Session { return _lastSession; }
	}
}
