package saci.uicomponents.videoPlayer {
	
	/**
	 * @author Nicholas Almeida
	 */
	public class VideoInfoVO{
		
		private var _id:String;
		private var _flv:String;
		private var _img:String;
		private var _thumbImg:String;
		private var _title:String;
		private var _description:String;
		
		public function VideoInfoVO($id:String, $flv:String, $img:String = null, $title:String = null, $description:String = null, $thumbImg:String = null) {
			_id = $id;
			_flv = $flv;
			_img = $img;
			_thumbImg = $thumbImg;
			_title = $title;
			_description = $description;
		}
		
		public function toString():String {
			return "[VideoInfoVO] id: " + id;
		}
		
		public function get id():String { return _id; }
		public function get flv():String { return _flv; }
		public function get img():String { return _img; }
		public function get thumbImg():String { return _thumbImg; }
		public function get title():String { return _title; }
		public function get description():String { return _description; }

	}

	
}