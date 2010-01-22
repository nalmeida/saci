package redneck.util.display {

	import flash.display.*;
	public function getMovieClipCast( movieclip:MovieClip, max_frames:Number = NaN ) : Array
	{
		var result : Array = new Array;

		//check params
		if (!movieclip){return result;}
		
		/*first stop*/
		movieclip.stop();
		
		/*check frames*/
		var frames : int = movieclip.totalFrames;
		frames = isNaN(max_frames)? frames : Math.min(frames,max_frames);
		
		/*cast array*/
		var count : int = 0
		while(count<frames){
			movieclip.gotoAndStop(count+1);
			result.push( getBitmap( movieclip ) );
			count++;
		}
		return result;
	}
}

