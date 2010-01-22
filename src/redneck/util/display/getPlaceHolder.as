package redneck.util.display
{
	import flash.display.Sprite;
	
	public function getPlaceHolder( p_width:Number, p_height:Number, p_fillColor: int = 0xffffff, p_fillAlpha: Number = 0, p_lineColor:int = 0xff0000, p_lineAlpha:Number = 1 ) : Sprite
	{
		
		var place_holder : Sprite = new Sprite();
			place_holder.graphics.beginFill( p_fillColor,p_fillAlpha );
			place_holder.graphics.drawRect( 0,0,p_width, p_height );
			place_holder.graphics.endFill();
			place_holder.graphics.lineStyle( 1, p_lineColor, p_lineAlpha );
			place_holder.graphics.lineTo( p_width, p_height );
			place_holder.graphics.moveTo( p_width, 0 );
			place_holder.graphics.lineTo( 0, p_height );
			place_holder.graphics.endFill();
			place_holder.graphics.lineStyle( 1, p_lineColor, p_lineAlpha );
			place_holder.graphics.drawRect( 0,0,p_width, p_height );
			place_holder.graphics.endFill();
			
		return place_holder;
	}
}