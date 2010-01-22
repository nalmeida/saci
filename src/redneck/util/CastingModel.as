package redneck.util {
	import com.adobe.serialization.json.JSON
	public class CastingModel{
		/**
		*	
		*	@param p_model Object
		*	@param p_param	String
		*	
		*	@return the same object passed in <code>p_model</code> with the values from <code>p_param</code>
		*	
		**/
		public static function fromString( p_model:Object, p_param : String ):*{
			if ( p_model == null || p_param == null ){
				return null;
			}
			var obj : Object;
			try{
				obj = JSON.decode( p_param );
				if ( obj==null ) return null;
			}catch(e:Error){
				trace("[CastingModel] error decoding result: " + p_param + " error: " + e.getStackTrace() );
				return null;
			}
			return fromObject( p_model, obj );
		}
		/**
		*	
		*	@param p_model Object
		*	@param p_param	XML
		*	
		*	@return the same object passed in <code>p_model</code> with the values from <code>p_param</code>
		*	
		**/
		public static function fromXML( p_model:Object, p_param : XML ):*{
			if ( p_model == null || p_param == null ){
				return null;
			}
			var result : * = p_model;
			if (p_param.children() == false){
				return false;
			}
			else{
				var o : Object = {};
				var prop : *
				for each( prop in p_param.child("*") ){
					o[prop.name()] = prop.toString();
				}	
			}
			return fromObject( p_model, o );
		}
		/**
		*	
		*	@param p_model Object
		*	@param p_param	Object
		*	
		*	@return the same object passed in <code>p_model</code> with the values from <code>p_param</code>
		*	
		**/
		public static function fromObject( p_model:Object, p_param : Object ): *
		{
			if ( p_model == null || p_param == null ){
				return null;
			}
			var result : * = p_model;
			var prop: String;
			for ( prop in p_param ){
				result.hasOwnProperty(prop) ? result[prop] = p_param[prop] : null;
			}
			return result;
		}
		/**
		*	
		*	Decide accourding to the data type which method to perform.
		*	
		*	@param p_model Object
		*	@param p_param	Object
		*	
		*	@return the same object passed in <code>p_model</code> with the values from <code>p_param</code>
		*	
		**/
		public static function resolve( p_model : Object, p_param : * ): *
		{
			if ( p_model == null || p_param == null ){
				return null;
			}
			if ( p_param is XML ){
				return fromXML( p_model, p_param );
			}else if ( p_param is String ){
				return fromString( p_model, p_param );
			}else{
				return fromObject( p_model, p_param );
			}
			return null;
		}
	}
}