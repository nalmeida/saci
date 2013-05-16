package project_name.ui
{
	/**
	@author Marcos Roque (mroque@fbiz.com.br)
	*/
	import br.com.stimuli.loading.BulkLoader;
	
	public class SiteStructure
	{
		private var _bulk:BulkLoader;
		
		private static var _instance:SiteStructure;
		private static var _allowInstance:Boolean;
		
		// Sound
		
		public static function getInstance():SiteStructure {
			if (SiteStructure._instance == null) {
				SiteStructure._allowInstance = true;
				SiteStructure._instance = new SiteStructure();
				SiteStructure._allowInstance = false;
			}
			return SiteStructure._instance;
		}
		
		public function SiteStructure()
		{
			if (SiteStructure._allowInstance !== true) {
				throw new Error("Use the singleton SiteStructure.getInstance() instead of new SiteStructure().");
			}
			
			_bulk = new BulkLoader("main");
		}
		
		/**
		* Getter ans setter
		*/
		public function get bulk():BulkLoader { return _bulk };
		
	}
	
}