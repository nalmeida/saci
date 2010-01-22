package redneck.ui.rule
{
	import flash.utils.*;
	import flash.ui.*;
	import flash.display.*;
	import flash.events.*;
	import flash.geom.*;
	import flash.text.*
	public class Rule extends Sprite
	{
		private var _stage : Stage;
		private var _hRule : Bitmap
		private var _vRule : Bitmap
		private var _vRuleBMP : BitmapData
		private var _hRuleBMP : BitmapData
		private var activationKey : int  = Keyboard.SPACE;
		private var _isOn : Boolean
		private var _guides : Dictionary
		private var _currentGuide : Guide;
		private var _ruleSize : int = 10;
		private var _head : int = 0;
		private var _rect : Rectangle = new Rectangle();
		private var _offColor : * = 0;
		private var _onColor : * = 0xffffffff;
		private var _counter : int = 0;
		private var _vBtn : Sprite
		private var _hBtn : Sprite
		private var _txtH : TextField;
		public function Rule( p_stage:Stage ):void
		{
			super();
			_stage = p_stage;
			_stage.addEventListener( KeyboardEvent.KEY_DOWN, checkKey );
			_guides = new Dictionary(true);
			
			_vBtn = addChild(new Sprite()) as Sprite;
			_hBtn = addChild(new Sprite()) as Sprite;
			
			_vRule = _vBtn.addChild (new Bitmap()) as Bitmap;
			_hRule = _hBtn.addChild (new Bitmap()) as Bitmap;
			
			_vRule.y = _ruleSize;
			_hRule.x = _ruleSize;
			
			_txtH = addChild(new TextField()) as TextField;
			_txtH.autoSize = TextFieldAutoSize.CENTER;
			_txtH.text = "redneck"; 
			_txtH.visible = false
			_txtH.blendMode = BlendMode.INVERT;
			_txtH.mouseEnabled = false

			_vBtn.addEventListener(MouseEvent.MOUSE_DOWN, createGuide)
			_hBtn.addEventListener(MouseEvent.MOUSE_DOWN, createGuide)
		}

		private function create():void{
			_stage.addChild(this);
			_stage.addEventListener(Event.RESIZE,resize);
			_stage.addEventListener(MouseEvent.MOUSE_UP, checkGuide)
			resize();
		}

		private function checkKey(e:KeyboardEvent):void{
			if (e.keyCode == activationKey){
				if(_isOn){
					remove();
					_txtH.visible = false
					_isOn = false;
				}else{
					create();
					_txtH.visible = true;
					_isOn = true;
				}
			}else if (e.keyCode == Keyboard.DELETE){
				deleteGuide();
			}
		}

		private function createGuide(e:MouseEvent):void{
			// adding new guide
			_counter++;
			_currentGuide = addChild(new Guide((e.currentTarget == _vBtn))) as Guide
			_currentGuide.id = _counter;
			manageGuide();
		}

		private function updateGuidePosition(e:Event):void{
			if (_currentGuide){
				if (_currentGuide.isVertival){
					_currentGuide.x = _stage.mouseX;
					_txtH.text = "x:" + _currentGuide.x.toString();
				}else{
					_currentGuide.y = _stage.mouseY;
					_txtH.text = "y:" + _currentGuide.y.toString();
				}
			}
		}

		private function manageGuide():void{
			_currentGuide.draw();
			_stage.addEventListener(MouseEvent.MOUSE_UP,checkGuide)
			_stage.addEventListener(Event.ENTER_FRAME, updateGuidePosition)
		}

		private function updateCurrentGuide(e:Event):void{
			_currentGuide = e.currentTarget as Guide;
			manageGuide();
		}

		private function checkGuide(e:Event):void{
			_stage.removeEventListener(Event.ENTER_FRAME, updateGuidePosition);
			_stage.removeEventListener(MouseEvent.MOUSE_UP, checkGuide)
			if (!_currentGuide){
				return;
			}
			if (_currentGuide.isVertival){
				if (_currentGuide.x <= _vBtn.x+_vBtn.width){
					deleteGuide();
					return;
				}
			}else{
				if (_currentGuide.y <= _hBtn.y+_hBtn.height){
					deleteGuide();
					return;
				}
			}
			if (_guides[_currentGuide.id] == _currentGuide){
				return;
			}
			_guides[_currentGuide.id] = _currentGuide;
			_guides[_currentGuide.id].addEventListener(MouseEvent.MOUSE_DOWN, updateCurrentGuide)
			_currentGuide = null;
		}

		private function deleteGuide():void{
			if (_currentGuide){
				if (contains(_currentGuide)){
					removeChild(_currentGuide);
				}
				_currentGuide.removeEventListener(MouseEvent.MOUSE_DOWN, updateCurrentGuide);
				var id : int = _currentGuide.id
				_guides[id] = null;
				delete _guides[id];
				_txtH.text = "redneck";
			}
		}

		private function resize(e:*=null):void{
			if (_vRuleBMP){
				_vRuleBMP.dispose();
			}
			if (_hRuleBMP){
				_hRuleBMP.dispose();
			}
			_txtH.y = _ruleSize;
			_txtH.x = _stage.stageWidth * .5;

			_rect.x = 0;
			_rect.y = 0;
			_rect.width = 0;
			_rect.height = 0;
			_head = 0;
			
			var color : int;
			_hRuleBMP = new BitmapData(_stage.stageWidth, _ruleSize, false, 0xffffffff);
			_rect.width = 1
			_rect.height = _ruleSize;
			do{
				if ( _head%2==0 ){
					color = _onColor;
				}else{
					color = _offColor;
				}
				_rect.x = _head;
				_hRuleBMP.fillRect( _rect, color );
				_head++;
			}
			while(_head<_hRuleBMP.width);
			_hRule.bitmapData = _hRuleBMP;
			
			_rect.x = 0;
			_rect.y = 0;
			_rect.width = 0;
			_rect.height = 0;
			_head = 0;
			
			_vRuleBMP = new BitmapData(_ruleSize, _stage.stageHeight, false, 0xffffffff);
			_rect.width = _ruleSize;
			_rect.height = 1;
			do{
				if ( _head%2==0 ){
					color = _onColor;
				}else{
					color = _offColor;
				}
				_rect.y = _head;
				_vRuleBMP.fillRect( _rect, color );
				_head++;
			}
			while(_head<_vRuleBMP.height);
			_vRule.bitmapData = _vRuleBMP;

			var g:Guide;
			for each(g in _guides){
				g.draw();
			}
		}

		private function remove():void{
			_stage.removeEventListener(Event.ENTER_FRAME, updateGuidePosition)
			_stage.removeEventListener(Event.RESIZE,resize);
			_vRuleBMP.dispose();
			_hRuleBMP.dispose();
			_stage.removeChild(this);
		}
	}
}

