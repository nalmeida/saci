package redneck.ui.rule
{
	import flash.display.*;
	public class Guide extends Sprite
	{
		public var id :int;
		public var isVertival : Boolean;
		private var _stroke : int = 2;
		public function Guide( p_verital : Boolean = true  )
		{
			super( );
			isVertival = p_verital
			draw( );
			this.blendMode = BlendMode.INVERT;
			buttonMode = true;
		}
		public function draw():void{
			if (!stage){
				return;
			}
			graphics.clear();
			graphics.beginFill(0xffff00,0)
			if (isVertival){
				graphics.drawRect(-_stroke,0,_stroke*2,stage.stageHeight);
			}else{ 
				graphics.drawRect(0,-_stroke,stage.stageWidth,_stroke*2);
			}
			graphics.endFill();
			graphics.lineStyle(.1,0xff0000,1);
			graphics.moveTo(0,0);
			if (isVertival){
				graphics.lineTo(0,stage.stageHeight);
			}else{
				graphics.lineTo(stage.stageWidth,0);
			}
			graphics.endFill();
		}
	}
}

