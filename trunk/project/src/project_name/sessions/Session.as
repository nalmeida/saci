package project_name.sessions {
	
	/**
	 * Classe que indica "seção". É integrada com a classe Navigation para fazer o deeplink funcionar automaticamente.
	 * @author Marcelo Miranda Carneiro | Nicholas Pires de Almeida
	 * @version 0.1.1
	 * @since 4/2/2009 22:16
	 * @see br.com.lux.navigation.Navigation
	 * @see br.com.lux.sessions.SessionManager
	 */

	import flash.display.DisplayObject;
	import project_name.loader.SaciBulkLoader;
	import project_name.navigation.Navigation;
	import project_name.sessions.collections.DependencyLinkageCollection;
	import project_name.sessions.collections.SessionCollection;
	import project_name.sessions.vo.DependencyItemVO;
	import project_name.sessions.vo.SessionInfoVO;
	import flash.events.Event;
	import saci.ui.SaciSprite;
	import saci.util.Logger;
	
	public class Session extends SaciSprite{
		
		/**
		 * Static stuff
		 */
		static public const START_TRANSTITION:String = "startTransition";
		static public const END_TRANSTITION:String = "endTransition";
		static public const COMPLETE_START_TRANSTITION:String = "completeStartTransition";
		static public const COMPLETE_END_TRANSTITION:String = "completeEndTransition";
		static public const COMPLETE_BUILD:String = "completeBuild";
		static public const ON_ACTIVE:String = "onActive";
		static public const ON_DEACTIVE:String = "onDeactive";
		
		static private var _instances:Array = [];
		
		/**
		 * Pega uma seção por ID.
		 * @param	$id ID da seção ([Session].info.id)
		 * @return
		 */
		static public function getById($id:String):Session {
			var i:int;
			for (i = 0; i < Session._instances.length; i++) {
				if (Session._instances[i].info.id == $id) {
					return Session._instances[i];
				}
			}
			return null;
		}
		
		/**
		 * Pega uma seção pelo info.
		 * @param	$info Value object com os dados da seção (vindos do xml).
		 * @return
		 */
		static public function getByInfo($info:SessionInfoVO):Session {
			var i:int;
			for (i = 0; i < Session._instances.length; i++) {
				if (Session._instances[i].info == $info) {
					return Session._instances[i];
				}
			}
			return null;
		}
		
		/**
		 * Dynamic stuff
		 */
		protected var _navigation:Navigation;
		protected var _sessionManager:SessionManager;

		protected var _info:SessionInfoVO;
		protected var _parentSession:Session;
		protected var _parentSessions:Array = [];
		protected var _children:SessionCollection;
		protected var _loader:SaciBulkLoader;
		
		protected var _doCloseParentAfter:Boolean = false;
		protected var _built:Boolean = false;
		protected var _active:Boolean = false;
		protected var _linkages:DependencyLinkageCollection;
		
		public function Session($info:SessionInfoVO) {
			Session._instances.push(this);
			_info = $info;
			_navigation = Navigation.getInstance();
			_sessionManager = SessionManager.getInstance();
			
			/**
			 * Coleção das sub-seções
			 */
			_children = new SessionCollection();

			/**
			 * Verifica se é uma sub-seção e se adiciona ao pai
			 */
			_parentSession = Session.getByInfo(info.parent);
			if(_parentSession != null && info.className != null){
				_parentSession.addSessionChild(this);
			}
			
			var currentParentSession:Session = _parentSession;
			while(currentParentSession){
				_parentSessions.push(currentParentSession);
				currentParentSession = currentParentSession.parentSession;
			}
			
			/**
			 * Se for dependencia do pai, usa o loader dele.
			 */
			if (info.isContent && parentSession != null) {
				_loader = parentSession._loader;
			}else {
				_loader = new SaciBulkLoader();
				_registerDependencies(info);
				_listenerManager.addEventListener(_loader.bulk, Event.COMPLETE, _onLoadComplete);
			}
			_listenerManager.addEventListener(this, COMPLETE_END_TRANSTITION, _deactivate);
			
			hide();
		}
		
		//{ open-load / close
		
		/**
		 * Abre a seção. Caso não esteja carregada, começa o processo carregamento.
		 * Caso tenha um pai e ele não está aberto / carregado, começa o processo pelo pai (recursivo).
		 */
		public function open():void {
			if (_parentSession != null && !_parentSession.active) {
				_listenerManager.addEventListener(_parentSession, COMPLETE_START_TRANSTITION, _openAfterParent);
				_parentSession.open();
				return;
			}

			/*trace("##open## ", info.deeplink);*/
			
			_active = true;
			dispatchEvent(new Event(ON_ACTIVE));
			
			if (loaded) {
				if(_built){
					_startTransition();
				}else {
					_build();
				}
			}else {
				if (hasDependency) {
					_loader.start();
				}else {
					_build();
				}
			}
		}
		
		/**
		 * Para sub-seções, força a abertura do pai antes que o filho se mostre.
		 * É chamada do listener da transição de abertura.
		 * @param	$e
		 */
		protected function _openAfterParent($e:Event):void {
			_listenerManager.removeEventListener(_parentSession, COMPLETE_START_TRANSTITION, _openAfterParent);
			open();
		}
		
		/**
		 * Fecha a seção. Se houver filhos que não foram fechados, inicia o
		 * processo de fechamento recursivo
		 */
		public function close(closeParentAfter:Boolean = false):void {
			//TODOFBIZ: --- [Session.close] verificar se a completeStartTransition foi disparada para evitar o erro de animação na timeline
			
			if (loaded) {
				/*trace("##close## children.hasActive(): ", children.hasActive(), info.deeplink);*/
				if (children.hasActive()){
					_doCloseParentAfter = closeParentAfter;
					for (var i:int = 0; Boolean(children.itens[i]); i++){
						if(children.itens[i].active){
							children.itens[i].close(true);
						}
					}
					return;
				}
				if (_parentSession != null && _navigation.currentSession != _parentSession && closeParentAfter) {
					_listenerManager.addEventListener(this, COMPLETE_END_TRANSTITION, _closeParentAfter);
				}
				_endTransition();
			}
		}
		
		/**
		 * Evento disparado pelo método "close" quando a seção contém um pai.
		 * @private
		 */
		private function _closeParentAfter($e:Event):void {
			_listenerManager.removeEventListener(this, COMPLETE_END_TRANSTITION, _closeParentAfter);
			_parentSession.close(_parentSession._doCloseParentAfter);
			_parentSession._doCloseParentAfter = false;
		}
		
		/**
		 * "Desativa" a seção. É chamada no listener da transição de fechamento
		 * @private
		 */
		private function _deactivate($e:Event):void {
			_active = false;
			dispatchEvent(new Event(ON_DEACTIVE));
		}
		
		/**
		 * Término do carregamento.
		 * @private
		 */
		private function _onLoadComplete($e:Event):void {
			_listenerManager.removeEventListener(_loader.bulk, Event.COMPLETE, _onLoadComplete);
			if(_linkages != null){
				var content:DisplayObject;
				var contentName:String;
				var linkageLength:int = _linkages.itens.length;
				for (var i:int = 0; i < linkageLength; i++) {
					contentName = _linkages.itens[i].name;
					content = _loader.bulk.getContent(contentName) as DisplayObject;
					_linkages.itens[i].init(content);
				}
				content = null;
				contentName = null;
				linkageLength = -1;
			}
			_build();
		}
		
		/**
		 * Constrói a sessão. Despacha um evento (COMPLETE_BUILD).
		 * @private
		 */
		private function _build():void{
			Logger.log("[Session._build] " + info.id);
			_built = true;
			dispatchEvent(new Event(COMPLETE_BUILD));
			_startTransition();
		}
		
		//}
		//{ transition
		
		/**
		 * Começa a transição de abertura. A princípio, não existe transição, então só despacha o evento.
		 */
		protected function _startTransition():void {
			Logger.log("[Session._startTransition] " + info.id);
			dispatchEvent(new Event(COMPLETE_START_TRANSTITION));
		}
		
		/**
		 * Começa a transição de fechamento. A princípio, não existe transição, então só despacha o evento.
		 */
		protected function _endTransition():void {
			Logger.log("[Session._endTransition] " + info.id);
			dispatchEvent(new Event(COMPLETE_END_TRANSTITION));
		}
		
		//}
		//{ dependencies / children sessions
		
		/**
		 * Regitra as dependências vindas do XML
		 * @private
		 */
		private function _registerDependencies($info:SessionInfoVO):void {
			if ($info.dependencies == null) return;
			var i:int;
			var dependency:DependencyItemVO;
			if(_linkages == null)
				_linkages = new DependencyLinkageCollection();
			for (i = 0; i < $info.dependencies.itens.length; i++) {
				dependency = $info.dependencies.itens[i];
				if (dependency.linkageCollection != null)
					_linkages.addItem(new DependencyLinkage(dependency.name, dependency.linkageCollection));
				_loader.add(dependency.value, {
					id: (($info != info) ? $info.id + "." : "") + dependency.name,
					weight: dependency.weight
				});
			}
		}
		
		/**
		 * Adiciona um filho (sub-seção) à seção
		 * @private
		 */
		protected function addSessionChild($session:Session):void {
			if(!_children.has($session) && $session.info.isContent){
				_registerDependencies($session.info);
			}
			_children.addItem($session);
		}
		/**
		 * Destrói todos os listeners e se remove da display list.
		 */
		override public function destroy():Boolean {
			hide();
			_listenerManager.removeAllEventListeners(_loader.bulk);
			_listenerManager.removeAllEventListeners(_loader);
			_children.destroy();
			if (_parentSession != null) {
				if(_listenerManager.hasEventListener(_parentSession, COMPLETE_START_TRANSTITION, _openAfterParent)){
					_listenerManager.removeEventListener(_parentSession, COMPLETE_START_TRANSTITION, _openAfterParent);
				}
				if (_listenerManager.hasEventListener(_parentSession, COMPLETE_END_TRANSTITION, _closeParentAfter)) {
					_listenerManager.removeEventListener(_parentSession, COMPLETE_END_TRANSTITION, _closeParentAfter);
				}
			}
			return super.destroy();
		}
		
		//}
		//{ getters / setters
		
		/**
		 * Dados da seção (vindos do XML).
		 */
		public function get info():SessionInfoVO { return _info; }
		
		/**
		 * Flag indicando que a seção está "ativa" (sendo navegada).
		 */
		public function get active():Boolean { return _active; }
		
		/**
		 * Flag indicando que a seção já foi iniciada.
		 */
		public function get built():Boolean { return _built; }
		
		/**
		 * Flash indicando que a seção já foi carregada.
		 */
		public function get loaded():Boolean {
			if (hasDependency) {
				return _loader.bulk.isFinished;
			} else {
				return true;
			}
		}
		
		/**
		 * "Pai" da seção, para os casos de sub-seções.
		 */
		public function get parentSession():Session { return _parentSession; }
		public function get parentSessions():Array { return _parentSessions.concat(); }
		
		/**
		 * O "pai" no maior nível na árvore de de seções.
		 * Ex.: em "seção > sub-seção > sub-sub-seção", o highestParentSession é "seção".
		 */
		public function get highestParentSession():Session {
			var sessionToCompare:Session = this;
			var returnValue:Session;
			while (sessionToCompare != null) {
				returnValue = sessionToCompare;
				sessionToCompare = sessionToCompare.parentSession;
			}
			return returnValue;
		}
		
		/**
		 * Coleção com os "filhos" (sub-seções).
		 */
		public function get children():SessionCollection { return _children; }
		
		/**
		 * Se a seção tem alguma dependência
		 */
		public function get hasDependency():Boolean {
		
			if (info.dependencies == null)
				return false;
			
			if (info.dependencies.itens.length > 0) {
				return true;
			}else {
				return false;
			}
		}
		
		public function get linkages():DependencyLinkageCollection { return _linkages; }
		//}
	}
}
