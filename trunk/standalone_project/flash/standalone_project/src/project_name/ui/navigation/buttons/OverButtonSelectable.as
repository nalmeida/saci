package project_name.ui.navigation.buttons {
	
	/**
	 * @author Marcelo Miranda Carneiro - mcarneiro@fbiz.com.br
	 */
	
	import flash.display.MovieClip;
	import caurina.transitions.Tweener;
	
	public class OverButtonSelectable extends OverButton {
		
		private var _state:String = "unselected";
		private var _visibility:Boolean = true;
		
		public function OverButtonSelectable(p_holder:MovieClip, p_asHolder:Boolean = false) {
			super(p_holder, p_asHolder);
			addHandlers();
		}
		
		private function stateChanged():void
		{
			switch (_state)
			{
				case "selected":
					_holderMc.gotoAndPlay("selected");
					removeHandlers();
					break;
				
				case "unselected":
					_holderMc.gotoAndPlay("unselected");
					addHandlers();
					break;
				
			}
		}
		
		private function visibilityChanged():void
		{
			_holderMc.visible = true;
			var _alpha:Number;
			switch (_visibility)
			{
				case true:
					_alpha = 1;
					break;
				
				case false:
					_alpha = 0;
					break;
				
			}
			
			Tweener.addTween(_holderMc, { alpha:_alpha, time:.5, transition:"linear", onComplete:_onCompleteAlpha } );
		}
		public function _onCompleteAlpha():void
		{
			_holderMc.visible = _visibility;
		}
		
		public function get state():String { return _state; }
		public function set state(value:String):void {
			if (value !== _state) {
				_state = value;
				stateChanged();
			}
		}
		
		public function get visibility():Boolean { return _visibility; }
		public function set visibility(value:Boolean):void {
			if (value !== _visibility) {
				_visibility = value;
				visibilityChanged();
			}
		}
		
	}
}