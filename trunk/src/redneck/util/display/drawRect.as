/*inspired on lucas dupin's drawRect, just a alpha parameter has benn added*/
package redneck.util.display {
	public function drawRect(	p_display : *, p_x:Number = 0, p_y:Number=0, p_width:Number = 10, p_height:Number = 10, p_color:int = 0xff0000, p_alpha:Number = 1 ):void{
		if (p_display && p_display.hasOwnProperty("graphics")){
			p_display.graphics.beginFill(p_color,p_alpha);
			p_display.graphics.drawRect(p_x,p_y,p_width,p_height);
			p_display.graphics.endFill();
		}
	}
}

