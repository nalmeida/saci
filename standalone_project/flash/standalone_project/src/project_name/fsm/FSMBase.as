package project_name.fsm
{
	/**
	@author Marcos Roque (mroque@fbiz.com.br)
	*/
	import caurina.transitions.Tweener;
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.events.EventDispatcher;
	import project_name.ui.base.Base;
	
	public class FSMBase extends EventDispatcher
	{
		protected var _base:Base;
		protected var _aHolder:MovieClip;
		protected var _state:String;
		
		public function FSMBase(animationHolder:MovieClip)
		{
			_base = Base.getInstance();
			_aHolder = animationHolder;
			init();
		}
		
		public function init():void {
			//
		}
		
		/**
		FSM
		*/
		protected function stateChanged():void
		{
			switch (_state)
			{
				case "open":
					animate(_aHolder, { alpha:1, time:0.5 });
					break;
				
				case "close":
					animate(_aHolder, { alpha:0, time:0.2 });
					break;
				
			}
		}
		
		/**
		Animate
		*/
		protected function animate(target:DisplayObject, props:Object):void
		{
			target.visible = true;
			var obj:Object = {
				time:1,
				transition:"linear",
				onComplete:_onCompleteTransition,
				onCompleteParams:[target]
			}
			for (var p:String in props) {
				obj[p] = props[p];
			}
			Tweener.addTween(target, obj);
		}
		protected function _onCompleteTransition(target:DisplayObject):void
		{
			target.visible = target.alpha != 0;
		}
		
		/**
		Getter and setter
		*/
		public function get state():String { return _state; }
		
		public function set state(value:String):void {
			if (value !== _state) {
				_state = value;
				stateChanged();
			}
		}
		
	}
	
}