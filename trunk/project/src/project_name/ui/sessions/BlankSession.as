package project_name.ui.sessions {
	
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
	import project_name.ui.SiteStructure;
	import saci.ui.SaciMovieClip;
	import saci.util.DocumentUtil;
	import saci.util.Logger;
	
	public class BlankSession extends Session{
		
		protected var _siteStructure:SiteStructure = SiteStructure.getInstance();
		protected var _parentContainer:DisplayObjectContainer;
		
		public function BlankSession($info:SessionInfoVO) {
			// define onde a seção será adicionada
			super($info);
			
			_listenerManager.addEventListener(this, Session.COMPLETE_BUILD, _onCompleteBuild);
			_listenerManager.addEventListener(_loader.bulk, ErrorEvent.ERROR, _loadError);
			_listenerManager.addEventListener(this, Session.ON_ACTIVE, _onActive);
			_listenerManager.addEventListener(this, Session.ON_DEACTIVE, _onDeactive);
			_listenerManager.addEventListener(_loader, SaciBulkLoader.SHOW_LOADER, _showLoaderIcon);
			_listenerManager.addEventListener(_loader, SaciBulkLoader.HIDE_LOADER, _hideLoaderIcon);
		}
		
		private function _loadError($e:ErrorEvent):void {
			Logger.logError("[BlankSession._loadError] error loading session \""+info.id+"\"");
		}
		private function _onCompleteBuild($e:Event):void {
			_listenerManager.removeEventListener(this, Session.COMPLETE_BUILD, _onCompleteBuild);
			_parentContainer = _siteStructure.layerContent;
			_parentContainer.addChild(this);
			
			// Constrói a seção aqui
		}
		
		//{ active / deactive
		private function _onActive($e:Event):void{
			//trace("> active \""+info.id+"\"!");
		}
		private function _onDeactive($e:Event):void{
			hide(); // remove a seção da displaylist
			//trace("deactive \""+info.id+"\"!");
		}
		//}
		
		//{ loader icon
		private function _showLoaderIcon($e:Event):void{
			//trace("show loader icon");
		}
		private function _hideLoaderIcon($e:Event):void{
			//trace("hide loader icon");
		}
		//}
		
		//{ transition
		override protected function _startTransition():void {
			show(); // insere a seção na displaylist
			super._startTransition();
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
