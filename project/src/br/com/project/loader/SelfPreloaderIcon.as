package br.com.project.loader{

	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.display.MovieClip;
	import flash.events.Event;
	
	// @original: http://www.dreaminginflash.com/2007/11/13/actionscript-3-preloader/
	
	/**
		SelfPreloader class. Creates a self preloader in the "first frame".
		
		@author Nicholas Almeida nicholasalmeida.com
		@since 12/6/2008 12:22
		@usage
				Insert the line above at package of your Main class:
				[Frame(factoryClass="as3classes.loader.SelfPreloaderIcon")]
				
				IMPORTANT:
					Your main class MUST be named as "Main".
					
					You MUST add a MovieClip as your preloader icon:
					 * Create a SWC file with a MovieClip with linkage name "lib_standardLoader".
					 * I allways will be at center center of stage.
	 */	
	
	public class SelfPreloaderIcon extends SelfPreloader {
		
		public override function init():void {
			trace("SelfPreloaderIcon.init");
			
			super.stage.scaleMode = StageScaleMode.NO_SCALE;
			super.stage.align = StageAlign.TOP_LEFT;
			
			super.useIcon = true;
			super.standardLoader = new lib_standardLoader as MovieClip;
			addChild(super.standardLoader);
			
            super.stage.addEventListener(Event.RESIZE, onResize, false, 0, true);
			onResize();
		}
		
		public override function onResize(evt:Event = null):void {
			super.standardLoader.x = super.stage.stageWidth * .5;
			super.standardLoader.y = super.stage.stageHeight * .5;
		}
		
	}
}

