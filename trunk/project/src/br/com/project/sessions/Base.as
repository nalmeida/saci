package br.com.project.sessions {
	
	/**
    * @author Marcelo Miranda Carneiro
	*/
	
	import br.com.project.data.DependencyParser;
	import br.com.project.data.ServerData;
	import br.com.project.loader.SaciBulkLoader;
	import br.com.project.sessions.collections.DependencyItemVOCollection;
	import br.com.project.sessions.vo.DependencyItemVO;
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import saci.events.ListenerManager;
	import saci.locales.Locales;
	import saci.ui.SaciSprite;
	
	public class Base extends EventDispatcher{
		
		//{ singleton
		private static var _instance:Base;
		private static var _allowInstance:Boolean;
			
		public static function getInstance():Base {
			if (Base._instance == null) {
				Base._allowInstance = true;
				Base._instance = new Base();
				Base._allowInstance = false;
				
				// constructor
				Base._instance._listenerManager = ListenerManager.getInstance();
				Base._instance._serverData = ServerData.getInstance();
			}
			return Base._instance;
		}
		//}

		protected var _listenerManager:ListenerManager;
		protected var _serverData:ServerData;
		
		protected var _loader:SaciBulkLoader;
		protected var _xml:XML;
		protected var _params:XMLList;
		private var _shortcuts:Object;
		
		public function Base():void {
			if (Base._allowInstance !== true) {
				throw new Error("Use the singleton Base.getInstance() instead of new Base().");
			}
		}
		
		public function parseXML($xml:XML, $shortcuts:Object):void {
			_xml = $xml;
			_params = new XMLList(_serverData.parseString(_serverData.parseString($xml.params.toString(), _shortcuts)));
			_shortcuts = $shortcuts;
			
			_build();
		}
		
		private function _build():void {

			_loader = new SaciBulkLoader();
			_listenerManager.addEventListener(_loader.bulk, Event.COMPLETE, _onLoadComplete);
			_listenerManager.addEventListener(_loader.bulk, ErrorEvent.ERROR, _onLoadError);
			_registerDependencies(DependencyParser.parseXML(_xml.dependencies[0], _shortcuts));
			_loader.start();
			
		}
		
		/**
		 * Regitra as dependências vindas do XML
		 * @private
		 */
		private function _registerDependencies($dependencies:DependencyItemVOCollection):void {
			var i:int;
			var dependency:DependencyItemVO;
			for (i = 0; i < $dependencies.itens.length; i++) {
				dependency = $dependencies.itens[i];
				_loader.add(dependency.value, {
					id: dependency.name,
					weight: dependency.weight
				});
			}
		}
		
		/**
		 * Handler de erro no carregamento das dependências
		 * @private
		 */
		private function _onLoadComplete($e:Event):void{
			/* Parse Locales */
			Locales.parse(_loader.bulk.getXML("locale"));
			_listenerManager.removeEventListener(_loader.bulk, Event.COMPLETE, _onLoadComplete);
			_listenerManager.removeEventListener(_loader.bulk, ErrorEvent.ERROR, _onLoadError);
			dispatchEvent($e);
		}
		
		/**
		 * Handler de erro no carregamento das dependências
		 * @private
		 */
		private function _onLoadError($e:ErrorEvent):void{
			_listenerManager.removeEventListener(_loader.bulk, Event.COMPLETE, _onLoadComplete);
			_listenerManager.removeEventListener(_loader.bulk, ErrorEvent.ERROR, _onLoadError);
			dispatchEvent($e);
		}
		
		//{ getters / setters
		
		public function get loader():SaciBulkLoader { return _loader; }
		public function get params():XMLList { return _params; }
		
		//}
	}
}