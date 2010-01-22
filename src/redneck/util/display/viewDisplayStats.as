package redneck.util.display
{
	import flash.display.DisplayObject;
	import flash.geom.Rectangle;
	
	public function viewDisplayStats( who : DisplayObject ) : String
	{
		var report:String = "********************************";
		report += "\n" + who + " name: " + who.name;
		report += "\n visible: " +  who.visible;
		report += "\n alpha: " +  who.alpha;
		report += "\n scaleX: " +  who.scaleX;
		report += "\n scaleY: " +  who.scaleY;
		report += "\n width: " +  who.width;
		report += "\n height: " +  who.height;
		report += "\n x: " +  who.x;
		report += "\n y: " +  who.y;
		report += "\n on the top?  " + (who.parent.getChildIndex( who ) >= who.parent.numChildren-1 ) ;
		report += "\n has stage? " + (who.stage!=null);
		report += "\n out of screen? " + (who.stage ? !new Rectangle(0,0,who.stage.stageWidth, who.stage.stageHeight).containsRect( who.getRect( who.stage ) ) : false );
		report += "\n********************************";
		return report;
	}
}