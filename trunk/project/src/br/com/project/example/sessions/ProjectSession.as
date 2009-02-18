package br.com.project.example.sessions {
	
	/**
    * @author Marcelo Miranda Carneiro
	*/
	
	import br.com.project.example.data.sessions.ProjectSessionParams;
	import br.com.project.sessions.Session;
	import br.com.project.sessions.vo.SessionInfoVO;
	import flash.display.DisplayObjectContainer;
	import flash.events.ErrorEvent;
	import saci.util.DocumentUtil;
	import saci.util.Logger;
	
	public class ProjectSession extends Session{
		
		protected var _parentContainer:DisplayObjectContainer;
		protected var _params:ProjectSessionParams;
		
		public function ProjectSession($info:SessionInfoVO) {
			_parentContainer = DocumentUtil.documentClass;
			super($info);

			_listenerManager.addEventListener(_loader.bulk, ErrorEvent.ERROR, _loadError);
			_params = new ProjectSessionParams(info.xmlParams);
		}
		private function _loadError($e:ErrorEvent):void {
			Logger.logError("[Session1._loadError] error loading area");
		}
		
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
		
		public function get params():ProjectSessionParams { return _params; }
		
	}
	
}
