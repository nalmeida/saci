/**
*
* @author igor almeida
* @version 1.0
*
* @todo - parse external xml to create a new form.
* @todo - figure out how resolve fields with multi multi views.
*
**/
package redneck.form
{
	import flash.display.*;
	import flash.events.*;
	import flash.net.*;
	import redneck.form.field.*
	import redneck.services.*;
	import redneck.events.*;
	public class Form extends EventDispatcher
	{
		private var _fields : Array;
		private var _errors : Array;
		private var _service : Service
		private var _name : String
		/**
		* 
		* @param p_name	String
		* @param p_name String
		* @param p_method String;
		* 
		**/
		public function Form( p_name:String, p_url:String, p_method:String = URLRequestMethod.GET ):void
		{
			super(null);
			_name = p_name;
			_errors = [];
			_fields = [];
			_service = new Service( p_name, p_url, p_method );
		}
		/**
		*	@see Service
		*	@return Service
		**/
		public function get service():Service
		{
			return _service;
		}
		/**
		* 
		* Returns a Field instance
		* 
		* @param p_name String
		* @see Field
		* 
		* @return Field
		**/
		public function getField(p_name:String):Field{
			for each(var p_field:Field in _fields){
				if(p_field.name==p_name){
					return p_field;
				}
			}
			return null;
		}
		/**
		* 
		* Add a new Field. The field list will be sorted out using the <code>Field.index</code> property
		* 
		* @param p_field Field
		* @see Field
		* 
		* @return Boolean
		* 
		**/
		public function addField( p_field:Field ):Boolean{
			var result : Boolean = false;
			if (p_field==null){
				return result;
			}else if ( getField( p_field.name )!=null ){
				return result;
			}
			result = true
			_fields.push(p_field);
			_fields.sortOn("index",Array.NUMERIC);
			return result;
		}
		/**
		* @param p_field *	field name or Field instance
		* @return Boolean
		**/
		public function removeField( p_field:* ):Boolean{
			var result : Boolean;
			var f : Field;
			if (p_field is String){
				f = getField(p_field)
			}else if (p_field is Field){
				f = getField(p_field.name);
			}else{
				return result;
			}
			if(f!=null){
				f.destroy();
				_fields.some( function (item:*, i:int, a:Array):Boolean{
					if( item == f ){
						_fields.splice( i, 1 );
						return true;
					}
					return false;
				}, null )
				_fields.sortOn("index",Array.NUMERIC);
				return true;
			}
			return false;
		}
		/**
		* 
		* Run over all fields and validate then.
		* If false you can catch all erros on <code>Form.errors</code>
		* 
		* @see errors
		* @see Field.validate
		* 
		* @return Boolean 
		* 
		**/
		public function validate():Boolean{
			_errors = new Array();
			_fields.forEach(function(item:Field,...rest):void{
				if (!item.validate()){
					_errors.push( new FormError(item) );
				}
			},null);
			return isValid;
		}
		/**
		*	
		*	Return an Array with all collected data.
		*	
		*	@param p_freeze	Boolean optional to perform the <code>FieldView.freeze</code>
		*	
		*	@see FieldView
		*	
		*	@return Array
		*	
		**/
		public function collectData( p_freeze : Boolean = false):Array{
			var fieldValues : Array = []
			_fields.forEach( function(p_field:Field, ...rest):void{
				if (!p_field.onlyClient){
					fieldValues.push(p_field.name+":"+p_field.value);
					if(p_freeze && p_field.view){
						p_field.view.freeze();
					}
				}
			},null );
			return fieldValues;
		}
		/**
		* 
		* Submit this form. 
		* 
		* @param p_urlRequest	URLRequest the ideia to allow a new urlRequest is to modifiy ou add new items, images etc on it.
		* @see isValid
		* 
		* @rerutn Boolean false if the for is not valid or if it is under progress
		* 
		**/
		public function submit( p_urlRequest :URLRequest = null, p_validateBefore : Boolean = false ):Boolean{
			if ( p_validateBefore ){
				validate();
			}
			if(!isValid || _service.status!=Service.STATUS_COMPLETE ){
				return false;
			}
			_service.addEventListener(ServiceEvent.ON_COMPLETE,status)
			_service.addEventListener(ServiceEvent.ON_ERROR,status)
			_service.addEventListener(ServiceEvent.ON_START,status)
			_service.addEventListener(ServiceEvent.ON_PROGRESS,status)
			_service.call( collectData( ).toString() , p_urlRequest );
			return true;
		}
		/**
		* @private
		* clean all service listeners
		**/
		private function clearListeners():void{
			_service.removeEventListener(ServiceEvent.ON_COMPLETE,status);
			_service.removeEventListener(ServiceEvent.ON_ERROR,status);
			_service.removeEventListener(ServiceEvent.ON_START,status);
			_service.removeEventListener(ServiceEvent.ON_PROGRESS,status);
		}
		/**
		* @private
		* monitore the service call status
		**/
		private function status(e:*):void{
			if(e is Event){
				if (e.type == ServiceEvent.ON_ERROR || e.type == ServiceEvent.ON_COMPLETE){
					clearListeners();
					_fields.forEach( function(p_field:Field, ...rest):void{
						if(p_field.view){
							p_field.view.unfreeze();
						}
					},null );
				}
				dispatchEvent(e.clone());
			}
		}
		/**
		* kill all.
		**/
		public function destroy():void{
			clearListeners();
			_fields.forEach( function(p_field:Field, ...rest):void{
				p_field.destroy();
			},null );
			_fields = [];
			_errors = [];
			_service.destroy();
			_service = null;
		}
		/**
		* check if have some field error
		* @see validate
		* @return Boolean
		**/
		public function get isValid():Boolean{
			return (errors.length==0);
		}
		/**
		* @return String
		**/
		public function get name():String
		{
			return _name;
		}
		/**
		* @see getField
		* @return Array
		**/
		public function get fields():Array
		{
			return _fields;
		}
		/**
		* @see validate
		* @return Array
		**/
		public function get errors():Array
		{
			return _errors;
		}
		/**
		* @return URLRequest
		**/
		public function get urlRequest():URLRequest
		{
			return _service.urlRequest;
		}
		/**
		* @return String
		**/
		public function get url():String
		{
			return _service.url;
		}
		/**
		* @return String
		**/
		public function get method():String
		{
			return _service.method;
		}
		/**
		* return the form submition result.
		* @param *
		**/
		public function get result():*{
			return _service.result;
		}
	}
}
import redneck.form.field.Field;
internal class FormError{
	public var field: Field
	public var errors:Array
	public function FormError(p_field:Field):void{
		field = p_field;
		errors = field.errors;
	}
	public function toString():String{
		return "-FormError\nfield:"+field+"\nerrors:"+errors.join("\n");
	}
}