package br.com.project.example.ui.sessions.session3 {
	
	/**
    * @author Marcelo Miranda Carneiro
	*/
	
	import br.com.project.example.sessions.ProjectSession;
	import br.com.project.sessions.Session;
	import br.com.project.sessions.vo.SessionInfoVO;
	import com.adobe.serialization.json.JSON;
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.events.Event;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.utils.setTimeout;
	import saci.font.Style;
	import saci.ui.SaciMovieClip;
	import saci.util.ClassUtil;
	import saci.util.Logger;
	
	public class Session3 extends ProjectSession{
		
		protected var _container:SaciMovieClip;
		protected var _textField:TextField;
		private var _JSON:Object;
		
		public function Session3($info:SessionInfoVO) {
			super($info);
			_listenerManager.addEventListener(this, Session.COMPLETE_BUILD, _onCompleteBuild);
		}
		
		private function _onCompleteBuild($e:Event):void {
			_listenerManager.removeEventListener(this, Session.COMPLETE_BUILD, _onCompleteBuild);
			
			_container = ClassUtil.cloneClassFromSwf(_loader.bulk.getContent("holder") as DisplayObject, params.get("session")) as SaciMovieClip;
			_JSON = JSON.decode(_loader.bulk.getText("config"));
			
			//{ transition listeners
			_listenerManager.addEventListener(_container, Session.COMPLETE_START_TRANSTITION, _onCompleteStartTransition);
			_listenerManager.addEventListener(_container, Session.COMPLETE_END_TRANSTITION, _onCompleteEndTransition);
			//}
			
			_textField = new TextField();
			_textField.x = _JSON.textfield.x;
			_textField.y = _JSON.textfield.y;
			_textField.width = _JSON.textfield.width;
			_textField.height = _JSON.textfield.height;
			Style.setStyle(_JSON.textfield.style, _textField, null, _JSON.textfield.optValue);
			
			_container.addChild(_textField);
			
			addChild(_container);
			
			// thumbs (tratados como "seção")
			var thumbsContainer:DisplayObjectContainer = _container.getChildByName("itensContainer") as DisplayObjectContainer;
			var i:int = 1;
			var item:Item;
			while (thumbsContainer.getChildByName("thumb" + i) != null) {
				if (children.itens[i-1] != null) {
					item = children.itens[i-1];
					item.build(
						thumbsContainer.getChildByName("thumb" + i) as SaciMovieClip,
						ClassUtil.cloneClassFromSwf(_loader.bulk.getContent("holder") as DisplayObject, params.get("thumbOver")) as SaciMovieClip,
						_textField
					);
				}
				i++;
			}
			
			// start transition after building area
			_startTransition();
		}
		
		//{ transition
		
		override protected function _startTransition():void {
			show();
			var i:int;
			for (i = 0; i < children.itens.length; i++) {
				setTimeout(children.itens[i].initTransition, i * 250);
			}
			_container.gotoAndPlay(Session.START_TRANSTITION);
		}
		private function _onCompleteStartTransition($e:Event):void{
			dispatchEvent(new Event(Session.COMPLETE_START_TRANSTITION));
		}
		override protected function _endTransition():void {
			var i:int;
			for (i = 0; i < children.itens.length; i++) {
				setTimeout(children.itens[i].endTransition, i * 250);
			}
			_container.gotoAndPlay(Session.END_TRANSTITION);
		}
		private function _onCompleteEndTransition($e:Event):void {
			dispatchEvent(new Event(Session.COMPLETE_END_TRANSTITION));
		}
		
		//}
		
		public function get parentContainer():DisplayObjectContainer { return _parentContainer; }
		
	}
	
}
