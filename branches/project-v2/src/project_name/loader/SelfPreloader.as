package project_name.loader{

	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.utils.getDefinitionByName;
	import flash.utils.setTimeout;

	// @original: http://www.dreaminginflash.com/2007/11/13/actionscript-3-preloader/
	
	/**
		SelfPreloader class. Creates a self preloader in the "first frame".
		
		@author Nicholas Almeida nicholasalmeida.com; edited by Marcelo Miranda Carneiro mcarneiro@gmail.com
		@since 11/6/2008 19:20
		@usage
				Insert the line above at package of your Main class:
				[Frame(factoryClass="as3classes.loader.SelfPreloader")]
				
				IMPORTANT: Place the name of yout main class in the method "_addMainClass".
	 */
	
	public class SelfPreloader extends MovieClip {
		
		protected var _percent:Number;
		protected var _mainClass:Class;
		
		public function SelfPreloader() {
			stop();
			
			addEventListener(Event.ENTER_FRAME, onEnterFrame);
			loaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onIOError);
		}
		
		protected function _onIOError(event:IOErrorEvent):void {
			removeListeners();
			//trace("[SelfPreloader._onIOError] event.toString(): " + event.toString());
		}
		protected function _onEnterFrame(event:Event):void {
			if (framesLoaded == totalFrames) {
				_percent = 1;
				removeListeners();
				nextFrame();
				onComplete();
			} else {
				_percent = loaderInfo.bytesLoaded / loaderInfo.bytesTotal;
			}
			//trace("[SelfPreloader.onEnterFrame] percent: " + percent);
		}
		protected function _onComplete():void {
			setTimeout(_addMainClass, 200);
		}
		
		// remove listeners
		public function removeListeners():void {
			removeEventListener(Event.ENTER_FRAME, onEnterFrame);
			loaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, onIOError);
		}
		
		// add main class
		protected function _addMainClass():void{
            _mainClass = Class(getDefinitionByName("project_name.Main"));
			if(mainClass) {
				addChild(new _mainClass() as DisplayObject);
			}
		}
		
		public function get mainClass():Class { return _mainClass; }
	}
}

