package saci.ui {
	
	import flash.text.*;
	import flash.display.*;
	import flash.events.*;
	import flash.geom.Rectangle;
	
	/**
	 * Classe para adicionar de maneira fácil eventos básicos de botão (click, over e out). Extende SaciMovieClip.
	 * @author Nicholas Almeida
	 * @since	23/1/2009 16:02
	 */
	public class SaciLazyButton extends SaciMovieClip{
		
		public var onClickHandler:Function;
		public var onOverHandler:Function;
		public var onOutHandler:Function;
		public var hitSprite:Sprite;
		
		/**
		 * Cria uma nova instancia de SaciLazyButton.
		 * @param	$onClickHandler	Handler de MouseEvent.CLICK que será adicionado ao ListenerManager
		 * @param	$onOverHandler	Handler de MouseEvent.ROLL_OVER que será adicionado ao ListenerManager
		 * @param	$onOutHandler	Handler de MouseEvent.ROLL_OUT que será adicionado ao ListenerManager
		 */
		public function SaciLazyButton($onClickHandler:Function = null, $onOverHandler:Function = null, $onOutHandler:Function = null) {
			super();
			
			onClickHandler = $onClickHandler;
			onOverHandler = $onOverHandler;
			onOutHandler = $onOutHandler;
			
			super.mouseEnabled = 
			super.buttonMode = true;
			super.mouseChildren = false;
			
			if(onClickHandler != null)
				super._listenerManager.addEventListener(super, MouseEvent.CLICK, onClickHandler);
				
			if(onOverHandler != null)
				super._listenerManager.addEventListener(super, MouseEvent.ROLL_OVER, onOverHandler);
				
			if(onOutHandler != null)
				super._listenerManager.addEventListener(super, MouseEvent.ROLL_OUT, onOutHandler);
		}
		
		/**
		 * Escolhe uma hitarea espcífica para o botão. Caso não receba nenhum parâmetro, cria um sprite retangular com as medidas do SaciLazyButton.
		 * @param	$hitSprite	Sprite que será usado como hitArea
		 * @param	$showHitArea	Se deve (para debug) ou não exibir o sprite usado como hitArea
		 */
		public function setHitArea($hitSprite:DisplayObjectContainer = null, $showHitArea:Boolean = false):void {
			
			if (hitSprite != null) {
				super.removeChild(hitSprite);
				hitSprite = null;
			}
			
			hitSprite = ($hitSprite == null) ? new Sprite() : $hitSprite as Sprite;
			
			if($hitSprite == null){
				var hitSpriteCoord:Rectangle = super.getRect(super);
				hitSprite.graphics.beginFill(0xFF0000);
				hitSprite.graphics.drawRect(hitSpriteCoord.x, hitSpriteCoord.y, hitSpriteCoord.width, hitSpriteCoord.height);
				hitSprite.graphics.endFill();
				hitSpriteCoord = null;
			}
			
			if ($showHitArea) {
				hitSprite.alpha = .4;
			} else {
				hitSprite.alpha = 0;
			}
			
			super.addChild(hitSprite);
			super.hitArea = hitSprite;
		}
		
	}
	
}