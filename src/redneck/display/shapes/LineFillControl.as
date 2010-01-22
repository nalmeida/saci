/**
* 
* @author igor almeida
* version 1.0
*
**/
package redneck.display.shapes
{
	import flash.display.*
	import flash.geom.*
	[Bindable]
	public class LineFillControl extends FillControl
	{	
		/****/
		public function LineFillControl():void{super();}

		/**
		*	
		*	@public
		*	
		*	@see Graphics.lineStyle
		*	
		**/
		internal var _miterLimit:Number = 3;
		public function get miterLimit():Number{return _miterLimit;}
		public function set miterLimit(value:Number):void
		{
			_miterLimit = value;
			change();
		}

		/**
		*	
		*	@public
		*	
		*	@see Graphics.lineStyle
		*	
		**/
		internal var _joints:String;
		public function get joints():String{return _joints;}
		public function set joints(value:String):void
		{
			_joints = value;
			change();
		}
		
		/**
		*	
		*	@public
		*	
		*	@see Graphics.lineStyle
		*	
		**/
		internal var _caps:String
		public function get caps():String{return _caps;}
		public function set caps(value:String):void
		{
			_caps = value;
			change();
		}
		
		/**
		*	
		*	@public
		*	
		*	@see Graphics.lineStyle
		*	
		**/
		internal var _scaleMode:String = "normal";
		public function get scaleMode():String{return _scaleMode;}
		public function set scaleMode(value:String):void
		{
			_scaleMode = value;
			change();
		}

		/**
		*	
		*	@public
		*	
		*	@see Graphics.lineStyle
		*	
		**/
		internal var _stroke : Number = 0;
		public function get stroke():Number{return _stroke;}
		public function set stroke(value:Number):void
		{
			_stroke = value;
			change();
		}

		/**
		*	
		*	@public
		*	
		*	@see Graphics.lineStyle
		*	
		**/
		internal var _pixelHinting:Boolean;
		public function get pixelHinting():Boolean{return _pixelHinting;}
		public function set pixelHinting(value:Boolean):void
		{
			_pixelHinting = value;
			change();
		}
	}
}