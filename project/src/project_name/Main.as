package project_name{
	
	import flash.display.DisplayObjectContainer;
	import flash.system.Security;
    import project_name.data.Config;
    import project_name.data.ServerData;
	import project_name.data.vo.MockDataVO;
    import project_name.sessions.Base;
    import project_name.sessions.SessionManager;
	import project_name.ui.sessions.BlankSession;
    import project_name.ui.SiteStructure;
	import flash.events.Event;
	import saci.events.ListenerManager;
	import saci.uicomponents.Console;
	import saci.ui.SaciMovieClip;
	import saci.ui.SaciSprite;
	import saci.util.DocumentUtil;
	import saci.util.Logger;
	
	/**
	 * @author Marcelo Miranda Carneiro | Nicholas Almeida
	 */
	
    //[Frame(factoryClass="project_name.loader.SelfPreloaderIcon")] // precisa da as3classes
	 
	public class Main extends SaciSprite {
		
		protected var _console:Console;
		protected var _bpc:int = 0;
		protected var _config:Config;		
		protected var _sessionManager:SessionManager;
		protected var _siteStructure:SiteStructure;
		protected var _serverData:ServerData;
		protected var _mockData:MockDataVO;
		
		public function Main():void {
			if (stage) init();
			else addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		protected function init(e:Event = null):void {
			removeEventListener(Event.ADDED_TO_STAGE, init);
			
			/**
			 * Register Sessions;
			 */
			_sessionManager = SessionManager.getInstance();
			_siteStructure = SiteStructure.getInstance();
			BlankSession;
			
			/**
			 * Document
			 */
			DocumentUtil.setDocument(root as DisplayObjectContainer);
			_bpc = DocumentUtil.isWeb() ? int(DocumentUtil.getFlashVar("bpc")) : Logger.LOG_VERBOSE;
			
			/**
			 * ServerData
			 */
			_serverData = ServerData.getInstance();
			_mockData = MockDataVO.getInstance();
			_listenerManager.addEventListener(_serverData, Event.COMPLETE, _onGetServerData);
			
			/**
			 * Console
			 */
			_console = new Console();

			/**
			 * Logger
			 */
			Logger.init(_bpc, _bpc > 0 && DocumentUtil.isWeb() ? _console.log : trace);
			Logger.logLevel = _bpc;
			
			/**
			 * Registra fontes
			 */
			//FontLibrary.addFont("myriad", "regular", lib_MyriadPro);
			
			/**
			 * Load Data (build site)
			 */
			_serverData.loadDataFromJs("getObj", _mockData.serverData);
			
		}
		
		protected function _onGetServerData(e:Event):void {
			
			/**
			 * allow domains
			 */
			if(_serverData.get("allowedDomains") != null){
				var allowedDomains:Array = _serverData.get("allowedDomains").split(",");
				var allowedDomainsLength:int = allowedDomains.length;
				for (var i:int = 0; i < allowedDomainsLength; i++) {
					Security.allowDomain(allowedDomains[i]);
				}
			}
			
			_listenerManager.removeEventListener(_serverData, Event.COMPLETE, _onGetServerData);
			
			/**
			 * Config
			 */
			_config = Config.getInstance();
			_listenerManager.addEventListener(_config, Event.COMPLETE, _buildScreen);
			
			_config.loadDataFromXML(_serverData.get("config"));
		}
		
		protected function _buildScreen(e:Event):void {
			_listenerManager.removeAllEventListeners(_config);
			
			/**
			 * Add resize listener
			 */
			_listenerManager.addEventListener(stage, Event.RESIZE, _onResizeStage);
			
			/**
			 * build site structure (usually the background, navigation menus)
			 */
			_siteStructure.init(this, Base.getInstance(), _mockData.siteStructure);
			
			/**
			 * add console to stage
			 */
			if (_bpc > 0 && _bpc < 4 && DocumentUtil.isWeb())
				_siteStructure.layerConsole.addChild(_console);
			
			_sessionManager.initNavigation();
			
			_onResizeStage(null);
		}
		
		protected function _onResizeStage(e:Event):void{
			_siteStructure.update();
		}
	}
}

