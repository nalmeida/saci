package project_name.ui.loader {
	
	/**
    * @author Marcelo Miranda Carneiro
	*/
	
	import caurina.transitions.Tweener;
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.display.DisplayObjectContainer;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import saci.ui.SaciSprite;
	import flash.text.TextField;
	
	public class LoaderIcon extends EventDispatcher{
		
		public const SHOW_COMPLETE:String = "showComplete";
		public const HIDE_COMPLETE:String = "hideComplete";
		public const SHOW_START:String = "showStart";
		public const HIDE_START:String = "hideStart";
		
		private var _json:Object;
		private var _parent:DisplayObjectContainer;
		private var _container:MovieClip;
		private var _mask:MovieClip;
		private var _guideMask:MovieClip;
		private var _aligner:DisplayObject;
		private var _percent:TextField;

		private var _dummyBg:SaciSprite;
		
		private var _visible:Boolean;
		
		public function LoaderIcon($parent:DisplayObjectContainer, $container:MovieClip, $json:Object = null):void {
			
			_dummyBg = new SaciSprite();
			
			_parent = $parent;
			_container = $container;
			_json = $json || {
				bgColor: "0xFFFFFF",
				bgOpacity: "0.5",
				time: 1
			};
			
			_mask = _container.mask_mc;
			_guideMask = _container.guideMask_mc;
			
			_aligner = _container.getChildByName("aligner");
			_percent = _container.getChildByName("percent_txt") as TextField;
			
			update();
		}
		
		private function _drawBg($e:Event = null):void {
			_dummyBg.graphics.clear();
			_dummyBg.graphics.beginFill(uint(_json.bgColor), _json.bgOpacity);
			_dummyBg.graphics.drawRect(0, 0, _parent.stage.stageWidth, _parent.stage.stageHeight);
			_dummyBg.graphics.endFill();
		}
		public function update():void{
			_drawBg();
			_container.x = _parent.stage.stageWidth / 2;
			_container.y = _parent.stage.stageHeight / 2;
		}
		
		private function _initTransition():void {
			if (_container.stage == null) {
				_parent.addChild(_dummyBg);
				_parent.addChild(_container);
			}
			
			_dummyBg.alpha = _container.alpha = 0;
			_dummyBg.visible = _container.visible = true;
		}
		private function _showComplete():void {
			_dummyBg.alpha = _container.alpha = 1;
			dispatchEvent(new Event(SHOW_COMPLETE));
			_visible = true;
		}
		private function _hideComplete():void {
			_container.alpha = 0;
			_dummyBg.visible = _container.visible = false;
			
			if (_container.stage != null) {
				_parent.removeChild(_dummyBg);
				_parent.removeChild(_container);
			}
			dispatchEvent(new Event(HIDE_COMPLETE));
			_visible = false;
		}
		
		public function refreshPercent($percent:Number):void {
			if (!_percent) { return; }
			_percent.text = Math.floor($percent * 100) + "%";
		}
		public function show($fx:Boolean = true):void {
			dispatchEvent(new Event(SHOW_START));
			refreshPercent(0);
			_initTransition();
			if ($fx === true) {
				
				Tweener.addTween([_container,_dummyBg], {
					alpha: 1,
					time: _json.time,
					onComplete: _showComplete
				});
				
			}else {
				_showComplete();
			}
		}
		public function hide($fx:Boolean = true):void {
			dispatchEvent(new Event(HIDE_START));
			_initTransition();
			if ($fx === true) {
				
				Tweener.addTween([_container,_dummyBg], {
					alpha: 0,
					time: _json.time,
					onComplete: _hideComplete
				});
				
			}else {
				_hideComplete();
			}
		}
		
		public function get container():MovieClip { return _container; }
		
		public function get parent():DisplayObjectContainer { return _parent; }
		public function set parent(value:DisplayObjectContainer):void {
			_parent = value;
		}
		
		public function set visible($value:Boolean):void {
			if (_visible === true) {
				show(false);
			} else {
				hide(false);
			}
		}
		public function get visible():Boolean { return _visible; }
		
		public override function toString():String {
			return "[LoaderIcon]";
		}
	}
}