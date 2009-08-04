package project_name.sessions {
	
	/**
    * @author Marcelo Miranda Carneiro
	*/
	
	import flash.display.DisplayObject;
    import project_name.data.ServerData;
    import project_name.loader.SaciBulkLoader;
    import project_name.sessions.collections.DependencyItemVOCollection;
	import project_name.sessions.collections.DependencyLinkageCollection;
    import project_name.sessions.vo.DependencyItemVO;
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
		protected var _shortcuts:Object;
		
		protected var _linkages:DependencyLinkageCollection;
		protected var _itemVOCollection:DependencyItemVOCollection;
		
		public function Base():void {
			if (Base._allowInstance !== true) {
				throw new Error("Use the singleton Base.getInstance() instead of new Base().");
			}
		}
		
		public function parseXML($xml:XML, $shortcuts:Object):void {
			_xml = $xml;
			
			if (_xml && _xml.params.toString() != "") {
				_params = new XMLList(_serverData.parseString(_serverData.parseString(_xml.params.toString(), _shortcuts)));
			} else {
				_params = new XMLList("<value />");
			}
			
			_shortcuts = $shortcuts;
			
			_build();
		}
		
		private function _build():void {

			_loader = new SaciBulkLoader();
			
			if (_xml){
				if(_xml.dependencies.toString() != ""){
					_listenerManager.addEventListener(_loader.bulk, Event.COMPLETE, _onLoadComplete);
					_listenerManager.addEventListener(_loader.bulk, ErrorEvent.ERROR, _onLoadError);
					_itemVOCollection = DependencyItemVOCollection.parseXML(_xml.dependencies[0].item, _shortcuts);
					_registerDependencies();
					_loader.start();
					return;
				}
			}
			dispatchEvent(new Event(Event.COMPLETE));
		}
		
		/**
		 * Regitra as dependências vindas do XML
		 * @private
		 */
		private function _registerDependencies():void {
			var i:int;
			var dependency:DependencyItemVO;
			_linkages = new DependencyLinkageCollection();
			for (i = 0; i < _itemVOCollection.itens.length; i++) {
				dependency = _itemVOCollection.itens[i];
				if (dependency.linkageCollection != null)
					_linkages.addItem(new DependencyLinkage(dependency.name, dependency.linkageCollection));
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
			
			var content:DisplayObject;
			var contentName:String;
			var linkageLength:int = int(_linkages.itens.length);
			
			for (var i:int = 0; i < linkageLength; i++) {
				contentName = _linkages.itens[i].name;
				content = _loader.bulk.getContent(contentName) as DisplayObject;
				_linkages.itens[i].init(content);
			}
			content = null;
			contentName = null;
			linkageLength = -1;
			
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
		
		/**
		 * Loader
		 */
		public function get loader():SaciBulkLoader { return _loader; }
		
		/**
		 * Parâmetros (xml)
		 */
		public function get params():XMLList { return _params; }
		
		/**
		 * Coleção de linkages por dependência
		 */
		public function get linkages():DependencyLinkageCollection { return _linkages; }
		
		//}
	}
}
