package saci.ui.carousel
{
	import caurina.transitions.Tweener;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.MouseEvent;
	import saci.util.MathUtil;
	
	public class Carousel extends Sprite
	{
		private var _items:Array;
		private var _data:Array;
		private var _angle:Number = 0;
		private var _id:int = 0;
		private var _reverseOrder:Boolean;
		private var _currentItem:CarouselItem;
		
		private var _validProps:Array = ["offsetX", "offsetY", "scale"];
		
		static public const LOCKED:String = "locked";
		static public const UNLOCKED:String = "unlocked";
		
		public function Carousel()
		{
			_items = new Array();
		}
		
		// Setup
		public function init(assets:Array, reverseOrder:Boolean = false, params:Object = null):void
		{
			_reverseOrder = reverseOrder;
			
			for (var i:int = 0; i < assets.length; i++)
			{
				var asset:Sprite = assets[i] as Sprite;
				var item:CarouselItem = new CarouselItem(asset);
				item.addEventListener(MouseEvent.CLICK, _onItemClick);
				item.id = i;
				item.state = "close";
				
				for (var p:String in params)
				{
					if (_validProps.indexOf(p) != -1)
					{
						item[p] = params[p];
					}
				}
				
				_items.push(item);
				addChild(asset);
			}
			
			_updateItems();
			_setCurrentItem();
		}
		
		// Navigation
		public function previous():void	
		{
			id--;
		}
		public function next():void
		{
			id++;
		}
		
		// animate
		private function _animate(value:Number):void
		{
			_currentItem.state = "close";
			Tweener.addTween(this, { angle:value, onUpdate:_onTweenUpdate, onComplete:_onTweenComplete, time:1, transition:"easeinoutcubic" });
		}
		private function _onTweenUpdate():void
		{
			_updateItems();
		}
		private function _onTweenComplete():void
		{
			_setCurrentItem();
		}
		private function _setCurrentItem():void
		{
			_currentItem = _items[_id];
			_currentItem.state = "open";
			dispatchEvent(new Event(UNLOCKED));
		}
		
		// Update items
		private function _updateItems():void
		{
			var order:Array = new Array();
			
			for (var i:int = 0; i < _items.length; i++)
			{
				var item:CarouselItem = _items[i];
				
				var newAngle:Number = (360 / _items.length) * i;
				if (!_reverseOrder) { newAngle *= -1; }
				item.angle = _angle + newAngle;
				
				order.push({ mc:item.holder, scale:item.holderScale });
			}
			
			// Z axis ordering
			order.sortOn("scale", Array.NUMERIC);
			for (var j:int = 0; j < order.length; j++)
			{
				addChild(order[j].mc);
			}
		}
		private function _onItemClick(e:MouseEvent):void
		{
			id = e.target.id
		}
		
		// ID changed
		private function _onIdChanged():void
		{
			dispatchEvent(new Event(LOCKED));
			
			var item:CarouselItem = _items[_id];
			_angle = MathUtil.normalizeAngle(_angle);
			_animate(_angle - item.angle);
		}
		
		// Getter and setter
		
		public function get id():int { return _id; }
		public function set id(value:int):void
		{
			if (value !== _id)
			{
				_id = value;
				if (_id > _items.length - 1) { _id = 0; }
				if (_id < 0) { _id = _items.length - 1; }
				_onIdChanged();
			}
		}
		
		public function get angle():Number { return _angle; }
		public function set angle(value:Number):void
		{
			if (value !== _angle)
			{
				_angle = value;
			}
		}
		
	}
	
}