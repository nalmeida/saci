package project_name.ui.base
{
	/**
	@author Marcos Roque (mroque@fbiz.com.br)
	*/
	import br.com.stimuli.loading.BulkLoader;
	import saci.util.ClassUtil;
	
	public class Base
	{
		//{ singleton
		private static var _instance:Base;
		private static var _allowInstance:Boolean;
			
		public static function getInstance():Base {
			if (Base._instance == null) {
				Base._allowInstance = true;
				Base._instance = new Base();
				Base._allowInstance = false;
			}
			return Base._instance;
		}
		//}
		
		public function Base():void {
			if (Base._allowInstance !== true) {
				throw new Error("Use the singleton MockData.getInstance() instead of new MockData().");
			}
		}
		
		private var _bulk:BulkLoader;
		
		public function init(bulk:BulkLoader):void
		{
			_bulk = bulk;
		}
		
		public function getLibraryItem(resource:String, libItem:String):*
		{
			return ClassUtil.cloneClassFromSwf(_bulk.getMovieClip(resource), libItem);
		}
		
	}
	
}