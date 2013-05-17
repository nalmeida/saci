package project_name
{
	import br.com.stimuli.loading.BulkLoader;
	import br.com.stimuli.loading.BulkProgressEvent;
	import flash.display.DisplayObjectContainer;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.system.Security;
	import saci.util.DocumentUtil;
	import project_name.data.ServerData;
	import project_name.data.vo.MockDataVO;
	import project_name.ui.base.Base;
	import project_name.ui.SiteStructure;
	import project_name.ui.loader.LoaderIcon;
	import project_name.ui.navigation.buttons.OverButtonSelectable;
	
	/**
	 * ...
	 * @author Marcos Roque (mroque@fbiz.com.br)
	 */
	public class Main extends Sprite 
	{
		private var _serverData:ServerData;
		private var _mockData:MockDataVO;
		private var _siteStructure:SiteStructure;
		private var _base:Base;
		
		private var _layerContent:Sprite;
		private var _layerUI:Sprite;
		
		private var _xml:XML;
		private var _loaderIcon:LoaderIcon;
		
		private var _assets:MovieClip;
		
		public function Main():void 
		{
			if (stage) init();
			else addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(e:Event = null):void 
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
			
			_layerContent = new Sprite();
			_layerUI = new Sprite();
			
			addChild(_layerContent);
			addChild(_layerUI);
			
			/**
			* entry point
			*/
			_siteStructure = SiteStructure.getInstance();
			_base = Base.getInstance();
			_base.init(_siteStructure.bulk);
			
			/**
			* Document
			*/
			DocumentUtil.setDocument(root as DisplayObjectContainer);
			
			/**
			* ServerData
			*/
			_serverData = ServerData.getInstance();
			_mockData = MockDataVO.getInstance();
			_serverData.addEventListener(Event.COMPLETE, _onGetServerData);
			
			/**
			* Load Data (build site)
			*/
			_serverData.loadDataFromJs("getObj", _mockData.serverData);
		}
		
		protected function _onGetServerData(e:Event):void {
			_serverData.removeEventListener(Event.COMPLETE, _onGetServerData);
			
			/**
			* allow domains
			*/
			if(_serverData.get("allowedDomains") != null){
				var allowedDomains:Array = _serverData.get("allowedDomains").split(",");
				for (var i:int = 0; i < allowedDomains.length; i++) {
					Security.allowDomain(allowedDomains[i]);
				}
			}
			
			/**
			* load crossdomains
			*/
			if(_serverData.get("crossDomains") != null){
				var crossDomains:Array = _serverData.get("crossDomains").split(",");
				for (var j:int = 0; j < crossDomains.length; j++) {
					var crossdomain:String = crossDomains[j];
					Security.loadPolicyFile(crossDomains[j]);
				}
			}
			
			/**
			* Load dependencies
			*/
			_siteStructure.bulk.add(_serverData.get("xmlFile"), { id:"xml", type:BulkLoader.TYPE_XML } );
			_siteStructure.bulk.add(_serverData.get("assets"), { id:"assets", type:BulkLoader.TYPE_MOVIECLIP } );
			_siteStructure.bulk.addEventListener(BulkProgressEvent.COMPLETE, _onComplete);
			_siteStructure.bulk.start();
			
			
			/**
			 * Loader
			 */
			_loaderIcon = new LoaderIcon(this, new lib_standardLoader());
			_loaderIcon.show();
			
			_siteStructure.bulk.addEventListener("progress", function(e:*):void{
				_loaderIcon.refreshPercent(_siteStructure.bulk.weightPercent);
			});
			
		}
		
		private function _onComplete(e:BulkProgressEvent):void
		{
			_siteStructure.bulk.removeEventListener(BulkProgressEvent.COMPLETE, _onComplete);
			_loaderIcon.hide(false);
			_dependenciesLoaded();
		}
		
		private function _dependenciesLoaded():void
		{
			_xml = _siteStructure.bulk.getXML("xml");
			trace(this, "_xml:", _xml);
			
			_addContent();
			_addUI();
		}
		
		/**
		Content
		*/
		private function _addContent():void
		{
			_assets = _siteStructure.bulk.getContent("assets");
			_layerContent.addChild(_assets);
		}
		
		/**
		UI
		*/
		private function _addUI():void
		{
			var mc:MovieClip = _base.getLibraryItem("assets", "lib_ui") as MovieClip;
			_layerUI.addChild(mc);
			
			var overButtonSelectable:OverButtonSelectable = new OverButtonSelectable(mc)
		}
		
	}
	
}
