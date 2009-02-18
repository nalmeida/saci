package br.com.project.example.ui.sessions.session3 {
	
	/**
    * @author Marcelo Miranda Carneiro
	*/
	
	import br.com.project.example.data.sessions.ProjectSessionParams;
	import br.com.project.sessions.Session;
	import br.com.project.sessions.vo.SessionInfoVO;
	import flash.display.DisplayObjectContainer;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.text.TextFormat;
	//import saci.font.FontManager;
	import saci.ui.SaciMovieClip;
	
	public class Item extends Session{
		
		private var _params:ProjectSessionParams;
		private var _container:SaciMovieClip;
		private var _over:SaciMovieClip;
		private var _thumbContainer:DisplayObjectContainer;
		private var _textField:TextField;
		
		public function Item($info:SessionInfoVO) {
			super($info);
			_params = new ProjectSessionParams(info.xmlParams);
		}
		
		public function build($container:SaciMovieClip, $over:SaciMovieClip, $textField:TextField):void {
			
			_container = $container;
			
			_thumbContainer = _container.getChildByName("thumbContainer") as DisplayObjectContainer;
			_thumbContainer.removeChildAt(0);
			_thumbContainer.addChild(_loader.bulk.getBitmap(info.id + ".imagem"));
			
			_textField = $textField;
			
			_over = $over;
			_over.stop();
			
			_container.buttonMode = true;
			_container.mouseChildren = false;
			_listenerManager.addEventListener(_container, MouseEvent.ROLL_OVER, _onOver);
			_listenerManager.addEventListener(_container, MouseEvent.ROLL_OUT, _onOut);
			_listenerManager.addEventListener(_container, MouseEvent.CLICK, _onClick);
			_listenerManager.addEventListener(this, ON_ACTIVE, _onActive);
			_listenerManager.addEventListener(this, ON_DEACTIVE, _onDeActive);
			
		}
		
		private function _onClick($e:MouseEvent):void{
			_navigation.go(params.get("destination"));
		}
		private function _onOver($e:MouseEvent = null):void{
			if (_over.parent == null) {
				_container.addChild(_over);
			}
			_over.play();
		}
		private function _onOut($e:MouseEvent):void{
			_over.stop();
			if (_over.parent != null) {
				_container.removeChild(_over);
			}
		}
		
		override protected function _startTransition():void {
			_textField.text = info.id;
			super._startTransition();
		}
		
		//{ animação (iniciada e controlada pela seção pai)
		public function initTransition():void {
			_container.gotoAndPlay(2);
		}
		public function endTransition():void {
			_container.playReverse();
		}
		//}
		
		override public function show():void {}
		override public function hide():void {}
		
		//{ itens ativos
		private function _onActive($e:Event):void{
			_listenerManager.removeEventListener(_container, MouseEvent.ROLL_OVER, _onOver);
			_listenerManager.removeEventListener(_container, MouseEvent.ROLL_OUT, _onOut);
			_listenerManager.removeEventListener(_container, MouseEvent.CLICK, _onClick);
			_onOver(null);
		}
		private function _onDeActive($e:Event):void{
			_listenerManager.addEventListener(_container, MouseEvent.ROLL_OVER, _onOver);
			_listenerManager.addEventListener(_container, MouseEvent.ROLL_OUT, _onOut);
			_listenerManager.addEventListener(_container, MouseEvent.CLICK, _onClick);
			_onOut(null);
		}
		//}
		
		public function get params():ProjectSessionParams { return _params; }
		
	}
	
}
