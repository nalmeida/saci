package project_name.service
{
	/**
	@author Marcos Roque (mroque@fbiz.com.br)
	*/
	import as3classes.amf.AMFConnection;
	import as3classes.amf.AMFConnectionEvent;
	import flash.events.ErrorEvent;
	import flash.events.EventDispatcher;
	import flash.utils.setTimeout;
	import project_name.events.BaseEvent;
	
	public class Service extends EventDispatcher
	{
		private var _errorResponse:Object;
		private var _tryes:int;
		
		private var _amfId:String;
		private var _completeMethod:Function;
		private var _args:Array;
		
		/**
		Singleton
		*/
		private static var _instance:Service;
		private static var _allowInstance:Boolean;
		
		public static function getInstance():Service {
			if (Service._instance == null) {
				Service._allowInstance = true;
				Service._instance = new Service();
				Service._allowInstance = false;
			}
			return Service._instance;
		}
		
		public function Service() {
			if (Service._allowInstance !== true) {
				throw new Error("Use the singleton SiteStructure.getInstance() instead of new SiteStructure().");
			}
		}
		
		public function init(gateway:String):void {
			// AMF
			AMFConnection.init(gateway);
			AMFConnection.verbose = true;
			//AMFConnection.close();
		}
		
		
		/**
		Sample
		*/
		public function sampleRecord(id:String):void
		{
			_communicate("sample", _onSampleComplete, ["AMF.Sample.Send"]);
		}
		private function _onSampleComplete(e:AMFConnectionEvent):void {
			trace(this, "_onSampleComplete:", e.answer);
			dispatchEvent(new BaseEvent(BaseEvent.COMMUNICATION_COMPLETE, e.answer));
		}
		
		
		
		/**
		Base
		*/
		private function _communicate(amfId:String, completeMethod:Function, args:Array):void
		{
			_amfId = amfId;
			_completeMethod = completeMethod;
			_args = args;
			
			_callAMF(false);
		}
		public function _callAMF(retry:Boolean = true):void
		{
			if (!retry) { _tryes = 1; } else { _tryes++; }
			trace(this, "_callAMF tryes:", _tryes);
			
			var amfGet:AMFConnection = new AMFConnection(_amfId);
			amfGet.addEventListener(AMFConnectionEvent.COMPLETE, _completeMethod);
			amfGet.addEventListener(AMFConnectionEvent.ERROR, _onErrorSending);
			amfGet.call.apply(null, _args);
		}
		private function _onErrorSending(e:AMFConnectionEvent):void {
			trace("_onErrorSending: " + e.answer);
			if (_tryes < 3)
			{
				setTimeout(_callAMF, 1 * 1000);
				return;
			}
			dispatchEvent(new ErrorEvent(ErrorEvent.ERROR));
		}
		
		/**
		Getter and setter
		*/
		public function get errorResponse():Object { return _errorResponse; }
		
	}
	
}