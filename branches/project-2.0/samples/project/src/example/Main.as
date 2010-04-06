package example {

	import flash.display.Sprite;
	import saci.loader.Preloader;
	import flash.events.Event;
	import saci.loader.Dependencies;
	import br.com.stimuli.loading.BulkLoader;
	import flash.display.MovieClip;
	import br.com.stimuli.string.printf;
	import saci.project.data.Config;

	public class Main extends Sprite {

		//protected var _project:Project;
		protected var dependencies:Dependencies;

		public function Main() {
			super();
			
			Preloader.lazyCreator(this, _onComplete, _onError);
		}
		
		public function _onError(e:Event):void {
			trace('Main::_onError() Error preloading');
		}
		public function _onComplete(e:Event):void {
			if(stage != null){
				_init();
			}else{
				addEventListener(Event.ADDED_TO_STAGE, _init);
			}
		}
		
		protected function _init(e:Event = null):void {
			//_project = new Project();
			//_project.config.getFromJS("getObj");
			//_project.config.getFromXML(_project.config.configXML, _onCompleteXML);
			//
			//_project.config.addViewData();
			
			//ViewData.parseXML();
			//ViewData.parseJSON();
			//_viewData = new ViewData();

			//Dependencies.parseXML();
			//Dependencies.parseJSON();
			//_viewData.dependencies = new Dependencies();
			
			// config (via xml, via json)
			//	- paths (swf, image, service, gateway)
			//	- allowedDomains
			//	- cache
			//	- debug (trace verbose / console)
			//	- services
			//	- views / navigationViews (old "sessions")
			
			// layers
			//	- layerBackground
			//	- layerContent
			//	- layerModal
			//	- layerBlocker
			//	- layerConsole
			
			var config:Object = {
				data:{
					config1: "%(configPath)s/config1|",
					config4: "%(config3)s/config4|",
					config2: "%(config1)s/config2|",
					config3: "%(config2)s/config3|",
					config5: "%(config4)s/config5|",
					config: "%(configPath)s/config.xml",
					config6: "%(config5)s/config6|",
					config7: "%(config6)s/config7|",
					configPath: "%(globalPath)s/config/",
					globalPath: "%(root)s/global/",
					localePath: "%(root)s/pt-BR/",
					root: "."
				}
			};
			
			var _config:Config = Config.parseJSON(config);
			trace('Main::_init() _config: ', _config);
			for (var p:String in config.data) {
				trace('Main::_init() config.get("'+p+'"): ', _config.getData(p));
			}
			
			
			var bulk:BulkLoader = new BulkLoader("teste"); //, -1, BulkLoader.LOG_VERBOSE
			var xml:XML =	<dependencies>
								<item id="dictionary" url="../locales/pt-br/dictionary.xml"></item>
								<item id="base" url="../swf/assets.swf">
									<linkage name="lib_animatedSquare" klass="flash.display.MovieClip" />
								</item>
							</dependencies>
			dependencies = Dependencies.parseXML(xml.item);
			//trace('Main::_init() dependencies: ', dependencies);
			//dependencies = new Dependencies(bulk);
			//dependencies.add("../swf/assets.swf", {
			//	id: "base"
			//});
			//dependencies.addLinkage("base", "lib_animatedSquare", "flash.display.MovieClip");
			
			//dependencies.addByJSON({
			//	"name": "base",
			//	"url": "../swf/assets.swf",
			//	"linkages": [
			//		{"name":"lib_animatedSquare", "klass":"flash.display.MovieClip"}
			//	]
			//});
			dependencies.start();
			dependencies.addEventListener(Event.COMPLETE, _onLoadDependenciComplete)
		}

		protected function _onLoadDependenciComplete(e:Event):void {
			var teste:MovieClip = dependencies.cloneInstance("base", "lib_animatedSquare") as MovieClip;
			addChild(teste);
		}
		protected function _onCompleteXML(e:Event):void{
			//_project.addLayer("layerContent");
			//_project.listLayers();
			//_project.init();
			//_project.config.getViewData("background");
			//_siteStructure = new SiteStructure();
		}

	}
}