/*recursive remove*/
package redneck.util.display {
	import flash.display.*;
	public function safeRemoveChildren( who:DisplayObjectContainer ):Boolean
	{
		if (!who){return false}
		var count:int = who.numChildren;
		try{
			while( count-- ){
				var obj : DisplayObject = who.getChildAt( count );
				if ( obj is MovieClip && MovieClip(obj).totalFrames>1 ){
					MovieClip(obj).stop();
				}else if( (obj is DisplayObjectContainer) ){
					safeRemoveChildren( DisplayObjectContainer( obj )  );
				}else if (obj is DisplayObject){
					safeRemoveChild( obj );	
				}
			}

		if (!(who is Stage)){
			safeRemoveChild( who );
		}

		}catch(e:Error){
			trace("error removing child "+this+"!" + e.getStackTrace());
			return false;
		}
		return true;
	}
}

