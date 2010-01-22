package redneck.services {
	import flash.net.URLRequestMethod;
	public class ServiceLocator {
		public var services : Object
		public function ServiceLocator()
		{
			super();
			services = new Object();
		}
		/**
		*	
		*	@param	p_id	String
		*	@param	p_url	String
		*	@param p_method String
		*	
		**/
		public function add( p_id:String, p_url:String, p_method:String = URLRequestMethod.GET, p_params : * = null ):Service{
			if ( services[p_id] == null ){
				var service : Service = new Service( p_id, p_url, p_method, p_params )
				services[service.id] = service;
				return service;
			}
			else{
				trace("ServiceLocator there is another service with name '"+p_id+"'.");
			}
			return null;
		}
		/**
		*	
		*	@param	p_service	String or Service
		*	
		*	@return Boolean
		*	
		**/
		public function remove( p_service : * ):Boolean{
			var service : Service;
			if ( p_service is String ){
				service = get(p_service);
			}
			else if ( p_service is Service ){
				service = get(p_service.id);
			}
			else{
				return false;
			}
			if(service){
				service.destroy();
				services[ service.id ] = null
				delete services[ service.id ];
				return true;
			}
			return false;
		}
		/**
		*	
		*	@param	p_id : String;
		*	
		*	@return Service
		*	
		**/
		public function get( p_id : String ) : Service{
			return services[ p_id ];
		}
		/**
		*	
		*	retorn list with all services ids
		*	
		*	@return Array
		*	
		**/
		public function list():Array{
			var result:Array = new Array()
			for(var prop :String in services){
				result.push( prop )
			}
			return result;
		}
	}
}

