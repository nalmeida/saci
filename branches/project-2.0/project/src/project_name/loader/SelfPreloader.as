package project_name.loader{

	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.utils.getDefinitionByName;
	import flash.utils.setTimeout;
	import as3classes.util.RootUtil;

	// @original: http://www.dreaminginflash.com/2007/11/13/actionscript-3-preloader/
	
	/**
		SelfPreloader class. Creates a self preloader in the "first frame".
		
		@author Nicholas Almeida nicholasalmeida.com
		@since 11/6/2008 19:20
		@usage
				Insert the line above at package of your Main class:
				[Frame(factoryClass="as3classes.loader.SelfPreloader")]
				
				IMPORTANT: Your main class MUST be named as "Main".
	 */
	
	public class SelfPreloader extends MovieClip {
		
		public var standardLoader:MovieClip;
		public var useIcon:Boolean = false;
		
		public function SelfPreloader() {
			stop();
			
			RootUtil.init(this);
			
			addEventListener(Event.ENTER_FRAME, onEnterFrame);
			loaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onIOError);
			
			init();
		}
		
		public function onIOError(event:IOErrorEvent):void {
			if (useIcon) {
				try {
					standardLoader.stop();
				} catch (e:Error) {}
			}
			stop();
			removeListeners();
			trace(event.toString());
			trace("--------------------------------------------");
		}
		
		public function removeListeners():void {
			removeEventListener(Event.ENTER_FRAME, onEnterFrame);
			loaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, onIOError);
			
			if (useIcon) {
				if (stage.hasEventListener(Event.RESIZE)) {
					stage.removeEventListener(Event.RESIZE, onResize);
				}
			}
		}
		
		public function onEnterFrame(event:Event):void {
			var percent:Number;
			if (framesLoaded == totalFrames) {
				percent = 1;
				removeListeners();
				nextFrame();
				onComplete();
			} else {
				percent = RootUtil.getRoot().loaderInfo.bytesLoaded / RootUtil.getRoot().loaderInfo.bytesTotal;
			}
			trace(percent);
		}
		
		private function onComplete():void {
			
			if (useIcon) {
				try {
					removeChild(standardLoader);
					standardLoader = null;
				} catch (e:Error) {}
			}
			setTimeout(_addMainClass, 200);
		}
		
		private function _addMainClass():void{
            var mainClass:Class = Class(getDefinitionByName("project_name.Main"));
			if(mainClass) {
				var app:Object = new mainClass();
				addChild(app as DisplayObject);
			}
			app = mainClass = null;
		}
		
		
		// OVERRIDED Functions
		public function init():void {trace("SelfPreloader.init");}
		public function onResize(evt:Event = null):void {}
	}
}

