package project_name.data.vo {
	
	/**
	 * Class to organize site's "mock data"
	 * @author Marcelo Miranda Carneiro (mcarneiro@fbiz.com.br)
	 */
	public class MockDataVO{
		
		//{ singleton
		private static var _instance:MockDataVO;
		private static var _allowInstance:Boolean;
			
		public static function getInstance():MockDataVO {
			if (MockDataVO._instance == null) {
				MockDataVO._allowInstance = true;
				MockDataVO._instance = new MockDataVO();
				MockDataVO._instance.init();
				MockDataVO._allowInstance = false;
			}
			return MockDataVO._instance;
		}
		//}
		
		public function MockDataVO():void {
			if (MockDataVO._allowInstance !== true) {
				throw new Error("Use the singleton MockData.getInstance() instead of new MockData().");
			}
		}
		
		protected var _serverData:Object;
		protected var _siteStructure:Object;
		
		public function init():void {
			_serverData = { 
				// ADDRESSES
				"root": "../",
				"configPath": "{root}config/",
				"config": "{configPath}config.xml",
				"swfPath": "{root}swf/",
				"imgPath": "{root}img/",
				"localePath": "{root}locales/",
				"defaultLocalePath": "{localePath}pt-br/",
				"allowedDomains": "http://localhost/project_name/, http://mcarneiro/project_name/" // comma separated domains
			};
			
			_siteStructure = {
				// site structure mockup config
			}
		}
		
		public function get serverData():Object { return _serverData; }
		public function get siteStructure():Object { return _siteStructure; }
		
	}
	
}