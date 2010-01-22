/**
*
*	@author igor almeida
*	@version 1.0

	todo: testar mc com unico frame (eventos de change principalmente)
	todo: runonce
**/
package redneck.display {

	import flash.display.*;
	import flash.events.*;
	import flash.utils.*;
	
	import redneck.util.display.getBitmapData;

	public class SuperMovieClip extends Sprite {
		
		// dispatched when the playehead leaves the <code>currentFrame</code>
		[Event(name="onFrameChange", type="redneck.display.SuperMovieClip")]
		public static const ON_FRAME_CHANGE : String = "onFrameChange";
		private const FRAME_CHANGE : Event = new Event( ON_FRAME_CHANGE );

		[Event(name="onLoop", type="redneck.display.SuperMovieClip")]
		public static const ON_LOOP : String = "onLoop";
		private const LOOP : Event = new Event( ON_LOOP );

		[Event(name="onCastComplete", type="redneck.display.SuperMovieClip")]
		public static const ON_CAST_COMPLETE : String = "onCastComplete";
		private const CAST_COMPLETE : Event = new Event( ON_CAST_COMPLETE );

		/*loop callback. when the playehead leaves the last frame and goes to the first frame*/
		public var onLoop : Function;
		/*finish castin callback. this callback runs only when <code>cast</code> has called*/
		public var onCastComplete : Function;
		/*frame change callback, when the playehead leaves any frame*/
		public var onFrameChange : Function;
		/**
		*	
		*	Amount of frames to wait before changing the current frame.
		*	
		*	@usage 
		*	var s : SuperMovieClip = new SuperMovieClip();
		*		s.cast( myMovieClip );
		*		s.frameRate = 5;
		*		s.play();
		*	
		*	It means that the playhead will wait 5 <code>Event.ENTER_FRAME</code> events before changing the <code>currentFrame</code>
		*	
		**/
		public var frameRate : int;
		/* internal frame delay control*/
		private var currentDelay : int;
		/*casting timer instance*/
		private var _timer : Timer;
		/*frames with scripts*/
		private var _frameScripts : Object
		/*internal var to check passed frames parameters*/
		private var _frame : int;
		/**
		*	
		*	Creates a SuperMovieClip instance.
		*	This MovieClip will be empty until an <code>addFrame</code> or <code>cast</code> be called.
		*	
		*	@see addFrame
		*	@see cast
		*	
		*	@param pixelSnapping
		*	@param smoothing
		*	
		**/
		public function SuperMovieClip( pixelSnapping:String = "auto", smoothing:Boolean = false ) : void
		{
			super();
			_display =  addChild( new Bitmap( null, pixelSnapping, smoothing ) ) as Bitmap;
			_bitmapList = new Array();
			_frameLabels = new Object();
			_frameScripts = new Object();
		}
		
		/*[read only] array that contanis all <code>BitmapData</code>*/
		private var _bitmapList : Array
		public function get bitmapList():Array{return _bitmapList;}

		/*[read only] total frames @see bitmapList*/
		public function get totalFrames():int{return _bitmapList.length}
		
		/*[read only] current playehead frame*/
		private var _currentFrame : int;
		public function get currentFrame():int{return _currentFrame;}
		
		/*object with all saved labels. When an <code>addFrame</code> or <code>cast</code> is called it gets the labels from your <code>MovieClip</code> or you can also add a brand new one using the <code>addLabel</code>*/
		private var _frameLabels : Object
		public function get frameLabels():Object{return _frameLabels;}

		/*just a flag from the playhead status*/
		private var _isPlaying : Boolean;
		public function get isPlaying():Boolean{return _isPlaying;}

		/*<code>Bitmap</code> that shows the frames*/
		private var _display : Bitmap;
		public function get display():Bitmap{return display;}
		
		/*returns if the casting still working*/
		private var _castIsFinished : Boolean
		public function get castIsFinished():Object{return _castIsFinished;}

		private var castingIndex : int;
		private var castFrames : int;
		private var movieclip : MovieClip
		/**
		*	
		*	Copy <code>frames</code> as <code>BitmapData</code> from <code>display</code>
		*	
		*	@param	display	MovieClip	source to copy frames
		*	@param	useTimer Boolean	if true, this class will use a timer to create the frames, it avoids your application to be freezing during this process.
 		*	@param	frames	int			if any value has passed, all frames will be cached.
		*	
		*	@see addFrame
		*	
		*	@return Boolean
		*	
		*	@usage
		*	
		**/
		public function cast( display:MovieClip, useTimer : Boolean = false, frames:int = int.MAX_VALUE ):Boolean{
			if (  totalFrames>0 || !display || totalFrames>0 ){return false;}

			_castIsFinished = false;
			movieclip = display;
			display.gotoAndStop(1)

			castingIndex = 0;
			castFrames = Math.min(display.totalFrames,frames);
			if (!useTimer){
				while( castingIndex<castFrames){
					addFrame( createBimapData( movieclip ) );
					castingIndex++;
				}
				
				// changing flag
				_castIsFinished = true;
				
				// start at first frame
				gotoAndStop(1);

				// notifying  casting creation
				dispatchEvent( CAST_COMPLETE.clone() );
				if (onCastComplete!=null){onCastComplete(this);}
			}
			else{
				_timer = new Timer(200);
				_timer.addEventListener( TimerEvent.TIMER,createFrameBytime,false,0,true );
				_timer.start()
			}
			return true;
		}
		/**
		*	creating cast by time.
		**/
		private function createFrameBytime(...rest):void{
			if ( castingIndex<castFrames ){
				addFrame( createBimapData( movieclip ) );
				castingIndex++;
			}
			else{
				// stoping timer
				_timer.removeEventListener( TimerEvent.TIMER,createFrameBytime );
				_timer.stop();
				
				// changing flag
				_castIsFinished = true;
				
				// start at first frame
				gotoAndStop(1);

				// notifying  casting creation
				dispatchEvent( CAST_COMPLETE.clone() );
				if (onCastComplete!=null){onCastComplete(this);}
			}
		}
		/**
		*	
		*	Genrerates the <code>BitmapData</code> relative to <code>castingIndex</code>
		*	
		*	@param display	MovieClip
		*	
		*	@return BitmapData
		*	
		**/
		private function createBimapData( display:MovieClip ):BitmapData{
			display.gotoAndStop( castingIndex+1 );
			if (display.currentLabel!=null){
				if ( !_frameLabels[ display.currentLabel ] ){
					_frameLabels[ display.currentLabel ] = display.currentFrame;
				}
			}
			return getBitmapData( display );
		}
		/**
		*	Add a new frame to the end of the list
		*	
		*	@param bitmap	BitmapData
		*	
		*	@return Boolean
		**/
		public function addFrame( bitmap:BitmapData ):Boolean{
			if (!bitmap){
				return false;
			}			
			if (!_timer){
				_castIsFinished = true;
			}
			_bitmapList.push( bitmap );
			return true;
		}
		/**
		*
		*	Adds the content to a specific frame. This <code>frame</code> must exist yet
		*	
		*	@see addFrameA
		*	
		*	@param bitmap	BitmapData
		*	@param frame	int
		*	
		*	@return Boolean
		*	
		**/
		public function addFrameAt( bitmap:BitmapData, frame:int ):Boolean{
			if (frame<0 || !bitmap ){
				return false;
			}
			if (_bitmapList[frame]){
				_bitmapList[frame] = bitmap;
			}
			return true;
		}
		/**
		*
		*	Adds a label to a specific frame
		*	
		*	@param frame
		*	@param label
		*	
		*	@return Boolean
		*	
		**/
		public function addLabel(frame:int, label:String):Boolean{
			if (frame<0 || !label){
				return false;
			}
			if (hasFrame(frame)){
				_frameLabels[frame] = label;
			}else{
				return false;
			}
			return true
		}
		/**
		*	
		*	Adds a script into a specific frame
		*	
		*	@param frame	*	int or String (for label)
		*	@param script	Function
		*	
		*	@return Boolean
		*	
		*	@usage
		*	var s : SuperMovieClip = new SuperMovieClip();
		*		s.onCastComplete = doSomething
		*		s.cast( anyMovieClip )
		*	
		*	function doSomething(caller : SuperMovieClip):void{
		*		s.addFrameScript( 5, function():void{trace("hello frames.")} );
		*	}
		*	
		**/
		public function addFrameScript( frame:*, script:Function ):Boolean{
			var f : int = getFrame( frame );
			if ( f == -1 || script==null || !castIsFinished ){
				return false;
			}else{
				_frameScripts[ f ] = script;
			}
			return true;
		}
		/**
		*	
		*	Checks whether <code>frame</code> exists
		*	
		*	@param	frame String or Number
		*	
		*	@return Boolean
		*	
		**/
		public function hasFrame(frame:int):Boolean{
			return  (frame>0 && frame<=totalFrames);
		}
		/**
		*	
		*	Returns the frame if it exists
		*	
		*	@param frame	String or Number
		*	
		*	@return int
		*	
		**/
		private function getFrame( frame:* ):int{
			var f : int;
			if ( frame is Number ){
				f = frame;
			}else if (frame is String){
				f = _frameLabels[ frame ];
			}else{
				f = -1;
			}
			if ( hasFrame( f ) ){
				return f;
			}else{
				return -1;
			}
		}
		/**
		*	
		*	Goes to the next frame
		*	
		*	@return Boolean
		*	
		**/
		public function nextFrame():Boolean{
			if ( currentFrame+1>totalFrames || !castIsFinished ){
				return false;
			}else{
				_currentFrame++;
			}
			updateView();
			return true;
		}
		/**
		*	
		*	Goes to the previews frame
		*	
		*	@return Boolean
		*	
		**/
		public function prevFrame():Boolean{
			if ( currentFrame==1 || !castIsFinished ){
				return false;
			}else{
				_currentFrame--;
			}
			updateView();
			return true;
		}
		/**
		*	
		*	Start chaging frames
		*	
		*	@return Boolean
		*	
		**/
		public function play():Boolean{
			if (_isPlaying || !castIsFinished){
				return false;
			}
			_isPlaying = true;
			this.addEventListener(Event.ENTER_FRAME, updateView, false, 0, true);
			return true;
		}
		/**
		*	
		*	Stop changing.
		*	
		*	@return Boolean
		*	
		**/
		public function stop():Boolean{
			currentDelay = 0;
			this.removeEventListener(Event.ENTER_FRAME, updateView);
			if (!_isPlaying || !castIsFinished){
				return false;
			}
			_isPlaying = false;
			return true;
		}
		/**
		*	
		*	Goes to a specific frame and stop
		*	
		*	@param frame	Number or String
		*	
		*	@return Boolean
		*	
		**/
		public function gotoAndStop( frame:* ):Boolean{
			stop( );
			if ( getFrame( frame )!=-1 && castIsFinished){
				_currentFrame = getFrame(frame);
				updateView();
			}else{
				return false;
			}
			return true;
		}
		/**
		*	
		*	Goes to a specific frame and stop
		*	
		*	@param frame	Number or String
		*	
		*	@return Boolean
		*	
		**/
		public function gotoAndPlay( frame:* ):Boolean{
			if (getFrame( frame )!=-1 && castIsFinished){
				_currentFrame = getFrame(frame);
				updateView();
			}else{
				return false;
			}
			return play();
		}
		/**
		*	
		*	Updates the current frame
		*	
		*	@see frameRate
		*	@see gotoAndStop
		*	@see gotoAndPlay
		*	@see play
		*	@see stop
		*	
		**/
		private function updateView(e:Event = null):void{
			var loop : Boolean;
			//checking only when playing
			if (e!=null){
				if (currentDelay==frameRate){
					if ( hasFrame(currentFrame+1) ){
						_currentFrame++;
					}else{
						loop = true;
						_currentFrame = 1;
					}
					currentDelay = 0;
				}
				else{
					currentDelay++;
					return;
				}
			}
			if (_bitmapList[currentFrame-1] && _display.bitmapData!=_bitmapList[currentFrame-1]){

				// notifying frame change callbacks
				dispatchEvent( FRAME_CHANGE.clone() );
				if (onFrameChange!=null){onFrameChange(this);}

				if (loop){
					// notifying loop callbacks
					dispatchEvent( LOOP.clone() );
					if (onLoop!=null){onLoop(this);}
				}

				_display.bitmapData = _bitmapList[currentFrame-1];

				// checking frame script
				if (_frameScripts[currentFrame]){
					_frameScripts[currentFrame].apply(null);
				}
			}
		}
		/**
		* disposes all bitmaps
		**/
		public function dispose( ...rest ):void{
			_bitmapList.forEach( function( bmp:BitmapData,...rest ):void{
				bmp.dispose();
			});
			_bitmapList = null;
			if (contains(_display) && _display!=null){
				removeChild(_display);
			}
			stop();
		}
	}
}