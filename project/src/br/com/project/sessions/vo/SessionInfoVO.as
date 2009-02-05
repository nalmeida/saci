package br.com.project.sessions.vo {

	/**
	 * Value Object de Session
	 * @author Marcelo Miranda Carneiro | Nicholas Pires de Almeida
	 * @version 0.1
	 * @since 4/2/2009 22:16
	 * @see br.com.project.sessions.collections.DependencyItemVO
	 * @see br.com.project.sessions.collections.DependencyItemVOCollection
	 * @see br.com.project.sessions.collections.SessionCollection
	 * @see br.com.project.sessions.Session
	 * @see br.com.project.sessions.SessionManager
	 */
	
	import br.com.project.sessions.collections.DependencyItemVOCollection;
	
	public class SessionInfoVO{
		
		private var _id:String;
		private var _deeplink:String;
		private var _className:String;
		private var _initMethod:String;
		private var _dependencies:DependencyItemVOCollection;
		private var _xmlSession:XML;
		private var _xmlParams:XMLList;
		private var _parent:SessionInfoVO;
		
		public function SessionInfoVO($id:String, $deeplink:String, $className:String, $initMethod:String, $dependencies:DependencyItemVOCollection, $xmlSession:XML, $xmlParams:XMLList, $parent:SessionInfoVO) {
			_id = $id;
			_className = $className;
			_initMethod = $initMethod;
			_dependencies = $dependencies;
			_xmlSession = $xmlSession;
			_xmlParams = $xmlParams;
			_parent = $parent;
			_deeplink = $deeplink;
			// ajusta as barras do deeplink
			_normalizeDeepLink();
		}
		
		/**
		 * Ajusta o deeplink concatenado para evitar barras seguidas
		 */
		private function _normalizeDeepLink():void{
			_deeplink += (_deeplink.slice(-1) != "/") ? "/" : "";
			if (_parent != null) {
				_deeplink = (_deeplink.slice(0, 1) == "/") ? _deeplink.slice(1) : _deeplink;
				_deeplink = _parent.deeplink + _deeplink;
			}
		}
		
		public function toString():String {
			return "[SessionInfoVO] id: " + id + "; deeplink: " + deeplink + "; className: " + className + "; dependencies: " + dependencies + "; xmlSession: " + xmlSession + "; parent: " + parent + "; ";
		}
		
		/**
		 * ID da Session
		 */
		public function get id():String { return _id; }
		
		/**
		 * Deeplink da session
		 */
		public function get deeplink():String {return _deeplink;}
		
		/**
		 * Deeplink da session como array [seção, sub-seção, ...] 
		 */
		public function get deeplinkAsArray():Array {return _deeplink.split("/").slice(1,-1);}
		
		/**
		 * Classe usada pela Session
		 */
		public function get className():String { return _className; }
		
		/**
		 * Dependências da Session
		 */
		public function get dependencies():DependencyItemVOCollection { return _dependencies; }
		
		/**
		 * XML original da Session
		 */
		public function get xmlSession():XML { return _xmlSession; }
		
		/**
		 * XML dos parâmetros opcionais da Session
		 */
		public function get xmlParams():XMLList { return _xmlParams; }
		
		/**
		 * No caso de sub-seção, é o "pai"
		 */
		public function get parent():SessionInfoVO { return _parent; }

	}
}