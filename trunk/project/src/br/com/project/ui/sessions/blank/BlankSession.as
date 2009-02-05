package br.com.project.ui.sessions.blank {
	
	/**
    * @author Marcelo Miranda Carneiro
	*/
	
	import br.com.project.loader.SaciBulkLoader;
	import br.com.project.Main;
	import br.com.project.navigation.Navigation;
	import br.com.project.sessions.Session;
	import br.com.project.sessions.vo.SessionInfoVO;
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
	
	public class BlankSession extends Session{
		
		protected var _parentContainer:DisplayObjectContainer;
		private var libTransition:SaciMovieClip;
		
		public function BlankSession($info:SessionInfoVO) {
			// define onde a seção será adicionada
			_parentContainer = DocumentUtil.documentClass;
			super($info);
			hide();
			
			_listenerManager.addEventListener(this, Session.COMPLETE_BUILD, _onCompleteBuild);
			_listenerManager.addEventListener(_loader.bulk, ErrorEvent.ERROR, _loadError);
			_listenerManager.addEventListener(_loader, SaciBulkLoader.SHOW_LOADER, _showLoaderIcon);
			_listenerManager.addEventListener(_loader, SaciBulkLoader.HIDE_LOADER, _hideLoaderIcon);
		}
		
		private function _loadError($e:ErrorEvent):void {
			Logger.logError("[Session1._loadError] error loading session \""+info.id+"\"");
		}
		private function _onCompleteBuild($e:Event):void {
			_listenerManager.removeEventListener(this, Session.COMPLETE_BUILD, _onCompleteBuild);
			_parentContainer.addChild(this);
			
			/**
			 * Constrói a seção
			 */
			
			// start transition after building area
			_startTransition();
		}
		
		private function _showLoaderIcon($e:Event):void{
			Main.mainLoaderIcon.show();
		}
		private function _hideLoaderIcon($e:Event):void{
			Main.mainLoaderIcon.hide();
		}
		
		public function get parentContainer():DisplayObjectContainer { return _parentContainer; }

		
	}
	
}
