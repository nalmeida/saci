package saci.uicomponents.videoPlayer {
	
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import saci.ui.SaciSprite;
	import saci.uicomponents.VideoPlayer;
	
	/**
	 * @author Nicholas Almeida
	 */
	public class VideoPlayerControlBar extends SaciSprite{
		
		private var _skin:Sprite;
		private var _videoPlayer:VideoPlayer;
		
		private var _controlBar:Sprite;
			private var _base:Sprite;
			private var _playButton:Sprite;
			private var _pauseButton:Sprite;
			private var _rewindButton:Sprite;
			private var _fullScreenButton:Sprite;
			private var _normalScreenButton:Sprite;
			private var _muteButton:Sprite;
			private var _unmuteButton:Sprite;
			private var _timerButton:Sprite;
				private var _fldTimer:TextField;
			
			private var _progressBar:Sprite;
				private var _timeRail:Sprite;
				private var _sliderButton:Sprite;
				private var _timeTrack:Sprite;
				private var _loadMask:Sprite;
		
		public function VideoPlayerControlBar($videoPlayer:VideoPlayer, $skin:Sprite) {
			_skin = $skin;
			_videoPlayer = $videoPlayer;
			
			_controlBar = _skin.getChildByName("controlBar") as Sprite;
				_base = _controlBar.getChildByName("base") as Sprite;
				_playButton = _controlBar.getChildByName("playButton") as Sprite;
				_pauseButton = _controlBar.getChildByName("pauseButton") as Sprite;
				_rewindButton = _controlBar.getChildByName("rewindButton") as Sprite;
				_fullScreenButton = _controlBar.getChildByName("fullScreenButton") as Sprite;
				_normalScreenButton = _controlBar.getChildByName("normalScreenButton") as Sprite;
				_muteButton = _controlBar.getChildByName("muteButton") as Sprite;
				_unmuteButton = _controlBar.getChildByName("unmuteButton") as Sprite;
				_timerButton = _controlBar.getChildByName("timerButton") as Sprite;
					_fldTimer = _timerButton.getChildByName("fldTimer") as TextField;
				_progressBar = _controlBar.getChildByName("progressBar") as Sprite;
					_sliderButton = _progressBar.getChildByName("sliderButton") as Sprite;
					_timeTrack = _progressBar.getChildByName("timeTrack") as Sprite;
					_timeRail = _progressBar.getChildByName("timeRail") as Sprite;
					_loadMask = _progressBar.getChildByName("loadMask") as Sprite;
					
			_loadMask.scaleX = 0;
			_timeTrack.mask = _loadMask;
				
			_controlBar.x
			_controlBar.y = 0;
			
			_timerButton.mouseChildren = 
			_unmuteButton.mouseChildren = 
			_muteButton.mouseChildren = 
			_fullScreenButton.mouseChildren = 
			_normalScreenButton.mouseChildren = 
			_playButton.mouseChildren = 
			_pauseButton.mouseChildren = 
			_rewindButton.mouseChildren = false;
			
			//_timerButton.buttonMode = 
			_fullScreenButton.buttonMode = 
			_normalScreenButton.buttonMode = 
			_playButton.buttonMode = 
			_pauseButton.buttonMode = 
			_rewindButton.buttonMode = true;
			
			_normalScreenButton.visible = false;
			
			if (_videoPlayer.volume <= 0) {
				_muteButton.visible = false;
				_unmuteButton.visible = true;
			} else {
				_muteButton.visible = true;
				_unmuteButton.visible = false;
			}
			
			_listenerManager.addEventListener(_playButton, MouseEvent.CLICK, _play);
			_listenerManager.addEventListener(_pauseButton, MouseEvent.CLICK, _pause);
			_listenerManager.addEventListener(_rewindButton, MouseEvent.CLICK, _rewind);
			_listenerManager.addEventListener(_fullScreenButton, MouseEvent.CLICK, _openFullScreen);
			_listenerManager.addEventListener(_normalScreenButton, MouseEvent.CLICK, _openNormalScreen);
			
			fldTimer.text = "00:00";
			
			refresh();
			
			addChild(_controlBar);
		}
		
		public function refresh():void {
			_muteButton.x = _base.width - _muteButton.width;
			_unmuteButton.x = _base.width - _unmuteButton.width;
			
			_fullScreenButton.x = _muteButton.x - _fullScreenButton.width;
			_normalScreenButton.x = _muteButton.x - _normalScreenButton.width;
			
			if(_videoPlayer.fullScreenEnabled) {
				_timerButton.x = _fullScreenButton.x - _timerButton.width;
			} else {
				_timerButton.x = _muteButton.x - _timerButton.width;
			}
			
			_timeRail.width = _base.width - _muteButton.width - _progressBar.x - (_timeRail.x * 2);
			if (_videoPlayer.fullScreenEnabled) {
				_timeRail.width -= _fullScreenButton.width;
			}
			
			if (_videoPlayer.timerEnabled) {
				_timeRail.width -= _timerButton.width;
			}
			
			_timeTrack.width = _timeRail.width;
		}
		
		public function enableFullScreen():void {
			_fullScreenButton.mouseEnabled = 
			_normalScreenButton.mouseEnabled = 
			_fullScreenButton.visible = 
			_normalScreenButton.visible = true;
			
			if (_videoPlayer.fullScreenMode == "normal") {
				_normalScreenButton.visible = false;
			}
		}
		
		public function disableFullScreen():void {
			_fullScreenButton.mouseEnabled = 
			_normalScreenButton.mouseEnabled = 
			_fullScreenButton.visible = 
			_normalScreenButton.visible = false;
		}
		
		public function enableTimer():void {
			_timerButton.mouseEnabled = 
			_timerButton.visible = true;
		}
		
		public function disableTimer():void {
			_timerButton.mouseEnabled = 
			_timerButton.visible = false;
		}
		
		private function _openFullScreen(e:MouseEvent):void {
			_fullScreenButton.visible = false;
			_normalScreenButton.visible = true;
		}
		
		private function _openNormalScreen(e:MouseEvent):void{
			_fullScreenButton.visible = true;
			_normalScreenButton.visible = false;
		}
		
		private function _play(e:MouseEvent):void{
			_videoPlayer.play();
		}
		
		private function _pause(e:MouseEvent):void {
			_videoPlayer.pause();
		}
		
		private function _rewind(e:MouseEvent):void{
			_videoPlayer.rewind();
		}
		
		public function get base():Sprite { return _base; }
		public function get playButton():Sprite { return _playButton; }
		public function get pauseButton():Sprite { return _pauseButton; }
		public function get rewindButton():Sprite { return _rewindButton; }
		public function get fldTimer():TextField { return _fldTimer; }
		
		public function set percentLoaded(value:Number):void {
			_loadMask.scaleX = value*_timeTrack.scaleX;
		}
		
		public function set percentPlayed(value:Number):void {
			_sliderButton.x = _timeTrack.x + (_timeTrack.width * value) - _sliderButton.width;
			
			if (_sliderButton.x < _timeTrack.x) {
				_sliderButton.x = _timeTrack.x;
			} else  if (_sliderButton.x > _timeTrack.width) {
				_sliderButton.x = _timeTrack.width;
			}
		}
		
		public function set time(value:Number):void {
			var sec:uint = value % 60;
			var min:uint = (value / 60) % 60;
			fldTimer.text = String(min < 10 ? "0" + min : min) + ":" + String(sec < 10 ? "0" + sec : sec);
		}
		
	}
	
}