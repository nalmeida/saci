package project_name.ui.navigation.buttons {

	/**
	 * @author Marcelo Miranda Carneiro - mcarneiro@fbiz.com.br
	 */
	
	import flash.display.*;
	import flash.events.*;
	import flash.text.*;
	import flash.external.ExternalInterface;
	import flash.net.navigateToURL;
	import flash.net.URLRequest;
	import saci.events.ListenerManager;
	//import project_name.navigation.Navigation;
	import saci.util.URL;
	
	public class ProjectButton extends Button{
		
		//protected var _navigation:Navigation;
		protected var _listenerManager:ListenerManager;
		protected var _linkToGo:String;
		protected var _targetToGo:String;
		protected var _analyticsToGo:String;
		
		public function ProjectButton(p_holder:Sprite, p_asHolder:Boolean = false) {
			super(p_holder, p_asHolder);
			_listenerManager = ListenerManager.getInstance();
			//_navigation = Navigation.getInstance();
		}
		
		public function setDestination(p_link:String, p_target:String = null, p_analytics:String = null):void {
			_linkToGo = p_link;
			_targetToGo = p_target;
			_analyticsToGo = p_analytics;
			
			if (_linkToGo != null && !_listenerManager.hasEventListener(this, MouseEvent.CLICK, _onClickDestination))
				_listenerManager.addEventListener(this, MouseEvent.CLICK, _onClickDestination);
		}
		
		protected function _onClickDestination(e:MouseEvent):void{
			var javascript:Array = _linkToGo.match(/javascript:(.*)\((.*?)\);/);
			if(javascript != null){
				var params:Array = [javascript[1]];
				if(javascript[2] != null){
					var splitted:Array = javascript[2].split(",");
					for (var i:int = 0; Boolean(splitted[i]); i++){
						params[params.length] = splitted[i].replace(/^\s+(.*?)\s+p_/, "p_1").replace(/^\'(.*?)\'p_/, "p_1");
					}
				}
				if(ExternalInterface.available){
					ExternalInterface.call.apply(null, params);
				}
			}else if(_linkToGo.match(/http:\/\//) != null || _targetToGo){
				navigateToURL(new URLRequest(_linkToGo), _targetToGo);
			}else{
				//_navigation.go(_linkToGo);
			}
			
			if(_analyticsToGo){
				URL.analytics(_analyticsToGo);
			}
		}
	}
}