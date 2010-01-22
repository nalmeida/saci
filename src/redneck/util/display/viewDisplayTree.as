/**
 * 
 * @author igor almeida
 * @version 0.1
 * 
 * */
package redneck.util.display
{
	import flash.display.DisplayObjectContainer;
	public function viewDisplayTree( who:DisplayObjectContainer , level:int = 0 ) : String
	{
		var inspect : displayInspect = new displayInspect( who, level );
		var result : String = inspect.data
		inspect = null;
		return result;	
	}
}
import flash.display.DisplayObjectContainer;
import redneck.util.string.repeat;
internal class displayInspect
{
	public var data : String;
	internal var recLevel : int;
	internal var tab : int;
	public function displayInspect( who:DisplayObjectContainer, level:int ) : void
	{
		recLevel = level;
		data = who.name + " (" +who.numChildren+ ")";
		inspect( who );
	}
	private function inspect ( child : DisplayObjectContainer) : void
	{
		var childs : int = child.numChildren
		tab++;
		while ( childs-- )
		{
			var obj : * = child.getChildAt( childs );
			data += "\n" + repeat("  ", tab) + (obj is DisplayObjectContainer && obj.numChildren > 0 ? "+ " : "- " ) + obj.name; 
			if ( obj is DisplayObjectContainer && (tab < recLevel || recLevel == 0 ))
			{
				data += " (" + obj.numChildren + ") "
				inspect( obj );
			}
		}
		tab--;	
	}
}