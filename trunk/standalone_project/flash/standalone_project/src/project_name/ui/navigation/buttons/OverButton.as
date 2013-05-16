package project_name.ui.navigation.buttons {
	
	/**
	 * @author Marcelo Miranda Carneiro - mcarneiro@fbiz.com.br
	 */
	
	import flash.display.MovieClip;
	import flash.events.MouseEvent;
	
	public class OverButton extends ProjectButton {
		
		protected var _holderMc:MovieClip;
		
		public function OverButton(p_holder:MovieClip, p_asHolder:Boolean = false) {
			_holderMc = p_holder;
			_holderMc.stop();
			super(p_holder, p_asHolder);
			addHandlers();
		}
		
		protected function _onOver(e:MouseEvent):void{
			_holderMc.gotoAndPlay("over");
		}
		protected function _onOut(e:MouseEvent):void{
			_holderMc.gotoAndPlay("out");
		}
		
		public function addHandlers():void {
			_listenerManager.addEventListener(_holder, MouseEvent.ROLL_OVER, _onOver);
			_listenerManager.addEventListener(_holder, MouseEvent.ROLL_OUT, _onOut);
		}
		public function removeHandlers():void {
			_listenerManager.removeEventListener(_holder, MouseEvent.ROLL_OVER, _onOver);
			_listenerManager.removeEventListener(_holder, MouseEvent.ROLL_OUT, _onOut);
		}
		
		public function get holderMc():MovieClip { return _holderMc; }
		
	}
}