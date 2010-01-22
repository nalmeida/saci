/**
*	@author igor almeida
*	@vervion 1.0
**/
package redneck.services {
	
	import flash.events.*;
	import flash.net.*;
	
	import br.com.stimuli.string.printf;
	
	import redneck.project.log.*;
	import redneck.events.*;
	import redneck.util.*;
	
	[Event(name="onComplete", type="redneck.events.ServiceEvent")]
	[Event(name="onError", type="redneck.events.ServiceEvent")]
	[Event(name="onStart", type="redneck.events.ServiceEvent")]
	[Event(name="onProgress", type="redneck.events.ServiceEvent")]
	
	public class Service extends EventDispatcher {

		protected var _status : String
		protected var _params : Object
		protected var _initialParams : Object;
		private var _url : String
		private var _method: String
		private var _urlrequest : URLRequest;
		private var urlloader : URLLoader;
		protected var _progressEvent : ServiceEvent;
		protected var _completeEvent : ServiceEvent;
		protected var _errorEvent : ServiceEvent;
		protected var _startEvent : ServiceEvent;

		public static const STATUS_COMPLETE : String = "complete";
		public static const STATUS_STARTED : String = "started";

		public var id : String;
		public var toReplace: Object;
		public var result : *;
		
		/**
		*	@param	p_id		String
		*	@param	p_url		String
		*	@param	p_method 	String
		*	@param	p_params	Object
		**/
		public function Service( p_id:String, p_url:String, p_method:String = URLRequestMethod.GET, p_params:* =null ):void
		{
			super();
			_url = p_url;
			_initialParams = checkParams( p_params );
			_method = (p_method == null || p_method.length==0) ? URLRequestMethod.GET : ( p_method.toLocaleLowerCase().indexOf("g")!=-1 ) ? URLRequestMethod.GET : URLRequestMethod.POST;
			_status = STATUS_COMPLETE;
			_urlrequest = new URLRequest();
			_progressEvent = new ServiceEvent( ServiceEvent.ON_PROGRESS, true );
			_startEvent = new ServiceEvent( ServiceEvent.ON_START, true );
			_errorEvent = new ServiceEvent( ServiceEvent.ON_ERROR, true );
			_completeEvent = new ServiceEvent( ServiceEvent.ON_COMPLETE, true );
			id = p_id;
		}
		/**
		*	@return String
		**/
		public function get url ( ): String{
			return printf( _url, toReplace );
		}
		/**
		*	@return String
		**/
		public function get method ():String{
			return _method;
		}
		/**
		*	@return String
		**/
		public function get status():String
		{
			return _status;
		}
		/**
		*	@return URLRequest
		**/
		public function get urlRequest () : URLRequest{
			_urlrequest.url = url;
			injectParams( _params || _initialParams );
			return _urlrequest;
		}
		/**
		*	Set parameters to apply on the URLRequest
		*	@param	p_params	String or Object
		**/
		public function set parameters (p_params : *) :void{
			_params = p_params;
		}
		/**
		*	Apply all all parameters on urlRequest
		**/
		private function injectParams( p_params : * ):void{
			_urlrequest.method = method;
			if ( method == URLRequestMethod.GET ){
				_urlrequest.url = url;
				_urlrequest.url += parseGET( checkParams( p_params ) );
			}
			else{
				_urlrequest.data = parsePOST( checkParams( p_params ) )
			}
		}
		/**
		*	
		*	Start the service call
		*	
		*	@param p_params	*
		*	@param p_request URLRequestMethod in this case, if you want to make special changes on the URLRequest you can pass a specific one.
		*	@return Boolean
		*	
		**/
		public function call( p_params:*=null, p_request : URLRequest = null ) : Boolean
		{
			if (p_params){
				parameters = p_params;
			}
			if ( _status != "complete" ){
				log("service runing...", LogEvent.ERROR);
				return false;
			}
			log( "calling service: " + toString( ) , LogEvent.VERBOSE );

			_status = STATUS_STARTED;
			_startEvent.url = p_request ? p_request.url : urlRequest.url;
			dispatchEvent( _startEvent.clone( ) );
			urlloader = new URLLoader( );
			urlloader.addEventListener( IOErrorEvent.IO_ERROR, error );
			urlloader.addEventListener( SecurityErrorEvent.SECURITY_ERROR, error );
			urlloader.addEventListener( ProgressEvent.PROGRESS, progress );
			urlloader.addEventListener( Event.COMPLETE, complete );
			urlloader.load( p_request || urlRequest );

			return true;
		}
		/**
		*	Create a string with object properties at GET model
		*	
		*	@param p_obj Object
		*	
		*	@return String
		**/
		private function parseGET( p_obj : Object = null ):String{
			if (p_obj == null){
				return "";
			}
			var result : String = "?";
			for( var prop : String  in p_obj){
				result += prop+"="+p_obj[prop]+"&";
			}
			result = result.slice(0,result.length-1);
			return result;
		}
		/**
		*	Create URLVariables with p_obj
		*	
		*	@param p_obj Object
		*	
		*	@return URLVariables
		**/
		private function parsePOST( p_obj :Object = null ) : URLVariables {
			var result : URLVariables = new URLVariables()
			if ( p_obj == null ){
				return result;
			}
			for( var prop : String  in p_obj){
				result[prop] = p_obj[prop];
			}
			return result;
		}
		/**
		*	Clear all listeners and recreate the <code>urlrequest</code>
		**/
		private function clearListeners():void{
			if(!urlloader){
				return;
			}
			urlloader.removeEventListener( IOErrorEvent.IO_ERROR, error );
			urlloader.removeEventListener( SecurityErrorEvent.SECURITY_ERROR, error );
			urlloader.removeEventListener( ProgressEvent.PROGRESS, progress );
			urlloader.removeEventListener( Event.COMPLETE, complete );
			_urlrequest = new URLRequest();
		}
		/**
		*	redispatch events
		*	@param e:Event
		*	@dispatchs ServiceEvent.ON_ERROR and the original error at <code>ServiceEvent.text</code>
		**/
		protected function error( e:Event ):void{
			_status = STATUS_COMPLETE;
			clearListeners();
			_errorEvent.text = e.toString();
			_errorEvent.url = urlRequest.url;
			dispatchEvent( _errorEvent.clone() );
		}
		/**
		*	redispatch events
		*	@param e:Event
		*	@dispatchs ServiceEvent.ON_PROGRESS
		**/
		protected function progress( e:ProgressEvent ):void{
			_progressEvent.bytesTotal = e.bytesTotal;
			_progressEvent.bytesLoaded = e.bytesLoaded;
			_progressEvent.url = urlRequest.url;
			dispatchEvent( _progressEvent.clone() );
		}
		/**
		*	redispatch events
		*	@param e:Event
		*	@dispatchs ServiceEvent.ON_COMPLETE
		**/
		protected function complete(e:Event):void{
			_status = STATUS_COMPLETE;
			clearListeners();
			if (urlloader){
				if (urlloader.data){
					result = urlloader.data;
					if(result){
						result = result.toString();
					}
					_completeEvent.url = urlRequest.url;
				}
				dispatchEvent( _completeEvent.clone() );
			}
		}
		/**
		*	simple parse to tranform string in objects
		*	
		*	@param p_params
		*	
		*	@example
		*	var s : Service = new Service("g","http://google.com/search","get","id=10,text=10")
		*	
		**/
		private function checkParams( p_params:*=null ):Object{
			if( p_params==null ){
				return null;
			}
			else if ( p_params is String ){
				var result : Object = new Object();
				var a : Array = p_params.indexOf(",") >-1 ? p_params.split(",") : p_params.indexOf(";")>-1 ? p_params.split(";") : p_params.indexOf("&") ? p_params.split( "&" ) : [ ];
				for each( var prop:String in a ){
					var i : Array = prop.indexOf("=")>-1 ? prop.split("=") : prop.indexOf(":")>-1 ? prop.split(":") : [];
					if ( ( i.length==0 ) || (i[0].length==0 || i[1].length==0) ){
						continue;
					}
					result[i[0]] = i[1];
				}
				return result;
			}
			else if ( p_params is Object ){
				return p_params;
			}
			return null;
		}
		/**
		*	destroy service
		**/
		public function destroy():void{
			clearListeners();
			_progressEvent = null;
			_urlrequest = null;
			try{urlloader.close()}catch(err:*){};
			urlloader = null;
			result = null;
			_completeEvent = null;
			_errorEvent = null;
			_progressEvent = null;
			_startEvent = null;
		}
		/**
		*	@return String
		**/
		public override function toString():String{
			return "[Service name:'"+id+"', url:'"+urlRequest.url+"', method:'"+method+"', params:'"+ ( (method==URLRequestMethod.POST) ? parseGET( _params || _initialParams ) : "") +"']";
		}
	}
}

