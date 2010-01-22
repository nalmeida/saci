package redneck.project.control {

	import flash.events.*;
	import flash.system.LoaderContext;
	import flash.media.SoundLoaderContext;
	import flash.system.ApplicationDomain;

	import br.com.stimuli.loading.*;
	import br.com.stimuli.string.*;	

	import redneck.util.string.trim;
	import redneck.core.IDisposable;
	import redneck.sound.SoundController;
	import redneck.util.isStandAlone;
	import redneck.util.valueFromXML;
	import redneck.services.Service;
	import redneck.services.services;
	import redneck.project.misc.xmlToLoaderProperty;
	import redneck.project.log.log;
	import redneck.events.LogEvent;
	import redneck.project.misc.getSoundControllerByXML;
	import redneck.util.ExtendedObject;

	public class ProcessLoader extends EventDispatcher implements IDisposable {

		private var lazyXML : XML;

		public var loaderContext : LoaderContext;
		public var soundContext : SoundLoaderContext;
		public var config : ExtendedObject

		private var _dependencies : BulkLoader;
		private var _soundController : SoundController;
		private var _loadAll : Boolean;
		private var _name : String;
		
		private function get uid( ):String{return _name + "_" + (UID++);}

		public static const COMPLETE : String = "processComplete";
		public static const ERROR : String = "processError";
		
		private static var UID : int;
		
		public function ProcessLoader( p_name:String )
		{
			super( null );

			loaderContext = new LoaderContext( false, ApplicationDomain.currentDomain, null); 
			soundContext = new SoundLoaderContext( );

			_name = trim(p_name);
			_dependencies = new BulkLoader( uid );
			_dependencies.logLevel = BulkLoader.LOG_ERRORS;

			UID++;
		}

		public function get name():String{return _name;}
		public function get soundController ( ) : SoundController {return _soundController}
		public function get dependencies ( ) : BulkLoader{ return _dependencies;}
		/**
		*	
		*	Starts the load of <code>p_url</code> and if <code>p_loadAll</code> is true loads also the possible dependencies on this xml
		*	
		*	@param p_url		String
		*	@param p_loadAll	Boolean
		*	
		**/
		public function startLazyLoader( p_url:String, p_loadAll : Boolean = false ):void{
			_loadAll = p_loadAll;
			_dependencies.addEventListener( BulkLoader.ERROR, redispatch, false, 0, true );
			_dependencies.addEventListener( ErrorEvent.ERROR, redispatch, false, 0, true );
			_dependencies.addEventListener( BulkLoader.COMPLETE, lazyLoaderComplete, false, 0, true );
			_dependencies.add( printf( p_url, config ), { id:"lazyLoader", type:"xml", preventCache:!isStandAlone( ) } );
			_dependencies.start( );
		}
		/**
		*	@private
		*	
		*	stores the current lazy xml on <code>lazyXML</code> and start the dependencies load.
		*	
		**/
		private function lazyLoaderComplete( e:Event ):void{

			cleanDependenciesListeners();

			lazyXML = _dependencies.getXML( "lazyLoader" );
			if ( !lazyXML ){
				var evt : Event = new Event( BulkLoader.ERROR );
				redispatch( new Event( BulkLoader.ERROR ) );
			}
			else{
				if ( _loadAll ){
					loadDependencies( lazyXML );
				}else{
					redispatch( new Event(BulkLoader.COMPLETE) );
				}
			}
			_loadAll = false;
		}
		/**
		*	
		*	Carrega as dependencias de um xml.
		*	
		*	@param p_data	*	if String will try to load a lazyxml and then load the dependencies from xml, else XML with dependencies list.
		*	
		**/
		public function loadDependencies( p_data : * = null ):void{
			if ( p_data is String ){
				startLazyLoader( p_data, true );
			}
			else if ( p_data is XML ){
				var src : String = valueFromXML( p_data , "src" );
				if ( src && src.toString().length > 0 ){
					startLazyLoader( src, true );
				}
				else{
					lazyXML = p_data;
					loadLazyLoaderDependencies( );
				}
			}
			else{
				loadLazyLoaderDependencies( );
			}
		}
		/**
		*	@private
		*	
		*	faz o parse do lazy xml carregado, adiciona todas as dependencias 
		*	que estiverem nele e inicia o carregamento delas, se necessário.
		*
		**/
		private function loadLazyLoaderDependencies( ):void{

			cleanDependenciesListeners()

			var total : int = int(dependencies.itemsTotal);
			if ( lazyXML ){
				if ( lazyXML.hasOwnProperty("services" ) && lazyXML.services.hasOwnProperty("service") ){
					for( i in lazyXML.services.service ){
						var name :String = valueFromXML( lazyXML.services.service[ i ],"name");
						var params : String = valueFromXML( lazyXML.services.service[ i ],"params");
						var method : String = valueFromXML( lazyXML.services.service[ i ],"method");
						var url : String = valueFromXML(lazyXML.services.service[ i ],"url");
						if (name.length>1 && url.length>1){
							var service:Service = services().add( name, url, method, params );
							if (service){
								service.toReplace = config;
							}
						}
					}
				}
				if ( lazyXML.hasOwnProperty("dependencies" ) ){
					if (lazyXML.dependencies.hasOwnProperty("file")){
						for( var i:String in lazyXML.dependencies.file ){
							var file:Object = xmlToLoaderProperty( new XML( lazyXML.dependencies.file[ i ] ) );
							if ( file.context == true ){
								file[ BulkLoader.CONTEXT ]  = BulkLoader.guessType( file.path ) == BulkLoader.TYPE_SOUND ? soundContext : loaderContext;
							}
							dependencies.add( printf( file.path, config ), file );
						}	
					}
					if ( lazyXML.dependencies.hasOwnProperty("service") ){
						for ( var s : String in lazyXML.dependencies.service ){
							var serv : Service = services( valueFromXML( lazyXML.dependencies.service[ s ],"name") || valueFromXML( lazyXML.dependencies.service[ s ],"id") );
							if ( serv && serv is Service ){
								dependencies.add( serv.urlRequest, {id:serv.id} );
							}
						}
					}
				}
				if ( dependencies.itemsTotal == dependencies.itemsLoaded ){
					nothingToLoad( );
					return;
				}
				else{
					log("loading dependencies...",LogEvent.VERBOSE);
					startDependenciesLoading( );
				}
			}
			else if( dependencies.itemsTotal != dependencies.itemsLoaded ){
				log("loading dependencies injected manually", LogEvent.VERBOSE)
				startDependenciesLoading();
			}
			else{ 
				nothingToLoad();
				return;
			}
		}
		/**
		*	load dependencies
		**/
		private function startDependenciesLoading():void{
			_dependencies.addEventListener( BulkLoader.ERROR, redispatch );
			_dependencies.addEventListener( ErrorEvent.ERROR, redispatch );
			_dependencies.addEventListener( BulkLoader.COMPLETE, parseDependencies ) ;
			_dependencies.start( );
		}
		/**
		*	just notify
		*/
		private function nothingToLoad():void{
			log("nothing to load or everything already laoded!", LogEvent.VERBOSE);
			redispatch( new Event(BulkLoader.COMPLETE) );
		}
		/**
		*	parse the current dependencies looking for <code>services</code> or <code>Sounds</code> to inject on <code>soundController</code>
		**/
		private function parseDependencies ( e:Event ) : void {
			cleanDependenciesListeners();
			if ( lazyXML && lazyXML.hasOwnProperty( "dependencies" ) ){
				if ( lazyXML.dependencies.hasOwnProperty("service") ){
					for ( var s : String in lazyXML.dependencies.service ){
						var serv : * = services( valueFromXML( lazyXML.dependencies.service[ s ],"name") || valueFromXML( lazyXML.dependencies.service[ s ],"id") )
						if ( serv && serv is Service ){
							serv.result = _dependencies.getContent( serv.id );
						}
					}
				}
				_soundController = getSoundControllerByXML( "soundController_"+UID , dependencies, new XML( lazyXML.dependencies) );
			}
			redispatch( new Event(BulkLoader.COMPLETE) );
		}
		/**
		*	diposes all
		**/
		public function dispose( ...rest ):void{
			if(soundController){
				_soundController.dispose( );
			}
			if(_dependencies){
				_dependencies.removeAll( );
			}
		}
		/**
		*	clean all listeners
		**/
		private function cleanDependenciesListeners():void{
			if (_dependencies){
				_dependencies.removeEventListener( BulkLoader.ERROR, redispatch )
				_dependencies.removeEventListener( ErrorEvent.ERROR, redispatch ),
				_dependencies.removeEventListener( BulkLoader.COMPLETE, lazyLoaderComplete ) ;
				_dependencies.removeEventListener( BulkLoader.COMPLETE, parseDependencies ) ;
				_dependencies.removeEventListener( BulkLoader.COMPLETE, lazyLoaderComplete ) ;
			}
		}
		/**
		*	just changing event class
		**/
		private function redispatch( e:Event ) : void{
			var evt:Event;
			if ( e.type == BulkLoader.COMPLETE ){
				evt = new Event( ProcessLoader.COMPLETE, false, true );
			}
			else{
				evt = new Event( ProcessLoader.ERROR, false, true );
				log( "loading error: " + (e.hasOwnProperty("text")?e["text"]:e.type) , LogEvent.ERROR );
			}
			dispatchEvent( evt );
		}
	}
}

