package project_name.loader{

	import flash.display.DisplayObjectContainer;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	
	// @original: http://www.dreaminginflash.com/2007/11/13/actionscript-3-preloader/
	
	/**
		SelfPreloader class. Creates a self preloader in the "first frame".
		
		@author Nicholas Almeida nicholasalmeida.com; edited by Marcelo Miranda Carneiro mcarneiro@gmail.com
		@since 12/6/2008 12:22
		@usage
				Insert the line above at package of your Main class:
				[Frame(factoryClass="as3classes.loader.SelfPreloaderIcon")]
				
				IMPORTANT:
					You MUST add a MovieClip as your preloader icon:
					 * Create a SWC file with a MovieClip with linkage name "lib_standardLoader".
					 * I allways will be at center center of stage.
				
				IMPORTANT: Place the name of yout main class in the method "_addMainClass".
	 */	
	
	public class SelfPreloaderIcon extends SelfPreloader {
		
		protected var _standardLoader:MovieClip;
		
		public function SelfPreloaderIcon():void {
			super();
			init();
		}
		
		public override function init():void {
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
			
			_standardLoader = new lib_standardLoader() as MovieClip;
			addChild(_standardLoader);
			
            stage.addEventListener(Event.RESIZE, _onResize);
			_onResize();
		}
		
		public override function _onResize(evt:Event = null):void {
			if(stage != null){
				_standardLoader.x = stage.stageWidth * .5;
				_standardLoader.y = stage.stageHeight * .5;
			}
		}
		override protected function _onComplete():void {
			if (_standardLoader.parent != null)
				if(_standardLoader.parent == this as DisplayObjectContainer)
					removeChild(_standardLoader);
			_standardLoader = null;
			_onComplete();
		}
		
		override public function removeListeners():void {
			if(stage != null)
				if (stage.hasEventListener(Event.RESIZE))
					stage.removeEventListener(Event.RESIZE, _onResize);
		}
	}
}

