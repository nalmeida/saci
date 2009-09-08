package saci.uicomponents.videoPlayer {
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import redneck.events.SliderEvent;
	import redneck.ui.Slider;
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
			private var _volumeBase:Sprite;
				private var _sliderVolumeButton:Sprite;
				private var _volumePercent:Sprite;
				private var _volumeTrack:Sprite;
			private var _muteButton:Sprite;
			private var _unmuteButton:Sprite;
			private var _timerButton:Sprite;
				private var _fldTimer:TextField;
			
			private var _progressBar:Sprite;
				private var _timeRail:Sprite;
				private var _sliderButton:Sprite;
				private var _timeTrack:Sprite;
				private var _loadMask:Sprite;
		
		private var _volumeSlider:Slider;
		private var _videoSlider:Slider;
		private var _slidingVideo:Boolean = false;
		private var _volume:Number;
		
		public static const VOLUME_CHANGED:String = "volumeChanged";
		
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
				_volumeBase = _controlBar.getChildByName("volumeBase") as Sprite;
					_sliderVolumeButton = _volumeBase.getChildByName("sliderVolumeButton") as Sprite;
					_volumePercent = _volumeBase.getChildByName("volumePercent") as Sprite;
					_volumeTrack = _volumeBase.getChildByName("volumeTrack") as Sprite;
				_muteButton = _controlBar.getChildByName("muteButton") as Sprite;
				_unmuteButton = _controlBar.getChildByName("unmuteButton") as Sprite;
				_timerButton = _controlBar.getChildByName("timerButton") as Sprite;
					_fldTimer = _timerButton.getChildByName("fldTimer") as TextField;
				_progressBar = _controlBar.getChildByName("progressBar") as Sprite;
					_sliderButton = _progressBar.getChildByName("sliderButton") as Sprite;
					_timeTrack = _progressBar.getChildByName("timeTrack") as Sprite;
					_timeRail = _progressBar.getChildByName("timeRail") as Sprite;
					_loadMask = _progressBar.getChildByName("loadMask") as Sprite;
					
			_volumeBase.visible = false;
			_volumePercent.mouseEnabled = false;
					
			_createSlider();
			_loadMask.scaleX = 0;
			_timeTrack.mask = _loadMask;
			_timeTrack.mouseEnabled = false;
				
			_controlBar.x
			_controlBar.y = 0;
			
			_sliderButton.mouseChildren = 
			_timerButton.mouseChildren = 
			_unmuteButton.mouseChildren = 
			_muteButton.mouseChildren = 
			_fullScreenButton.mouseChildren = 
			_normalScreenButton.mouseChildren = 
			_playButton.mouseChildren = 
			_pauseButton.mouseChildren = 
			_rewindButton.mouseChildren = false;
			
			//_timerButton.buttonMode = 
			_sliderButton.buttonMode = 
			_fullScreenButton.buttonMode = 
			_normalScreenButton.buttonMode = 
			_playButton.buttonMode = 
			_pauseButton.buttonMode = 
			_rewindButton.buttonMode = true;
			
			_sliderButton.useHandCursor = false;
			
			_normalScreenButton.visible = false;
			
			if (_videoPlayer.volume <= 0) {
				_muteButton.visible = false;
				_unmuteButton.visible = true;
			} else {
				_muteButton.visible = true;
				_unmuteButton.visible = false;
			}
			
			_listenerManager.addEventListener(_playButton, MouseEvent.CLICK, play);
			_listenerManager.addEventListener(_pauseButton, MouseEvent.CLICK, pause);
			_listenerManager.addEventListener(_rewindButton, MouseEvent.CLICK, rewind);
			_listenerManager.addEventListener(_fullScreenButton, MouseEvent.CLICK, _openFullScreen);
			_listenerManager.addEventListener(_normalScreenButton, MouseEvent.CLICK, _openNormalScreen);
			
			_listenerManager.addEventListener(_volumeBase, MouseEvent.ROLL_OVER, _openVolumeControl);
			_listenerManager.addEventListener(_muteButton, MouseEvent.ROLL_OVER, _openVolumeControl);
			_listenerManager.addEventListener(_unmuteButton, MouseEvent.ROLL_OVER, _openVolumeControl);
			
			_listenerManager.addEventListener(_volumeBase, MouseEvent.ROLL_OUT, _closeVolumeControl);
			_listenerManager.addEventListener(_muteButton, MouseEvent.ROLL_OUT, _closeVolumeControl);
			_listenerManager.addEventListener(_unmuteButton, MouseEvent.ROLL_OUT, _closeVolumeControl);
			
			fldTimer.text = "00:00";
			addChild(_controlBar);
			
			refresh();
		}
		
		public function refresh():void {
			base.width = _videoPlayer.screen.base.width;
			_muteButton.x = 
			_unmuteButton.x = 
			_volumeBase.x = _base.width - _unmuteButton.width;
			
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
			
			_volumeSlider.refresh();
			_videoSlider.refresh();
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
		
		private function play(e:MouseEvent = null):void{
			_videoPlayer.play();
		}
		
		private function pause(e:MouseEvent = null):void {
			_videoPlayer.pause();
		}
		
		private function rewind(e:MouseEvent = null):void{
			_videoPlayer.rewind();
		}
		
		public function seek(time:Number, playAfter:Boolean = true ):void {
			_videoPlayer.seek(time, playAfter);
		}
		
		public function seekVolume(value:Number):void {
			_volumePercent.y = _sliderVolumeButton.y = _volumeTrack.height * (1 - value);
			_volumePercent.height = (_volumeTrack.height * value) + _sliderVolumeButton.height - 1;
			volume = value;
		}
		
		/**
		 * PRIVATE
		 */
		
		private function _createSlider():void{
			_videoSlider = new Slider(_sliderButton, _timeRail, true);
			_listenerManager.addEventListener(_videoSlider, SliderEvent.ON_PRESS, _onPressVideoSlider);
			_listenerManager.addEventListener(_videoSlider, SliderEvent.ON_RELEASE, _onReleaseVideoSlider);
			_listenerManager.addEventListener(_videoSlider, SliderEvent.ON_CHANGE, _onSlideVideo);
			
			_volumeSlider = new Slider(_sliderVolumeButton, _volumeTrack, false);
			
			_volumeSlider.seek = true;
			_listenerManager.addEventListener(_volumeSlider, SliderEvent.ON_CHANGE, _onSlideVolume);
			
			if(_videoPlayer.volume != _volume) {
				seekVolume(_videoPlayer.volume);
			}
		}
		
		private function _onSlideVolume(e:SliderEvent):void {
			volume = (1 - _volumeSlider.percent);
			
			_volumePercent.y = _sliderVolumeButton.y;
			_volumePercent.height = _volumeTrack.height - _sliderVolumeButton.y + _volumeTrack.y;

			dispatchEvent(new Event(VOLUME_CHANGED));
		}
		
		private function _mute():void {
			_muteButton.visible = false;
			_unmuteButton.visible = true;
		}
		
		private function _unMute():void {
			_muteButton.visible = true;
			_unmuteButton.visible = false;
		}
		
		private function _onPressVideoSlider(e:SliderEvent):void {
			_slidingVideo = true;
		}
		
		private function _onReleaseVideoSlider(e:SliderEvent):void{
			_slidingVideo = false;
		}
		
		private function _onSlideVideo(e:SliderEvent):void {
			if(_slidingVideo){
				var _highestMaskWidth:Number = _loadMask.x + _loadMask.width;
				
				if (_sliderButton.x > _highestMaskWidth) {
					_sliderButton.x = _highestMaskWidth;
				} else {
					var calc:Number = ((_videoPlayer.video.duration * _sliderButton.x) / _timeTrack.width);
					if (calc >= _videoPlayer.video.duration) {
						calc = _videoPlayer.video.duration;
					}
					seek(calc, _videoPlayer.video.isPlaying);
				}
			}
		}

		private function _openFullScreen(e:MouseEvent):void {
			_fullScreenButton.visible = false;
			_normalScreenButton.visible = true;
		}
		
		private function _openNormalScreen(e:MouseEvent):void{
			_fullScreenButton.visible = true;
			_normalScreenButton.visible = false;
		}
		
		private function _openVolumeControl(e:MouseEvent = null):void {
			_volumeBase.visible = true;
		}
		
		private function _closeVolumeControl(e:MouseEvent = null):void {
			_volumeBase.visible = false;
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
			if(!_slidingVideo){
				_sliderButton.x = _timeTrack.x + (_timeTrack.width * value) - _sliderButton.width;
				
				if (_sliderButton.x < _timeTrack.x) {
					_sliderButton.x = _timeTrack.x;
				} else  if (_sliderButton.x > _timeTrack.width) {
					_sliderButton.x = _timeTrack.width;
				}
			}
		}
		
		public function set time(value:Number):void {
			var sec:uint = value % 60;
			var min:uint = (value / 60) % 60;
			fldTimer.text = String(min < 10 ? "0" + min : min) + ":" + String(sec < 10 ? "0" + sec : sec);
		}
		
		public function get sliderButton():Sprite { return _sliderButton; }
		public function get timeTrack():Sprite { return _timeTrack; }
		
		public function get volume():Number { return _volume; }
		public function set volume(value:Number):void {
			_volume = value;
			if (volume <= 0) {
				_mute();
			} else {
				_unMute();
			}
		}
		
	}
	
}