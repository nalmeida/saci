package{

	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.EventDispatcher;

	public class Preloader extends EventDispatcher {
		
		static public function lazyCreator(p_root:DisplayObject, p_completeHandler:Function = null, p_errorHandler:Function = null):Preloader {
			var preloader:Preloader = new Preloader(p_root);
			if(p_completeHandler != null){
				preloader.addEventListener(Event.COMPLETE, p_completeHandler);
			}
			if(p_errorHandler != null){
				preloader.addEventListener(IOErrorEvent.IO_ERROR, p_errorHandler);
			}
			preloader.init();
			return preloader;
		}
		
		protected var _root:DisplayObject;
		protected var _percentLoaded:Number;
		
		public function Preloader(p_root:DisplayObject) {
			_percentLoaded = 0;
			_root = p_root;
		}
		
		public function init():void{
			if(_root.loaderInfo.bytesLoaded < _root.loaderInfo.bytesTotal){
				addEventListener(Event.ENTER_FRAME, _onEnterFrame);
				_root.loaderInfo.addEventListener(IOErrorEvent.IO_ERROR, _onIOError);
			}else{
				_onComplete();
			}
		}
		
		protected function _onIOError(e:IOErrorEvent):void {
			_removeListeners();
			dispatchEvent(e.clone());
		}
		protected function _onEnterFrame(e:Event):void {
			if (_root.loaderInfo.bytesLoaded == _root.loaderInfo.bytesTotal) {
				_percentLoaded = 1;
				_onComplete();
			} else {
				_percentLoaded = _root.loaderInfo.bytesLoaded / _root.loaderInfo.bytesTotal;
			}
		}
		
		protected function _removeListeners():void {
			removeEventListener(Event.ENTER_FRAME, _onEnterFrame);
			if(_root.loaderInfo.hasEventListener(IOErrorEvent.IO_ERROR)){
				_root.loaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, _onIOError);
			}
		}
		
		private function _onComplete():void{
			dispatchEvent(new Event(Event.COMPLETE));
			_removeListeners();
		}
		
		public function get percentLoaded():Number { return _percentLoaded; }
	}
}