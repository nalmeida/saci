package br.com.project.sessions {
	
	/**
	 * Classe que indica "seção". É integrada com a classe Navigation para fazer o deeplink funcionar automaticamente.
	 * @author Marcelo Miranda Carneiro | Nicholas Pires de Almeida
	 * @version 0.1
	 * @since 4/2/2009 22:16
	 * @see br.com.project.navigation.Navigation
	 * @see br.com.project.sessions.SessionManager
	 */

	import br.com.project.loader.SaciBulkLoader;
	import br.com.project.navigation.Navigation;
	import br.com.project.sessions.collections.SessionCollection;
	import br.com.project.sessions.vo.DependencyItemVO;
	import br.com.project.sessions.vo.SessionInfoVO;
	import br.com.stimuli.loading.BulkLoader;
	import br.com.stimuli.loading.loadingtypes.LoadingItem;
	import flash.display.DisplayObjectContainer;
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.utils.setTimeout;
	import saci.events.ListenerManager;
	import saci.interfaces.IDestroyable;
	import saci.ui.SaciSprite;
	import saci.util.Logger;
	
	public class Session extends SaciSprite{
		
		/**
		 * Static stuff
		 */
		static public const COMPLETE_START_TRANSTITION:String = "completeStartTransition";
		static public const COMPLETE_END_TRANSTITION:String = "completeEndTransition";
		static public const COMPLETE_BUILD:String = "completeBuild";
		
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
		protected var _navigation:Navigation = Navigation.getInstance();
		protected var _sessionManager:SessionManager = SessionManager.getInstance();

		protected var _info:SessionInfoVO;
		protected var _parentSession:Session;
		protected var _children:SessionCollection;

		protected var _loader:SaciBulkLoader;
		protected var _built:Boolean = false;
		protected var _active:Boolean = false;
		
		public function Session($info:SessionInfoVO) {
			Session._instances.push(this);
			_info = $info;
			
			/**
			 * coleção das sub-seções
			 */
			_children = new SessionCollection();

			_loader = new SaciBulkLoader();
			_listenerManager = ListenerManager.getInstance();
			_listenerManager.addEventListener(_loader.bulk, Event.COMPLETE, _onLoadComplete);
			_listenerManager.addEventListener(this, COMPLETE_END_TRANSTITION, _deactivate);

			/**
			 * registra dependencias no processo de loading
			 */
			_registerDependencies();
			
			/**
			 * Verifica se é uma sub-seção e se adiciona à seção pai
			 */
			_parentSession = Session.getByInfo(info.parent);
			if(_parentSession != null){
				_parentSession.addSessionChild(this);
			}
			
			hide();
		}
		
		/**
		 * Abre a seção. Caso não esteja carregada, começa o processo carregamento.
		 */
		public function open():void {
			if (_parentSession != null && _parentSession.active === false) {
				if (_listenerManager.hasEventListener(_parentSession, COMPLETE_START_TRANSTITION, _openAfterParent) === true) {
					_listenerManager.removeEventListener(_parentSession, COMPLETE_START_TRANSTITION, _openAfterParent);
				}
				_listenerManager.addEventListener(_parentSession, COMPLETE_START_TRANSTITION, _openAfterParent);
				_parentSession.open();
				return;
			}
			_active = true;
			if (loaded === true) {
				if(_built === true){
					_startTransition();
				}else {
					_build();
				}
			}else {
				_loader.start();
			}
		}
		
		/**
		 * Para sub-seções, força a abertura do pai antes que o filho se mostre. É chamada do listener da transição de abertura.
		 * @param	$e
		 */
		protected function _openAfterParent($e:Event):void {
			_listenerManager.removeEventListener(_parentSession, COMPLETE_START_TRANSTITION, _openAfterParent);
			open();
		}
		
		/**
		 * Fecha a seção
		 */
		public function close():void {
			if (_listenerManager.hasEventListener(this, COMPLETE_END_TRANSTITION, _closeParentAfter) === true) {
				_listenerManager.removeEventListener(this, COMPLETE_END_TRANSTITION, _closeParentAfter);
			}
			if (loaded == true) {
				if (children.hasActive() === true)
					return;
				if (_parentSession != null && _navigation.currentSession != _parentSession) {
					if (_parentSession.children.itens.length > 0 && _parentSession.active === true) {
						_listenerManager.addEventListener(this, COMPLETE_END_TRANSTITION, _closeParentAfter);
					}
				}
				_endTransition();
			}
		}
		
		/**
		 * Para sub-seções, força o fechamento do pai depois do filho, mantendo a ordem correta das transições. É chamada do listener da transição de fechamento.
		 * @param	$e
		 */
		protected function _closeParentAfter($e:Event):void {
			_listenerManager.removeEventListener(this, COMPLETE_END_TRANSTITION, _closeParentAfter);
			_parentSession.close();
		}

		/**
		 * "Desativa" a seção. É chamada no listener da transição de fechamento
		 * @param	$e
		 */
		private function _deactivate($e:Event):void {
			_active = false;
			hide();
		}
		
		/**
		 * Começa a transição de abertura. A princípio, não existe transição, então só despacha o evento.
		 */
		protected function _startTransition():void {
			Logger.log("[Session._startTransition] " + info.id);
			show();
			dispatchEvent(new Event(COMPLETE_START_TRANSTITION));
		}
		
		/**
		 * Começa a transição de fechamento. A princípio, não existe transição, então só despacha o evento.
		 */
		protected function _endTransition():void {
			Logger.log("[Session._endTransition] " + info.id);
			dispatchEvent(new Event(COMPLETE_END_TRANSTITION));
		}
		
		/**
		 * Regitra as dependências vindas do XML
		 */
		private function _registerDependencies():void {
			var i:int;
			var dependency:DependencyItemVO;
			for (i = 0; i < _info.dependencies.itens.length; i++) {
				dependency = _info.dependencies.itens[i];
				_loader.add(dependency.value, {
					id: dependency.id,
					weight: dependency.weight
				});
			}
		}
		
		/**
		 * Término do carregamento.
		 * @param	$e
		 */
		private function _onLoadComplete($e:Event):void {
			_listenerManager.removeEventListener(_loader.bulk, Event.COMPLETE, _onLoadComplete);
			_build();
		}
		
		/**
		 * Para início da sessão. Despacha um evento para isso.
		 */
		protected function _build():void{
			Logger.log("[Session._build] " + info.id);
			_built = true;
			dispatchEvent(new Event(COMPLETE_BUILD));
		}
		
		/**
		 * Adiciona um filho (sub-seção) à seção
		 * @param	$session
		 */
		private function addSessionChild($session:Session):void {
			_children.addItem($session);
		}
		
		/**
		 * Destrói todos os listeners e se remove da display list.
		 */
		override public function destroy():Boolean {
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
			hide();
			return super.destroy();
		}
		
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
		public function get loaded():Boolean { return _loader.bulk.isFinished; }
		
		/**
		 * "Pai" da seção, para os casos de sub-seções.
		 */
		public function get parentSession():Session { return _parentSession; }
		
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
	}
}