package project_name.sessions.collections {
	
	/**
	 * Coleção de seções (classe Session)
	 * @author Marcelo Miranda Carneiro | Nicholas Pires de Almeida
	 * @version 0.1
	 * @since 4/2/2009 22:16
     * @see project_name.sessions.vo.SessionInfoVO
     * @see project_name.sessions.Session
     * @see project_name.sessions.SessionManager
	 */
	
    import project_name.sessions.Session;
    import project_name.sessions.SessionManager;
	import saci.collection.Collection;
	
	public class SessionCollection extends Collection{
		
		static public var _sessionManager:SessionManager = SessionManager.getInstance();
		
		/**
		 * Static stuff
		 */
		/**
		 * Verifica se duas sub-seções fazem parte da mesma seção
		 * @param	$item1
		 * @param	$item2
		 * @return
		 */
		static public function isSubSection($item1:Session, $item2:Session):Boolean {
			if ($item1 == null || $item2 == null) return false;
			var item1:Array = ($item1.info.redirectId != null) ? _sessionManager.sessionCollection.getById($item1.info.redirectId).info.deeplinkAsArray : $item1.info.deeplinkAsArray;
			var item2:Array = ($item2.info.redirectId != null) ? _sessionManager.sessionCollection.getById($item2.info.redirectId).info.deeplinkAsArray : $item2.info.deeplinkAsArray;
			var counter:int = 0;
			if (item1.length === item2.length) {
				var i:int;
				for (i = 0; i < (item1.length-1); i++) {
					if (item1[i] === item2[i]) {
						counter++;
					}else {
						return false;
					}
				}
				if (counter === (item1.length-1)) {
					return true;
				}
			}
			return false;
		}
		
		/**
		 * Dynamic stuff
		 */
		
		public function SessionCollection(...$itens) {
			_itemType = Session;
			super($itens);
		}
		
		/**
		 * Pega o deeplink de uma seção por ID
		 * @param	$id ID da seção ([Session].info.id)
		 * @return
		 */
		public function getDeeplinkById($id:String):String {
			var i:int;
			for (i = 0; i < itens.length; i++) {
				if (itens[i].info.id == $id) {
					return itens[i].info.deeplink;
				}
			}
			return null;
		}
		
		/**
		 * Pega uma seção por ID
		 * @param	$id ID da seção ([Session].info.id)
		 * @return
		 */
		public function getById($id:String):Session {
			var i:int;
			for (i = 0; i < itens.length; i++) {
				if (itens[i].info.id == $id) {
					return itens[i];
				}
			}
			return null;
		}
		
		/**
		 * Pega uma seção por Deeplink
		 * @param	$deeplink Deeplink da seção ([Session].info.deeplink)
		 * @return
		 */
		public function getByDeeplink($deeplink:String):Session {
			var i:int;
			for (i = 0; i < itens.length; i++) {
				if (itens[i].info.deeplink == $deeplink) {
					return itens[i];
				}
			}
			return null;
		}
		
		/**
		 * Pega todas as seções no mesmo nível + ativas pelo ID
		 * @param	$id ID da seção ([Session].info.id)
		 * @return
		 */
		public function getSameLevelById($id:String):SessionCollection {
			if (getById($id) == null) return null;
			var oriLink:Array = getById($id).info.deeplinkAsArray;
			var actLink:Array;
			var returnValue:SessionCollection = new SessionCollection();
			for (var i:int = 0; i < itens.length; i++) {
				if (itens[i].active === true) {
					returnValue.addItem(itens[i]);
				}else{
					actLink = itens[i].info.deeplinkAsArray;
					if(oriLink.length == 1){
						if (actLink.length == oriLink.length) {
							returnValue.addItem(itens[i]);
						}
					}else {
						if(actLink.length == oriLink.length && actLink[0] == oriLink[0]){
							returnValue.addItem(itens[i]);
						}
					}
				}
			}
			return (returnValue.itens.length > 0) ? returnValue : null;
		}
		
		/**
		 * Pega todas as seções do mesmo nível + ativas pelo deeplink
		 * @param	$deeplink Deeplink da seção ([Session].info.deeplink)
         * @see project_name.sessions.collections.SessionCollection#getSameLevelById
		 * @return
		 */
		public function getSameLevelByDeepLink($deeplink:String):SessionCollection {
			if (getByDeeplink($deeplink) == null) return null;
			return getSameLevelById(getByDeeplink($deeplink).info.id);
		}
		
		/**
		 * Verifica se existem seções ativas.
		 * @return
		 */
		public function hasActive():Boolean {
			var i:int;
			for (i = 0; i < itens.length; i++) {
				if (itens[i].active === true) {
					return true;
				}
			}
			return false;
		}
	}
}
