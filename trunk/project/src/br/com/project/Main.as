package br.com.project{
	
	import br.com.project.data.Config;
	import br.com.project.data.ServerData;
	import br.com.project.sessions.Base;
	import br.com.project.sessions.SessionManager;
	import br.com.project.example.ui.sessions.session1.Session1;
	import br.com.project.example.ui.sessions.session3.Item;
	import br.com.project.example.ui.sessions.session3.Session3;
	import br.com.project.example.ui.SiteStructure;
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
	
    //[Frame(factoryClass="br.com.project.loader.SelfPreloaderIcon")] // precisa da as3classes
	 
	public class Main extends SaciSprite {
		
		private var _console:Console;
		private var _bpc:int = 0;
		private var _config:Config;		
		private var _sessionManager:SessionManager;
		private var _serverData:ServerData;
		
		static private var _layerBackground:SaciSprite;
		static private var _layerContent:SaciSprite;
		static private var _layerBlocker:SaciSprite;
		static private var _layerAlert:SaciSprite;
		static private var _layerConsole:SaciSprite;
		
		public function Main():void {
			if (stage) init();
			else addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(e:Event = null):void {
			removeEventListener(Event.ADDED_TO_STAGE, init);
			
			/**
			 * Register Layers
			 */
			_layerBackground = new SaciSprite();
			_layerContent = new SaciSprite();
			_layerBlocker = new SaciSprite();
			_layerAlert = new SaciSprite();
			_layerConsole = new SaciSprite();
			
			addChild(_layerBackground);
			addChild(_layerContent);
			addChild(_layerBlocker);
			addChild(_layerAlert);
			addChild(_layerConsole);
			
			/**
			 * Register Sessions;
			 */
			_sessionManager = SessionManager.getInstance();
			Item;
			Session1;
			Session3;
			
			/**
			 * Document
			 */
			DocumentUtil.setDocument(_layerContent);
			_bpc = DocumentUtil.isWeb() ? int(DocumentUtil.getFlashVar("bpc")) : Logger.LOG_VERBOSE;
			
			/**
			 * ServerData
			 */
			_serverData = ServerData.getInstance();
			var mockData:Object = { 
				root: "../",
				configPath: "{root}config/",
				config: "{configPath}config.xml",
				swfPath: "{root}swf/",
				imgPath: "{root}img/",
				localePath: "{root}locales/",
				defaultLocalePath: "{localePath}pt-br/"
			};
			_listenerManager.addEventListener(_serverData, Event.COMPLETE, _onGetServerData);
			
			/**
			 * Console
			 */
			_console = new Console();
			_layerConsole.addChild(_console);

			/**
			 * Logger
			 */
			Logger.init(_bpc, _bpc > 0 && DocumentUtil.isWeb() ? _console.log : trace);
			Logger.logLevel = _bpc;
			
			
			/**
			 * Load Data
			 */
			_serverData.loadDataFromJs("getObj", mockData);
			
			_listenerManager.addEventListener(stage, Event.RESIZE, _onResizeStage);
			
		}
		
		private function _onGetServerData(e:Event):void {
			_listenerManager.removeEventListener(_serverData, Event.COMPLETE, _onGetServerData);
			_serverData.list();
			
			/**
			 * Config
			 */
			_config = Config.getInstance();
			_listenerManager.addEventListener(_config, Event.COMPLETE, _buildScreen);
			
			_config.loadDataFromXML(_serverData.get("config"));
		}
		
		private function _buildScreen(e:Event):void {
			_listenerManager.removeAllEventListeners(_config);
			
			// monta a estrutura do site
			SiteStructure.init(_layerBackground, Base.getInstance());
			_sessionManager.initNavigation();
		}
		
		static public function get layerBackground():SaciSprite { return _layerBackground; }
		static public function get layerContent():SaciSprite { return _layerContent; }
		static public function get layerBlocker():SaciSprite { return _layerBlocker; }
		static public function get layerAlert():SaciSprite { return _layerAlert; }
		static public function get layerConsole():SaciSprite { return _layerConsole; }
		
		private function _onResizeStage(e:Event):void{
			SiteStructure.update();
		}
	}
}

