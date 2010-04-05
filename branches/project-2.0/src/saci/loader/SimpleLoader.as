package saci.loader {
	
	/**
	 * Very Simple Content Loader
	 * @author Nicholas Almeida nicholasalmeida.com
	 * @since 28/10/2008 15:39
	 * @usage 
	 
		loader = new SimpleLoader();
			loader.addEventListener(Event.COMPLETE, onLoadComplete);
			loader.addEventListener(ProgressEvent.PROGRESS, onLoadProgress);
			loader.addEventListener(ErrorEvent.ERROR, onLoadError);
			loader.addEventListener(IOErrorEvent.IO_ERROR, onLoadError);
			
		loader.load("your_swf.swf");
		
		// or holder.addChild(loader.loader); // Used when you load AS2 SWFs
	 
	 
		public function onLoadError(e:*):void { // ErrorEvent or IOErrorEvent
			trace("ERROR" + e);
		}

		public function onLoadProgress(e:ProgressEvent):void {
			trace("% loaded: " + loader._percentLoaded);
		}

		public function onLoadComplete(e:Event):void {
			holder.addChild(loader.content as MovieClip);
		}
		
	 */
	
	import flash.display.Loader;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.ErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.EventDispatcher;
	import flash.net.URLRequest;
	import flash.system.LoaderContext;
	import saci.events.ListenerManager;
	import saci.util.Logger;
		
	public class SimpleLoader extends EventDispatcher{
		
		private var _loader:Loader;
		private var _file:String;
		private var _percentLoaded:Number = 0;
		private var _contentType:String;
		public var content:*;
		public var context:LoaderContext;
		
		private var _listenerManager:ListenerManager;
		private var _logger:Logger;
		
		public function SimpleLoader() {
			_listenerManager = ListenerManager.getInstance();
			Logger.init(Logger.LOG_VERBOSE);
		}
		
		private function _addListeners():void {
			_listenerManager.addEventListener(loader.contentLoaderInfo, Event.COMPLETE, _onLoadComplete, false, 0, true);
			_listenerManager.addEventListener(loader.contentLoaderInfo, ProgressEvent.PROGRESS, _onLoadProgress, false, 0, true);
			_listenerManager.addEventListener(loader.contentLoaderInfo, ErrorEvent.ERROR, _onLoadError, false, 0, true);
			_listenerManager.addEventListener(loader.contentLoaderInfo, IOErrorEvent.IO_ERROR, _onLoadError, false, 0, true);
		}
		
		
		private function _removeListeners():void {
			if (loader != null) {
				if(_listenerManager.has(loader.contentLoaderInfo)){
					_listenerManager.removeAllEventListeners(loader.contentLoaderInfo);
				}
			}
		}
		
		private function _onLoadError(e:*):void {
			dispatchEvent(e);
			stop();
		}
		
		private function _onLoadProgress(e:Event):void {
			dispatchEvent(e);
			_percentLoaded = loader.contentLoaderInfo.bytesLoaded / loader.contentLoaderInfo.bytesTotal;
		}
		
		private function _onLoadComplete(e:Event):void {
			_contentType = loader.contentLoaderInfo.contentType;
			content = loader.content;
			dispatchEvent(e);
			_removeListeners();
		}
		
		public function destroy():void {
			_removeListeners();
			_loader = null;
		}
		
		public function stop():void {
			if(loader != null){
				loader.close();
			}
		}
		
		public function load($file:String, $context:LoaderContext = null):void {
			_file = $file;
			context = $context;
			_percentLoaded = 0;
			content = null;
			
			stop();
			destroy();
			
			_loader = new Loader();
			_addListeners();
			
			if(_file != null && _file != ""){
				loader.load(new URLRequest(_file));
			} else {
				Logger.logWarning("[SimpleLoader.load] \"$file\" is undefined");
			}
		}
		
		public function get loader():Loader { return _loader; }
		public function get file():String { return _file; }
		public function get percentLoaded():Number { return _percentLoaded; }
		public function get contentType():String { return _contentType; }
	}
	
}