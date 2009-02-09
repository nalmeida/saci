package br.com.project{
	
	import as3classes.ui.loader.LoaderIcon;
	import br.com.project.data.ServerData;
	import br.com.project.loader.SaciBulkLoader;
	import br.com.project.sessions.SessionManager;
	import br.com.project.ui.sessions.session1.Session1;
	import flash.events.Event;
	import flash.geom.Point;
	import saci.events.ListenerManager;
	import saci.ui.Console;
	import saci.ui.SaciMovieClip;
	import saci.ui.SaciSprite;
	import saci.util.DocumentUtil;
	import saci.util.Logger;
	
	/**
	 * @author Marcelo Miranda Carneiro | Nicholas Almeida
	 */
	
	[Frame(factoryClass="br.com.project.loader.SelfPreloaderIcon")]
	 
	public class Main extends SaciSprite {
		
		static private var _mainLoaderIcon:LoaderIcon;
		
		public var listenerManager:ListenerManager;
		public var siteRoot:Sprite;
		public var console:Console;
		public var bpc:int = 0;
		public var sessionManager:SessionManager;
		public var serverData:ServerData;
		
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
			Session1;
			//Session2;
			
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
				root: "./",
				sessions: "{root}sessions.xml",
				swfPath: "{root}swf/"
			};
			listenerManager.addEventListener(serverData, Event.COMPLETE, _onGetServerData);
			serverData.loadDataFromJs("getObj");
			
			/**
			 * Loader Icon
			 */
			_mainLoaderIcon = new LoaderIcon(this, new lib_standardLoader(), null, new Point(stage.stageWidth/2, stage.stageHeight/2));
			
			/**
			 * Console
			 */
			console = new Console();
			addChild(console);

			/**
			 * Logger
			 */
			Logger.init(bpc, bpc > 0 && DocumentUtil.isWeb() ? console.log : trace);
			Logger.logLevel = bpc;
		}
		
		private function _onGetServerData(e:Event):void {
			listenerManager.removeEventListener(serverData, Event.COMPLETE, _onGetServerData);
			serverData.list();
			
			/**
			 * SessionManager
			 */
			sessionManager = SessionManager.getInstance();
			sessionManager.load(serverData.get("sessions"));
		}
		
		//private function _onResizeStage(e:Event):void{
			//trace(e);
		//}
		
		static public function get mainLoaderIcon():LoaderIcon { return _mainLoaderIcon; }
	}
}