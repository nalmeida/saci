/*inspired at lucas dupin's safeRemoveChild*/
package redneck.util.display {
	import flash.display.*;
	public function safeRemoveChild( who:* ) : Boolean
	{
		try
		{
			if (who && who.hasOwnProperty("parent") && who.parent.hasOwnProperty("contains") && who.parent.contains(who)){
				who.parent.removeChild( who )
			}
		} 
		catch (e:Error){
			trace("safeRemoveChild::safeRemoveChild() error removing child'"+who+"'");
			return false;
		}
		return true
	}
}

