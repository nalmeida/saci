package redneck.ui {

	import flash.display.*;
	import flash.text.*;
	import flash.events.*;
	import flash.utils.*;
	import flash.geom.*;

	public class DisplayParallax extends Sprite implements IDisposable
	{
		public var slick : Number;
		public var depth : Number;
		public var onlyX:Boolean;
		public var onlyY:Boolean;
		public var keepIn : Boolean;
		public var onChange: Function;
		public var relativeX : Number;
		public var relativeY : Number;

		internal var _target : DisplayObject;
		internal var _refference : DisplayObject;

		/*sets and gets*/
		private var  _isStarted : Boolean
		private var _targetPoint : Point;

		private var boundsRefference : Rectangle;
		private var boundsTarget : Rectangle;
		private var moveOffSet : Point;
		private var offset : Point;
		private var evt : Event

		/**
		*	
		*	
		*	@param	p_reff - refference object
		*	@param	p_target - object to be moved
		*	@param	p_slick	- how smooth is the movement
		*	@param	p_depth - depth field.
		*	
		*	
		**/
		public function DisplayParallax( p_reff:DisplayObject, p_target:DisplayObject, p_slick:Number = .9, p_depth:Number = 1 ):void
		{
			super();

			if ( !p_reff || !p_target || p_target is Stage ){throw new Error ( "invalid parameters!" );}

			depth = p_depth;
			offset = new Point;
			
			_targetPoint	= new Point;
			_refference		= p_reff;
			_target			= p_target;

			updateData( );

			slick = p_slick;
			moveOffSet = new Point( );
			evt = new Event(Event.CHANGE);
		}
		
		public function get isStarted():Boolean{return _isStarted;}

		public function get refference():DisplayObject{return _refference;}
		public function set refference(value:DisplayObject):void
		{
			_refference = value;
			updateData();
		}
		
		public function get target():DisplayObject{return _target;}
		public function set target(value:DisplayObject):void
		{
			_target = value;
			updateData( );
		}

		private function updateData():void{
			boundsRefference = getArea(refference);
			boundsTarget = getArea(target);

			offset.x = boundsTarget.width - boundsRefference.width;
			offset.y = boundsTarget.height - boundsRefference.height;
		}

		private function getArea( p_obj: DisplayObject ):Rectangle{
			if (p_obj){
				var result : Rectangle;
				if ( p_obj is Stage ){
					return new Rectangle( 0,0,(p_obj as Stage).stageWidth,(p_obj as Stage).stageHeight )
				}else{
					return p_obj.getBounds( p_obj );
				}
			}
			return null;
		}
		
		public function start():DisplayParallax{
			_isStarted = true;
			addEventListener( Event.ENTER_FRAME, move, false, 0, true);
			return this;
		}

		public function stop():DisplayParallax{
			_isStarted = false;
			removeEventListener( Event.ENTER_FRAME, move);
			return this
		}

		public function get targetPointX():Number{return _targetPoint.x;}
		public function set targetPointX(value:Number):void
		{
			_targetPoint.x = value;
			update( );
		}

		public function get targetPointY():Number{return _targetPoint.y;}
		public function set targetPointY(value:Number):void{
			_targetPoint.y = value;
			update( );
		}

		private function move(e:Event):void{
			_targetPoint.x = refference.mouseX;
			_targetPoint.y = refference.mouseY;
			update( );
		}

		private function update(  ):void{

			relativeX = (keepIn ? Math.min( boundsRefference.width, targetPointX ) : targetPointX );
			relativeY = (keepIn ? Math.min( boundsRefference.height, targetPointY ) : targetPointY );

			relativeX /= depth;
			relativeY /= depth;

			render( );
		}

		public function render():DisplayParallax{
			if ( refference && target) ;
			{
				if (offset.x+offset.y>0)
				{
					moveOffSet.x = relativeX / boundsRefference.width * offset.x * -1;
					moveOffSet.y = relativeY / boundsRefference.height * offset.y * -1;

					moveOffSet.x = moveOffSet.x - (moveOffSet.x - target.x) * slick;
					moveOffSet.y = moveOffSet.y - (moveOffSet.y - target.y) * slick;

					if(!onlyY){
						target.x = moveOffSet.x;
					}
					if(!onlyX){
						target.y = moveOffSet.y;
					}
				}
				if (onChange!=null){
					onChange.apply( null, [this] );
				}
				dispatchEvent( evt.clone( ) );
			}
			return this;
		}

		public function dispose( ...rest ):void{
			stop();
		}
	}
}
