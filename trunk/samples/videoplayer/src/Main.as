package{	
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.utils.setTimeout;
	import saci.events.ListenerManager;
	import saci.uicomponents.VideoPlayer;
	import saci.video.Video;
	
	[SWF(width='1000', height='500', backgroundColor='#FFFFFF', frameRate='60')]
	public class Main extends Sprite{

		protected var _listenerManager:ListenerManager;
		protected var _videoPlayer:VideoPlayer;
		/*protected var _videoPlayerList:VideoPlayerList;*/
		protected var _video:Video;

		public function Main(){
			super();
			
			stage.scaleMode = "noScale";
			stage.align = "topLeft";
			
			if(stage != null){
				_init();
			}else{
				addEventListener(Event.ADDED_TO_STAGE, _init);
			}
		}
		public function _init(e:Event = null):void{
			stage.addEventListener(Event.RESIZE, _onResize);
			
			_videoPlayer = new VideoPlayer(new videoPlayerDefaultSkin());
			/*_videoPlayerList = new VideoPlayerList(new videoPlayerDefaultSkin());*/
			
			_videoPlayer.fullScreenEnabled = true;
			_videoPlayer.volume = .5;
			/*_videoPlayer.x = 100;
			_videoPlayer.y = 100;*/
			_videoPlayer.smoothing = true;
			_videoPlayer.setSize(500, 300);
			/*_videoPlayer.autoHideBar = true;*/
			_videoPlayer.previewURL = "ext/flap1.png";
			_videoPlayer.init("ext/flap1.flv");
			/*setTimeout(_videoPlayer.startVideo, 1000);*/
			setTimeout(function():void {
				/*_videoPlayer.fullScreenEnabled = false;
				_videoPlayer.timerEnabled = false;*/
				/*_videoPlayer.previewURL = "ext/flap2.png";
				_videoPlayer.load("http://interface.aceite.fbiz.com.br/testes/flv/video.flv");*/
				/*_videoPlayer.load("ext/flap2.flv");*/
				/*_videoPlayer.startVideo();*/
				/*setTimeout(_videoPlayer.play, 400);*/
				/*_videoPlayer.play();*/
			}, 2000);
			/*_videoPlayer.rotation = -10;*/
			addChild(_videoPlayer);

			_onResize(null);
		}
		private function _onResize(e:Event){
			_videoPlayer.setSize(stage.stageWidth, stage.stageHeight);
		}

	}
}