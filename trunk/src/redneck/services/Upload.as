package redneck.services {
	import flash.events.*;
	import flash.net.*;
	import redneck.services.*;
	public class Upload extends Service {
		
		private var _file : FileReference;
		public static const FILTER_TEXT : Array = [new FileFilter("*", "*.txt;*.rtf;*.pdf;*.doc;*.diff;*.todo;*.log;")];
		public static const FILTER_IMAGE : Array = [new FileFilter("*", "*.bmp;*.gif;*.pdf;*.jpg;*.jpeg;*.png;*.tiff;")];
		public static const FILTER_AUDIO : Array = [new FileFilter("*", "*.mp3;*.mid;*.wav;*.aac;")];
		public static const FILTER_ALL : Array = [new FileFilter("*", "*.*")];
		public static const STATUS_READY : String = "ready";
		public static const STATUS_EMPTY : String = "empty";
		public var maxSize : int = 0
		/**
		*	@param	p_id		String
		*	@param	p_url		String
		*	@param	p_method 	String
		*	@param	p_params	Object
		**/
		public function Upload( p_id:String, p_url:String, p_method:String = URLRequestMethod.GET, p_params:* =null ):void{
			super(p_id, p_url, p_method, p_params);
			_status = STATUS_EMPTY;
		}
		/**
		*	@FileReference
		**/
		public function get file():FileReference
		{
			return _file;
		}
		/**
		*	Browse for selection
		*	
		*	@param p_filter	Array
		*	@see FILTER_ALL
		*	@see FILTER_AUDIO
		*	@see FILTER_IMAGE
		*	@see FILTER_TEXT
		*	
		**/
		public function browse( p_filter:Array = null ):void{
			var filter : Array = p_filter || FILTER_ALL;
			_file = new FileReference();
			_file.addEventListener( IOErrorEvent.IO_ERROR, error );
			_file.addEventListener( SecurityErrorEvent.SECURITY_ERROR, error );
			_file.addEventListener( ProgressEvent.PROGRESS, uploadPprogress );
			_file.addEventListener( Event.CANCEL, cancelHandler );
			_file.addEventListener( Event.SELECT, selectHandler );
			_file.addEventListener( DataEvent.UPLOAD_COMPLETE_DATA,uploadCompleteDataHandler );
			_file.browse( filter );
		}
		/**
		*	True is is ready
		*	
		*	@see ready
		*	@return Boolean
		*	
		**/
		public function upload(p_params:*=null):Boolean{
			if (status == STATUS_READY){
				_status = STATUS_EMPTY;
				parameters = p_params || _initialParams;
				dispatchEvent(_startEvent.clone());
				_file.upload(super.urlRequest);
				return true;
			}
			return false;
		}
		/**
		*	@see updaload
		**/
		public override function call( p_params:*=null, p_request : URLRequest = null ) : Boolean
		{
			return false;
		}
		/**
		*	Browser cancel hander
		**/
		private function cancelHandler(e:Event):void{
			_status = STATUS_EMPTY;
			dispatchEvent( e.clone() )
		}
		private function selectHandler(e:Event):void{
			if (maxSize==0 ||file.size<maxSize){
				_status = STATUS_READY;
				dispatchEvent( e.clone()  );
			}else{
				dispatchEvent( new Event( Event.CANCEL )  );
			}
			
		}
		/**
		*	manage loading event
		**/
		private function uploadPprogress(e:ProgressEvent):void{
			_progressEvent.bytesTotal = e.bytesTotal;
			_progressEvent.bytesLoaded = e.bytesLoaded;
			_progressEvent.url = urlRequest.url;
			dispatchEvent( _progressEvent.clone() );
		}
		private function uploadCompleteDataHandler(e:DataEvent):void{
			_status = STATUS_EMPTY;
			clearListeners();
			if ( e ){
				_file = null;
				result = e.data;
				_completeEvent.url = urlRequest.url;
				dispatchEvent( _completeEvent.clone() );
			}
		}
		/**
		*	clear this mess
		**/
		private function clearListeners():void{
			if (_file){
				_file.removeEventListener( IOErrorEvent.IO_ERROR, error );
				_file.removeEventListener( SecurityErrorEvent.SECURITY_ERROR, error );
				_file.removeEventListener( ProgressEvent.PROGRESS, uploadPprogress );
				_file.removeEventListener( Event.CANCEL, cancelHandler );
				_file.removeEventListener( Event.SELECT, selectHandler );
				_file.removeEventListener( DataEvent.UPLOAD_COMPLETE_DATA,uploadCompleteDataHandler );
			}
		}
		/**
		*	clear listeners and destroy instance
		**/
		public override function destroy():void{
			_file = null;
			super.destroy();
		}
	}
}