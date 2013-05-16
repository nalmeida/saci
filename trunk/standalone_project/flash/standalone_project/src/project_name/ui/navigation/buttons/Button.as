package project_name.ui.navigation.buttons {

	/**
	 * @author Marcelo Miranda Carneiro - mcarneiro@fbiz.com.br
	 */
	
	import flash.display.Sprite;
	import flash.geom.Rectangle;
	import flash.display.DisplayObjectContainer;
	
	public class Button extends Sprite {
		
		protected var _holder:Sprite;
		protected var _hitSprite:Sprite;
		protected var _hitAreaElement:Sprite;
		
		protected var _asHolder:Boolean;
		
		public function Button(p_holder:Sprite, p_asHolder:Boolean = false) {
			super();
			
			_holder = p_holder;
			_holder.mouseChildren = false;
			_holder.buttonMode = true;
			_hitAreaElement = _holder.getChildByName("preHitArea") as Sprite;
			
			_asHolder = p_asHolder;

			if(_asHolder){
				mouseEnabled = false;
				mouseChildren = true;
			}
			
			if(_asHolder){
				addChild(_holder);
			}
			setHitArea(_hitAreaElement);
		}
		
		public function setHitArea(p_hitSprite:Sprite = null, p_showHitArea:Boolean = false):void {
			
			if (_hitSprite != null) {
				hitArea = null;
				_holder.removeChild(_hitSprite);
				_hitSprite = null;
			}
			
			_hitSprite = (p_hitSprite == null) ? new Sprite() : p_hitSprite;
			
			if(p_hitSprite == null){
				var hitSpriteCoord:Rectangle = _holder.getBounds(_holder);
				_hitSprite.graphics.beginFill(0x00D6F0);
				_hitSprite.graphics.drawRect(hitSpriteCoord.x, hitSpriteCoord.y, hitSpriteCoord.width, hitSpriteCoord.height);
				_hitSprite.graphics.endFill();
				hitSpriteCoord = null;
			}
			
			if (p_showHitArea) {
				_hitSprite.alpha = .4;
			} else {
				_hitSprite.alpha = 0;
			}
			
			_holder.addChild(_hitSprite);
			_holder.hitArea = _hitSprite;
		}
		
		
		override public function addEventListener(type:String, listener:Function, useCapture:Boolean = false, priority:int = 0, useWeakReference:Boolean = false):void {
			if(!_asHolder){
				_holder.addEventListener(type, listener, useCapture, priority, useWeakReference);
			}else{
				super.addEventListener(type, listener, useCapture, priority, useWeakReference);
			}
		}
		override public function removeEventListener(type:String, listener:Function, useCapture:Boolean = false):void {
			if(!_asHolder){
				_holder.removeEventListener(type, listener, useCapture);
			}else{
				super.removeEventListener(type, listener, useCapture);
			}
		}
		override public function hasEventListener(type:String):Boolean {
			if(!_asHolder){
				return _holder.hasEventListener(type);
			}else{
				return super.hasEventListener(type);
			}
		}
		
		override public function set mouseEnabled(value:Boolean):void	{ _asHolder ? super.mouseEnabled = value 	: _holder.mouseEnabled = value; }
		override public function set buttonMode(value:Boolean):void		{ _asHolder ? super.buttonMode = value 		: _holder.buttonMode = value; }
		override public function set x(value:Number):void				{ _asHolder ? super.x = value 				: _holder.x = value; }
		override public function set y(value:Number):void 				{ _asHolder ? super.y = value 				: _holder.y = value; }
		override public function set width(value:Number):void 			{ _asHolder ? super.width = value 			: _holder.width = value; }
		override public function set height(value:Number):void 			{ _asHolder ? super.height = value 			: _holder.height = value; }
		
		override public function get mouseEnabled():Boolean				{ return _asHolder ? super.mouseEnabled 	: _holder.mouseEnabled; }
		override public function get buttonMode():Boolean				{ return _asHolder ? super.buttonMode 		: _holder.buttonMode; }
		override public function get x():Number							{ return _asHolder ? super.x 				: _holder.x; }
		override public function get y():Number 						{ return _asHolder ? super.y 				: _holder.y; }
		override public function get width():Number 					{ return _asHolder ? super.width 			: _holder.width; }
		override public function get height():Number 					{ return _asHolder ? super.height 			: _holder.height; }
		override public function get parent():DisplayObjectContainer 	{ return _asHolder ? super.parent 			: _holder.parent; }
		public function get holder():Sprite { return _holder; }
	}
}