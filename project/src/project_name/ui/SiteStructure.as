package project_name.ui {
	
	/**
	 * Site structure holder / builder / controller (navigation menus, background, etc, should be controlled here)
     * @author Marcelo Miranda Carneiro
	 */
	
	import flash.text.TextField;
	import flash.text.TextFormat;
    import project_name.data.sessions.ProjectParams;
    import project_name.sessions.Base;
	import com.adobe.serialization.json.JSON;
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.text.Font;
	import project_name.data.RawData;
	import project_name.sessions.SessionManager;
	import saci.fonts.FontLibrary;
	import saci.ui.SaciSprite;
	import saci.util.ClassUtil;
	import saci.util.DocumentUtil;
	
	public class SiteStructure {
		
		//{ singleton
		private static var _instance:SiteStructure;
		private static var _allowInstance:Boolean;
			
		public static function getInstance():SiteStructure {
			if (SiteStructure._instance == null) {
				SiteStructure._allowInstance = true;
				SiteStructure._instance = new SiteStructure();
				SiteStructure._instance._sessionManager = SessionManager.getInstance();
				SiteStructure._allowInstance = false;
			}
			return SiteStructure._instance;
		}
		//}
		
		public function SiteStructure():void {
			if (SiteStructure._allowInstance !== true) {
				throw new Error("Use the singleton SiteStructure.getInstance() instead of new SiteStructure().");
			}
		}
		
		protected var _sessionManager:SessionManager;
		protected var _base:Base;
		protected var _params:ProjectParams;
		protected var _rawData:RawData;

		protected var _root:DisplayObjectContainer;
		protected var _layerBackground:SaciSprite;
		protected var _layerContent:SaciSprite;
		protected var _layerNavigation:SaciSprite;
		protected var _layerBlocker:SaciSprite;
		protected var _layerAlert:SaciSprite;
		protected var _layerConsole:SaciSprite;
		
		public function init(siteContainer:DisplayObjectContainer, base:Base, mockData:Object):void {
			
			/**
			 * register default layers
			 */
			_root = siteContainer;
			_layerBackground = new SaciSprite();
			_layerContent = new SaciSprite();
			_layerNavigation = new SaciSprite();
			_layerBlocker = new SaciSprite();
			_layerAlert = new SaciSprite();
			_layerConsole = new SaciSprite();
			
			_root.addChild(_layerBackground);
			_root.addChild(_layerContent);
			_root.addChild(_layerNavigation);
			_root.addChild(_layerBlocker);
			_root.addChild(_layerAlert);
			_root.addChild(_layerConsole);
			
			/**
			 * register base params and config settings
			 */
			_base = base;
			_params = new ProjectParams(_base.params.value);
			var rawData:Object;
			if(_base.loader.bulk.getText("config") != "" && _base.loader.bulk.getText("config") != "null")
				rawData = JSON.decode(_base.loader.bulk.getText("config"));
			_rawData = new RawData(rawData, mockData);
			
			// registrar os elementos estruturais (de lay out) aqui
			
			var txtTest:TextField = new TextField();
			txtTest.wordWrap = 
			txtTest.embedFonts = true;
			txtTest.autoSize = flash.text.TextFieldAutoSize.LEFT;
			txtTest.width = 500;
			txtTest.defaultTextFormat = new TextFormat(FontLibrary.getFontName("myriad", "regular"), 25);
			txtTest.appendText("Teste do carregamento da fonte \"" + FontLibrary.getFontName("myriad", "regular")+"\"\n");
			txtTest.appendText("Não se esqueça de atualizar ou remover o swc \"fonts.swc\" e as linhas que adicionam este exemplo em \"Main.as\" e \"SiteStructure.as\"");
			trace("[SiteStructure.init] txtTest.text: " + txtTest.text);
			txtTest.x = txtTest.y = 30;
			_layerContent.addChild(txtTest);
		}
		
		public function update():void {
			// disparado no resize do flash (adicionado na Main.as)
		}
		
		public function get rawData():RawData { return _rawData; }
		
		public function get root():DisplayObjectContainer { return _root; }
		public function get layerBackground():SaciSprite { return _layerBackground; }
		public function get layerContent():SaciSprite { return _layerContent; }
		public function get layerNavigation():SaciSprite { return _layerNavigation; }
		public function get layerBlocker():SaciSprite { return _layerBlocker; }
		public function get layerAlert():SaciSprite { return _layerAlert; }
		public function get layerConsole():SaciSprite { return _layerConsole; }
	}
}


