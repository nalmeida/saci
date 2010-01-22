package redneck.util {
	import flash.events.*;
	import flash.display.*;
	import flash.geom.*;
	import flash.utils.getTimer
	import flash.text.*;
	public class MouseWatcher extends Sprite{
		public static const STOP:String = "STOP";
		public static const MOVE:String = "MOVE";
		private var _speed : Number
		private var _isStoped : Boolean;
		private var _degree : Number;
		private var _radian : Number;
		private var _currentPosition : Point;
		private var _lastPosition: Point;
		private var _stage : Stage;
		private var _lastTime : int;
		private var _distance : Number
		private var arrow : Sprite;
		private var info : TextField;
		private var fmt : TextFormat
		public function MouseWatcher(stage:Stage)
		{
			super();
			_stage = stage;
			_currentPosition = new Point()
			_lastPosition = new Point();
			
			graphics.beginFill(0xffffff)
			graphics.drawRect( 0,0,80,100 )
			graphics.endFill();
			arrow = new Sprite();
			with (arrow.graphics)
			{
				beginFill(0xff0000);
				drawRect(-1,-10,2,20)
				endFill();
				beginFill(0);
				drawCircle(0,0,1);
				endFill();
				beginFill(0xff0000);
				drawCircle(0,8,2);
				endFill();
				beginFill(0xffff00)
				drawRect( -1,-10,2,2);
				endFill();
			}
			addChild(arrow);
			arrow.x = 80*.5;
			arrow.y = 20;
			
			fmt = new TextFormat( );
			fmt.size = 8;
			fmt.font = "Courier";
			info = new TextField( );
			info.autoSize = TextFieldAutoSize.LEFT;
			info.defaultTextFormat = fmt;
			info.width = 80;
			addChild(info)
			info.y = 45;
		}
		public function get currentPosition():Point
		{
			return _currentPosition;
		}
		public function get lastPosition():Point
		{
			return _lastPosition;
		}
		public function get speed():Number
		{
			return _speed;
		}
		public function get isStoped():Boolean
		{
			return _isStoped;
		}
		public function get degree():Number
		{
			return _degree;
		}
		public function get radian():Number
		{
			return _radian;
		}
		public function get distance():Number
		{
			return _distance;
		}
		public function start():void{
			_lastTime = 0;
			_lastPosition.x = _stage.mouseX;
			_lastPosition.y = _stage.mouseY;
			_stage.addEventListener(Event.ENTER_FRAME,check,false,0,true)
		}
		public function stop():void{
			_stage.removeEventListener(Event.ENTER_FRAME,check)
		}
		private function check(e:Event):void
		{
			_lastTime = getTimer( ) - _lastTime;
			_currentPosition.x = _stage.mouseX;
			_currentPosition.y = _stage.mouseY;
			_distance = Point.distance(_lastPosition,_currentPosition);
			_isStoped =  _distance == 0;
			_speed = _distance / ( _lastTime * 0.0001);
			_radian = Math.atan2(lastPosition.x-currentPosition.x,lastPosition.y-currentPosition.y)*-1;
			_degree = _radian * 180 / Math.PI;
			if (stage){
				updateView();
			}
			if (isStoped){
				dispatchEvent(new Event(MousePeeker.STOP))
			}else{
				dispatchEvent(new Event(MousePeeker.MOVE))
			}
			_lastPosition.x  = _currentPosition.x
			_lastPosition.y = _currentPosition.y
		}
		private function updateView():void{
			info.text = stats;
			arrow.rotation = degree;
		}
		public function get stats():String{
			return "distance:"+distance+"\nspeed:"+speed+"\radian:"+radian+"\ndegree:"+degree+"\nisStoped:"+isStoped+"\n";
		}
	}
}

