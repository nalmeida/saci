package saci.ui.carousel
{
	
	import flash.events.EventDispatcher;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import saci.util.MathUtil;
	import flash.filters.BlurFilter;
	
	public class CarouselItem extends EventDispatcher
	{
		private var _holder:Sprite;
		private var _angle:Number;
		private var _holderScale:Number;
		private var _holderBlur:Number;
		private var _id:int;
		private var _state:String;
		
		private var _offsetX:Number = 250;
		private var _offsetY:Number = 0;
		private var _scale:Number = 0.5;
		private var _blur:Number = 8;
		
		public function CarouselItem(holder:Sprite)
		{
			super();
			_holder = holder;
			_addButton();
		}
		
		private function _addButton():void
		{
			_holder.addEventListener(MouseEvent.CLICK, _onClick);
		}
		private function _onClick(e:MouseEvent):void
		{
			dispatchEvent(e);
		}
		
		// Update angle
		private function _updateAngle():void
		{
			// Math
			var rad:Number = (_angle + 90) * Math.PI / 180;
			var cos:Number = Math.cos(rad);
			var sin:Number = Math.sin(rad);
			var depth:Number = (sin + 1) / 2;
			
			// Position
			_holder.x = _offsetX * cos;
			_holder.y = _offsetY * sin;
			//_holder.x = _offsetX * ((cos - 1) / 2);
			//_holder.y = _offsetY * sin;
			
			// Scale
			_holderScale = _scale + (1 - _scale) * depth;
			_holder.scaleX = _holder.scaleY = _holderScale;
			
			// Blur
			var depthBlur:Number = 1 - depth;
			var blurFilter:BlurFilter = new BlurFilter(_blur * depthBlur, _blur * depthBlur);
			_holder.filters = [blurFilter];
		}
		
		// FSM
		private function _onStateChanged():void
		{
			switch (_state)
			{
				case "open":
					_holder.mouseChildren = true;
					break;
					
				case "close":
					_holder.mouseChildren = false;
					break;
					
			}
		}
		
		// Getter and setter
		
		public function get holder():Sprite { return _holder; }
		public function get holderScale():Number { return _holderScale; }
		
		public function set offsetX(value:Number):void { if (value !== _offsetX) { _offsetX = value; } }
		public function set offsetY(value:Number):void { if (value !== _offsetY) { _offsetY = value; } }
		public function set scale(value:Number):void { if (value !== _scale) { _scale = value; } }
		public function set blur(value:Number):void { if (value !== _blur) { _blur = value; } }
		
		public function get state():String { return _state; }
		public function set state(value:String):void
		{
			if (value !== _state)
			{
				_state = value;
				_onStateChanged();
			}
		}
		
		public function get angle():Number { return _angle; }
		public function set angle(value:Number):void
		{
			if (value !== _angle)
			{
				_angle = value;
				_updateAngle();
				_angle = MathUtil.normalizeAngle(_angle);
			}
		}
		
		public function get id():int { return _id; }
		public function set id(value:int):void
		{
			if (value !== _id)
			{
				_id = value;
			}
		}
		
	}
	
}