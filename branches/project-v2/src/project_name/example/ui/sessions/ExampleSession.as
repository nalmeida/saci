package project_name.example.ui.sessions {
	
	/**
	 * @author Marcelo Miranda Carneiro
	 */
	
    import project_name.loader.SaciBulkLoader;
    import project_name.Main;
    import project_name.navigation.Navigation;
    import project_name.sessions.Session;
    import project_name.sessions.vo.SessionInfoVO;
	import flash.display.Bitmap;
	import flash.display.DisplayObjectContainer;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import saci.ui.SaciMovieClip;
	import saci.util.DocumentUtil;
	import saci.util.Logger;
	
	public class ExampleSession {
		
		protected var _parentContainer:DisplayObjectContainer;
		
		public function ExampleSession($info:SessionInfoVO) {
			// define onde a seção será adicionada
			_parentContainer = DocumentUtil.documentClass;
			super($info);
			hide();
			
			_listenerManager.addEventListener(this, Session.COMPLETE_BUILD, _onCompleteBuild);
			_listenerManager.addEventListener(_loader.bulk, ErrorEvent.ERROR, _loadError);
			_listenerManager.addEventListener(this, Session.ON_ACTIVE, _onActive);
			_listenerManager.addEventListener(this, Session.ON_DEACTIVE, _onDective);
			_listenerManager.addEventListener(_loader, SaciBulkLoader.SHOW_LOADER, _showLoaderIcon);
			_listenerManager.addEventListener(_loader, SaciBulkLoader.HIDE_LOADER, _hideLoaderIcon);
		}
		
		private function _loadError($e:ErrorEvent):void {
			Logger.logError("[BlankSession._loadError] error loading session \""+info.id+"\"");
		}
		private function _onCompleteBuild($e:Event):void {
			_listenerManager.removeEventListener(this, Session.COMPLETE_BUILD, _onCompleteBuild);
			_parentContainer.addChild(this);
			
			// Constrói a seção aqui
		}
		
		//{ active / deactive
		private function _onActive($e:Event):void{
			trace("> active \""+info.id+"\"!");
		}
		private function _onDective($e:Event):void{
			trace("deactive \""+info.id+"\"!");
		}
		//}
		
		//{ loader icon
		private function _showLoaderIcon($e:Event):void{
			trace("show loader icon");
		}
		private function _hideLoaderIcon($e:Event):void{
			trace("hide loader icon");
		}
		//}
		
		//{ show / hide
		override public function show():void {
			if (parent == null) {
				_parentContainer.addChild(this);
			}
			super.show();
		}
		override public function hide():void {
			if (parent != null) {
				parent.removeChild(this);
			}
			super.hide();
		}
		//}
		
		public function get parentContainer():DisplayObjectContainer { return _parentContainer; }

		
	}
	
}