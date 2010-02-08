package{	
	
	import br.com.stimuli.loading.BulkLoader;
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.IEventDispatcher;
	import flash.external.ExternalInterface;
	import flash.utils.setTimeout;
	import redneck.events.VideoEvent;
	import saci.events.ListenerManager;
	import saci.uicomponents.VideoPlayer;
	import saci.util.ClassUtil;
	import saci.video.Video;
	import saci.uicomponents.videoPlayer.VideoPlayerControlBar;

	
	[SWF(width='1000', height='500', backgroundColor='#FFFFFF', frameRate='60')]
	public class Main extends Sprite{

		protected var _listenerManager:ListenerManager;
		protected var _videoPlayer:VideoPlayer;
		protected var _loader:BulkLoader;

		protected var _config:Object;
		protected var _skin:Sprite;
		protected var _flv:String;
		protected var _previewURL:String;

		public function Main(){
			super();
			
			stage.scaleMode = "noScale";
			stage.align = "topLeft";
			
			Preloader.lazyCreator(this, _onPreload);
		}
		public function _onPreload(e:Event = null):void{
			
			_listenerManager = ListenerManager.getInstance();
			
			// default values
			_config = {
				skin: null,
				hideInactiveMouseCursor: null,
				hideInactiveMouseCursorTime: null,
				linkage: "lib_videoPlayerSkin",
				autoHideBar: "false",
				fullScreenEnabled: "false",
				volume: null,
				timerEnabled: "true",
				useSharedObject: "true",
				bufferTime: "5",
				smoothing: "true",
				timeout: "5",
				autoSize: "smaller", // none (esticado) || bigger (sangrado) || smaller (tarjas pretas) || original
				onFirstPlay: null,
				onFirstComplete: null,
				onPlay: null,
				onComplete: null,
				onRewind: null,
				onPause: null,
				onVolume: null
			};
			
			if(stage != null){
				_init();
			}else{
				_listenerManager.addEventListener(stage, Event.ADDED_TO_STAGE, _init);
			}
		}
		public function _init(e:Event = null):void{
			_listenerManager.addEventListener(stage, Event.RESIZE, _onResize);
			
			_loader = new BulkLoader(BulkLoader.getUniqueName());
			_listenerManager.addEventListener(_loader, ErrorEvent.ERROR, _onErrorLoad);
			
			// loads CONFIG XML
			if(loaderInfo.parameters["configXML"] != null){
				_loader.add(loaderInfo.parameters["configXML"], { id: "config" });
				_listenerManager.addEventListener(_loader, Event.COMPLETE, _onCompleteXMLLoad);
				_loader.start();
			}else{
				_buildVideo();
			}
		}
		
		// XML CONFIG
		protected function _onCompleteXMLLoad(e:Event):void{
			_listenerManager.removeEventListener(_loader, Event.COMPLETE, _onCompleteXMLLoad);
			_parseXMLConfig(_loader.getXML("config").player[0]);
			_buildVideo();
		}
		protected function _parseXMLConfig(p_xml:XML):void{
			if(p_xml != null){
				for (var p:String in _config){
					if(String(p_xml[p]) != ""){
						_config[p] = String(p_xml[p]);
					}
				}
				if(String(p_xml["flv"]) != ""){
					_flv = String(p_xml["flv"]);
				}
				if(String(p_xml["previewURL"]) != ""){
					_previewURL = String(p_xml["previewURL"]);
				}
			}
		}
		
		// FLASH VARS CONFIG
		protected function _parseFlashVarsConfig():void{
			for (var p:String in _config){
				if(loaderInfo.parameters[p] != null){
					_config[p] = loaderInfo.parameters[p];
				}
			}
			if(loaderInfo.parameters["flv"] != null){
				_flv = loaderInfo.parameters["flv"];
			}
			if(loaderInfo.parameters["previewURL"] != null){
				_previewURL = loaderInfo.parameters["previewURL"];
			}
		}
		
		// CUSTOM SKIN
		protected function _onCompleteSkinLoad(e:Event):void{
			_listenerManager.removeEventListener(_loader, Event.COMPLETE, _onCompleteSkinLoad);
			var loadedSwf:DisplayObject = DisplayObject(_loader.getContent("skin"));
			var currSkin:Sprite = ClassUtil.cloneClassFromSwf(loadedSwf, _config.linkage);
			_skin = currSkin != null ? currSkin : _skin;
			_onBuildVideo();
		}
		
		protected function _buildVideo():void{
			_parseFlashVarsConfig();
			
			if(_config.skin != null){
				_loader.removeAll()
				_loader.add(_config.skin, { id: "skin" });
				_listenerManager.addEventListener(_loader, Event.COMPLETE, _onCompleteSkinLoad);
				_loader.start();
			}else{
				_skin = new videoPlayerDefaultSkin();
				_onBuildVideo();
			}
		}
		protected function _onBuildVideo():void{
			_videoPlayer = new VideoPlayer(_skin);
			
			addChild(_videoPlayer);

			if(_videoPlayer.stage != null){
				_onAddedVideo();
			}else{
				_listenerManager.addEventListener(_videoPlayer, Event.ADDED_TO_STAGE, _onAddedVideo);
			}
		}
		
		public function _onAddedVideo(e:Event = null):void{
			if(_listenerManager.hasEventListener(_videoPlayer, Event.ADDED_TO_STAGE, _onAddedVideo)){
				_listenerManager.removeEventListener(_videoPlayer, Event.ADDED_TO_STAGE, _onAddedVideo);
			}
			
			if(_config.hideInactiveMouseCursor != null)
				_videoPlayer.hideInactiveMouseCursor = _config.hideInactiveMouseCursor == "true";
			if(_config.hideInactiveMouseCursorTime != null)
				_videoPlayer.hideInactiveMouseCursorTime = Number(_config.hideInactiveMouseCursorTime);
			_videoPlayer.fullScreenEnabled = _config.fullScreenEnabled == "true";
			_videoPlayer.autoHideBar = _config.autoHideBar == "true";
			_videoPlayer.timerEnabled = _config.timerEnabled == "true";
			_videoPlayer.bufferTime = Number(_config.bufferTime);
			_videoPlayer.smoothing = _config.smoothing == "true";
			_videoPlayer.useSharedObject = _config.useSharedObject == "true";
			if(_config.volume != null)
				_videoPlayer.volume = Number(_config.volume);
			_videoPlayer.timeout = Number(_config.timeout)*1000;
			_videoPlayer.autoSize = _config.autoSize; // none (esticado) || bigger (sangrado) || smaller (tarjas pretas) || original
			
			if(_previewURL != null){
				_videoPlayer.previewURL = _previewURL;
			}
			_videoPlayer.init(_flv);
			
			// register javascript callbacks
			if(ExternalInterface.available){
				ExternalInterface.addCallback("playVideo", function():void{_videoPlayer.play();});
				ExternalInterface.addCallback("pauseVideo", function():void{_videoPlayer.pause();});
				ExternalInterface.addCallback("playPauseVideo", function():void{_videoPlayer.playPause();});
				ExternalInterface.addCallback("rewindVideo", function():void{_videoPlayer.rewind();});
				ExternalInterface.addCallback("seekVideo", _videoPlayer.seek);
				ExternalInterface.addCallback("setVideoVolume", _setVolume);
				ExternalInterface.addCallback("changeVideo", _changeVideo);
				ExternalInterface.addCallback("setVideoProperty", _setProperty);
				
				// apply JS listeners
				if(_config.onFirstPlay != null){
					_addJSEventListener(_videoPlayer, Video.FIRST_TIME_PLAY, _config.onFirstPlay);
				}
				if(_config.onFirstComplete != null){
					_addJSEventListener(_videoPlayer, Video.FIRST_TIME_COMPLETE, _config.onFirstComplete);
				}
				if(_config.onPlay != null){
					_addJSEventListener(_videoPlayer.video, VideoEvent.PLAY_START, _config.onPlay);
				}
				if(_config.onComplete != null){
					_addJSEventListener(_videoPlayer.video, VideoEvent.COMPLETE, _config.onComplete);
				}
				if(_config.onRewind != null){
					_addJSEventListener(_videoPlayer.video, VideoEvent.REWIND, _config.onRewind);
				}
				if(_config.onPause != null){
					_addJSEventListener(_videoPlayer.video, VideoEvent.PAUSE_NOTIFY, _config.onPause);
				}
				if(_config.onVolume != null){
					_addJSEventListener(_videoPlayer.controlBar, VideoPlayerControlBar.VOLUME_CHANGED, _config.onVolume);
				}
			}
			_onResize(null);
		}
		
		// JS callbacks
		protected function _addJSEventListener(p_element:IEventDispatcher, p_eventType:String, p_JSMethod:String):void {
			_listenerManager.addEventListener(p_element, p_eventType, function(e:Event):void{
				var type:String = "";
				
				switch(e.type){
					case Video.FIRST_TIME_PLAY:
						type = "firstTimePlay";
						break;
					case Video.FIRST_TIME_COMPLETE:
						type = "firstTimeComplete";
						break;
					case VideoEvent.PLAY_START:
						type = "play";
						break;
					case VideoEvent.COMPLETE:
						type = "complete";
						break;
					case VideoEvent.PAUSE_NOTIFY:
						type = "pause";
						break;
					case VideoPlayerControlBar.VOLUME_CHANGED:
						type = "volumeChanged";
						break;
				}
				
				var data:Object = {
					type: type,
					duration: _videoPlayer.video.duration,
					time: _videoPlayer.time,
					flv: _videoPlayer.flv,
					autoSize: _videoPlayer.autoSize,
					previewURL: _videoPlayer.previewURL,
					fullScreenEnabled: _videoPlayer.fullScreenEnabled,
					volume: _videoPlayer.volume,
					smoothing: _videoPlayer.smoothing,
					useSharedObject: _videoPlayer.useSharedObject,
					isPlaying: _videoPlayer.video.isPlaying,
					isLoaded: _videoPlayer.video.isLoaded,
					percentLoaded: _videoPlayer.video.percentLoaded
				};
				ExternalInterface.call(p_JSMethod, data);
			});
		}
		protected function _setProperty(p_property:String, p_value:*):void{
			switch(p_property){
				case "autoHideBar":
				case "timerEnabled":
				case "smoothing":
				case "fullScreenEnabled":
				case "useSharedObject":
				case "hideInactiveMouseCursor":
					_videoPlayer[p_property] = p_value is Boolean ? p_value : p_value == "true";
					break;
				case "autoSize":
					_videoPlayer[p_property] = p_value;
					break;
				case "volume":
				case "bufferTime":
				case "timeout":
				case "hideInactiveMouseCursorTime":
					_videoPlayer[p_property] = Number(p_value);
					break;
			}
		}
		protected function _changeVideo(p_flv:String, p_previewURL:String = null):void{
			_videoPlayer.load(p_flv);
			if(p_previewURL != null){
				_videoPlayer.previewURL = p_previewURL;
			}
		}
		protected function _setVolume(value:Number):void{
			_videoPlayer.volume = value > 1 ? 1 : value;
		}
		
		// global handlers
		protected function _onErrorLoad(e:ErrorEvent):void{
			_listenerManager.removeEventListener(_loader, Event.COMPLETE, _onCompleteXMLLoad);
			_listenerManager.removeEventListener(_loader, Event.COMPLETE, _onCompleteSkinLoad);
			_loader.removeFailedItems();
		}
		protected function _onResize(e:Event):void{
			if(_videoPlayer){
				_videoPlayer.setSize(stage.stageWidth, stage.stageHeight);
			}
		}

	}
}