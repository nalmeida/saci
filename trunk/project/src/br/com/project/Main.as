package br.com.halls{
	
    import br.com.halls.data.ServerData;
    import br.com.halls.loader.SaciBulkLoader;
	import br.com.halls.data.Config;
	import br.com.halls.sessions.SessionManager;
	import br.com.halls.ui.sessions.produtos.hallspower.Hallspower;
    import br.com.halls.ui.sessions.session1.Session1;
	import flash.events.Event;
	import saci.events.ListenerManager;
	import saci.ui.Console;
	import saci.ui.SaciMovieClip;
	import saci.ui.SaciSprite;
	import saci.util.DocumentUtil;
	import saci.util.Logger;
	
	/**
	 * @author Marcelo Miranda Carneiro | Nicholas Almeida
	 */
	
    //[Frame(factoryClass="br.com.halls.loader.SelfPreloaderIcon")] // precisa da as3classes
	 
	public class Main extends SaciSprite {
		
		public var sessionManager:SessionManager;
		public var listenerManager:ListenerManager;
		public var console:Console;
		public var bpc:int = 0;
		public var config:Config;
		public var serverData:ServerData;
		
		public var siteRoot:SaciSprite;		
		public var layerBackground:SaciSprite;
		public var layerContent:SaciSprite;
		public var layerBlocker:SaciSprite;
		public var layerAlert:SaciSprite;
		public var layerConsole:SaciSprite;
		
		public function Main():void {
			if (stage) init();
			else addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(e:Event = null):void {
			removeEventListener(Event.ADDED_TO_STAGE, init);
			
			// entry point
			
			siteRoot = new SaciSprite();
			addChild(siteRoot);
			
			/**
			 * Register Sessions;
			 */
			sessionManager = SessionManager.getInstance();
			Session1;
			Hallspower;
			
			/**
			 * Document
			 */
			DocumentUtil.setDocument(siteRoot);
			bpc = DocumentUtil.isWeb() ? int(DocumentUtil.getFlashVar("bpc")) : Logger.LOG_VERBOSE;
			
			/**
			 * ListenerManager
			 */
			listenerManager = ListenerManager.getInstance();
			//listenerManager.addEventListener(DocumentUtil.stage, Event.RESIZE, _onResizeStage);
			
			/**
			 * ServerData
			 */
			serverData = ServerData.getInstance();
			serverData.mockData = { 
				root: "../",
				config: "{root}config/config.xml",
				swfPath: "{root}swf/",
				imgPath: "{root}img/"
			};
			listenerManager.addEventListener(serverData, Event.COMPLETE, _onGetServerData);
			
			/**
			 * Layers
			 */
			layerBackground = new SaciSprite();
			layerContent = new SaciSprite();
			layerBlocker = new SaciSprite();
			layerAlert = new SaciSprite();
			layerConsole = new SaciSprite();
			
			siteRoot.addChild(layerBackground);
			siteRoot.addChild(layerContent);
			siteRoot.addChild(layerBlocker);
			siteRoot.addChild(layerAlert);
			siteRoot.addChild(layerConsole);
			
			/**
			 * Console
			 */
			console = new Console();
			layerConsole.addChild(console);

			/**
			 * Logger
			 */
			Logger.init(bpc, bpc > 0 && DocumentUtil.isWeb() ? console.log : trace);
			Logger.logLevel = bpc;
			
			
			/**
			 * Load Data
			 */
			serverData.loadDataFromJs("getObj");
			
		}
		
		private function _onGetServerData(e:Event):void {
			listenerManager.removeEventListener(serverData, Event.COMPLETE, _onGetServerData);
			serverData.list();
			
			/**
			 * Config
			 */
			config = Config.getInstance();
			listenerManager.addEventListener(config, Event.COMPLETE, _buildScreen);
			
			config.load(serverData.get("config"));
		}
		
		private function _buildScreen(e:Event):void {
			listenerManager.removeAllEventListeners(config);
			
			
			sessionManager.parseXml();
		}
		
		//private function _onResizeStage(e:Event):void{
			//trace(e);
		//}
	}
}

