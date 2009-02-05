package br.com.project.ui.sessions.session1 {
	
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
	
	public class Session1 extends Session{
		
		protected var _parentContainer:DisplayObjectContainer;
		private var libTransition:SaciMovieClip;
		
		public function Session1($info:SessionInfoVO) {
			_parentContainer = DocumentUtil.documentClass;
			super($info);
			_hide();
			
			_listenerManager.addEventListener(this, Session.COMPLETE_BUILD, _onCompleteBuild);
			_listenerManager.addEventListener(_loader.bulk, ErrorEvent.ERROR, _loadError);
			_listenerManager.addEventListener(_loader, SaciBulkLoader.SHOW_LOADER, _showLoaderIcon);
			_listenerManager.addEventListener(_loader, SaciBulkLoader.HIDE_LOADER, _hideLoaderIcon);
		}
		
		private function _loadError($e:ErrorEvent):void {
			Logger.logError("[Session1._loadError] error loading area");
		}
		private function _onCompleteBuild($e:Event):void {
			_listenerManager.removeEventListener(this, Session.COMPLETE_BUILD, _onCompleteBuild);
			_parentContainer.addChild(this);
			
			var botao1:Sprite = new Sprite();
			var imagem1:Bitmap = _loader.bulk.getContent("imagem1") as Bitmap;
			Logger.log(_loader.bulk.getContent("imagem1"));
			Logger.log(imagem1);
			imagem1.width = 200;
			imagem1.scaleY = imagem1.scaleX;
			botao1.addChild(imagem1);
			
			var botao2:Sprite = new Sprite();
			var imagem2:Bitmap = _loader.bulk.getContent("imagem2") as Bitmap;
			imagem2.x = imagem1.x + imagem1.width + 10;
			imagem2.width = 200;
			imagem2.scaleY = imagem2.scaleX;
			botao2.addChild(imagem2);

			var botao3:Sprite = new Sprite();
			var imagem3:Bitmap = _loader.bulk.getContent("imagem3") as Bitmap;
			imagem3.width = 200;
			imagem3.scaleY = imagem3.scaleX;
			imagem3.x = imagem2.x + imagem2.width + 10;
			botao3.addChild(imagem3);
			
			var botao4:Sprite = new Sprite();
			var imagem4:Bitmap = _loader.bulk.getContent("imagem4") as Bitmap;
			imagem4.width = 200;
			imagem4.scaleY = imagem4.scaleX;
			imagem4.x = imagem3.x + imagem3.width + 10;
			botao4.addChild(imagem4);
			
			botao1.buttonMode = botao2.buttonMode = botao3.buttonMode = botao4.buttonMode = true;
			_listenerManager.addEventListener(botao1, MouseEvent.CLICK, _go1);
			_listenerManager.addEventListener(botao2, MouseEvent.CLICK, _go2);
			_listenerManager.addEventListener(botao3, MouseEvent.CLICK, _go3);
			_listenerManager.addEventListener(botao4, MouseEvent.CLICK, _go4);
			
			addChild(botao1);
			addChild(botao2);
			addChild(botao3);
			addChild(botao4);

			var transitionMc:MovieClip = _loader.bulk.getContent("movieclip1") as MovieClip;
			libTransition = new (transitionMc.loaderInfo.applicationDomain.getDefinition(info.xmlParams.linkage[0].@value.toString()) as Class) as SaciMovieClip;
			_listenerManager.addEventListener(libTransition, Session.COMPLETE_END_TRANSTITION, _hide);
			_listenerManager.addEventListener(libTransition, Session.COMPLETE_START_TRANSTITION, _completeStartTransition);
			libTransition.y = 300;
			libTransition.gotoAndStop(1);
			
			var fld:TextField = libTransition.getChildByName("fld") as TextField;
			
			fld.text = info.id;
			
			addChild(libTransition);
			
			// start transition after building area
			_startTransition();
		}
		
		private function _go1(e:MouseEvent):void {
			_navigation.go("session1");
		}
		private function _go2(e:MouseEvent):void {
			_navigation.go("session2");
		}
		private function _go3(e:MouseEvent):void {
			_navigation.go("sub-area1");
		}
		private function _go4(e:MouseEvent):void {
			_navigation.go("sub-area2");
		}
		
		override protected function _startTransition():void {
			show();
			libTransition.gotoAndPlay("startTransition");
		}
		override protected function _endTransition():void {
			libTransition.gotoAndPlay("endTransition");
		}
		
		private function _completeStartTransition($e:Event = null):void {
			dispatchEvent(new Event(Session.COMPLETE_START_TRANSTITION));
		}
		private function _hide($e:Event = null):void {
			hide();
			super._endTransition();
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
