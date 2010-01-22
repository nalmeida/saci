/**
 * @author igor almeida
 * @version 2.0
 * 
 **/
package redneck.project
{
	import br.com.stimuli.loading.*;
	import br.com.stimuli.string.*;
	
	import flash.display.*;
	import flash.events.*;
	import flash.media.*;
	import flash.system.*;
	
	import redneck.project.*
	import redneck.util.ExtendedObject;
	import redneck.project.log.*;
	import redneck.project.control.*
	import redneck.project.language.*;
	import redneck.project.misc.*;
	import redneck.events.*
	import redneck.util.*;
	import redneck.util.string.trim;
	import redneck.project.contextmenu.*;
	/**
	 *	Dispatched when the config xml file is loaded.
	 */
	[Event(name="ON_CONFIG_LOADED", type="redneck.events.ProjectEvent")]
	/**
	 *	Dispatched when the <code>config.xml</code> and all dependencies are loadeds.
	 */
	[Event(name="ON_DEPENDENCIES_LOADED", type="redneck.events.ProjectEvent")]
	/**
	 *	Dispatched when any error ocurres. Usually this error is after a <code>log()</code> message.
	 */
	[Event(name="ON_ERROR", type="redneck.events.ProjectEvent")]
	/***/
	public class Project extends EventDispatcher
	{	
		/*  stores the config xml */
		public var configXML : XML;
		/* use to put background and everything under the main content. */ 	
		public var layerBackground : Sprite
		/* all site content using the Project will be putted on this Sprite */
		public var layerContent : Sprite
		/* layer to put blocker, if you have. */
		public var layerBlocker : Sprite
		/* layer to put all alerts, loaders and everything with need to be show on the top */
		public var layerAlert : Sprite;
		/* scope to add all content layers */
		public var scope:Sprite;
		/*  all histories */
		public var logHistory:Array

		/* controls the context menu */
		private var _contextMenu : Boolean = false;
		/* context menu instance */
		private var _menu : ContextNavigation

		/*manages all string substitutions*/
		private var _config : ExtendedObject
		public function get config(  ):ExtendedObject{
			if (!_config){_config = new ExtendedObject();}
			return _config;
		}

		/*project's name*/
		private var _name : String
		public function get name():String{return _name};

		/* relative paths lib */
		private var _relativePaths : Array
		public function get relativePaths( ):Array{ return _relativePaths };

		/* navigation instance */
		private var _navigation : Navigation;
		public function get navigation ( ) : Navigation{ return _navigation; }

		/*load all dependencies*/
		private var _process: ProcessLoader ;
		public function get dependencies ( ) : BulkLoader{ return _process.dependencies; }

		/* static reference */
		private static var instances : Object;
		/**
		 * 
		 * Retorna uma instance de project
		 * 
		 * @param p_name String
		 * 
		 * @return Project
		 * 
		 * */
		public static function getProjectById( p_name : String ) : Project
		{
			return instances[ p_name ]; 
		}
		/**
		*	@param	LogEvent	
		**/
		private function addLogHistory(e:LogEvent):void{
			logHistory.push( e.text );
			if (config.quiet==false){
				if( ( config.logLevel == LogEvent.ERROR && e.type == LogEvent.ERROR ) || config.logLevel == LogEvent.VERBOSE ){
					trace(e.text);
				}
			}
		}
		/**
		 * 
		 *	Creates a new Project instance
		 *	
		 *	@see setConfig
		 * 
		 *	@param	p_name	String 
		 *	@param	p_scope	Object place to add all layers
		 * 
		 * */
		public function Project( p_name: String, p_scope:Sprite ) : void
		{
			super( );

			if ( !instances ) {
				instances = new Object( );
			}

			if ( !instances[ p_name ] ){
				instances[ p_name ] = this;
			} else {
				throw new Error ( "There is another Project with name: '" + name + "'" );
			}

			_name = p_name

			config.logLevel		= LogEvent.ERROR;
			config.quiet		= true;

			scope	= p_scope;

			logHistory = new Array();

			log( ).addEventListener( LogEvent.VERBOSE, addLogHistory, false, 0, true )
			log( ).addEventListener( LogEvent.ERROR, addLogHistory, false, 0, true ) ;
			
			layerAlert		= new Sprite();
			layerBlocker	= new Sprite();
			layerContent	= new Sprite();
			layerBackground	= new Sprite();
			
			scope.addChild( this.layerBackground );
			scope.addChild( this.layerContent );
			scope.addChild( this.layerBlocker );
			scope.addChild( this.layerAlert );
			
			_relativePaths	= new Array();
			_navigation		= new Navigation( this, this.layerContent );
			_process = new ProcessLoader( name );
			_process.config = this.config
			
			language( ).addEventListener(Event.CHANGE, updateLocale, false, 0, true);
			language( ).stringReplace = this.config;
		}
		/**
		 *
		 * Start loading the config.xml
		 * 
		 *	@param	p_configXMLPath	String	path to config.xml
		 *	@param	p_parameters	Object
		 *	
		 * @dispatchs Event.INIT before start the main loading.
		 * 
		 * */
		public function start( p_configPath:String = null , p_parameters : Object = null ) : void
		{
			config.configPath = p_configPath;

			if ( p_parameters ){
				for ( var vars:String in p_parameters ){
					config[ vars ] = p_parameters[ vars ];
				}
			}

			checkRelativePath( );

			_process.addEventListener( ProcessLoader.ERROR,		loadError,		false, 0, true );
			_process.addEventListener( ProcessLoader.COMPLETE,	configParse,	false, 0, true );

			if ( config.configPath ){
				log( "loading: ", config.configPath, LogEvent.VERBOSE );
				_process.startLazyLoader( printf( config.configPath, this.config ) );
			}
			else{
				if ( configXML ){
					configParse( null );
				}else{
					log( "any extra config to load. lets go through dependencies...", LogEvent.VERBOSE );
					_process.dispatchEvent( new Event(ProcessLoader.COMPLETE) );
				}
			}
		}
		/**
		 * @private
		 * 
		 * Pega todos os ERROR de loading. Tanto da config.xml
		 * quando das dependencias registradas nele.
		 * 
		 * @param	e	Event.
		 * @dispatchs ErrorEvent.ERRO when any load fail.
		 * 
		 * */
		private function loadError( e:* ) : void
		{
			_process.dependencies.pauseAll( );
			clearAllListeners( );
			dispatchEvent( new ProjectEvent(ProjectEvent.ON_ERROR) );
		}
		/****/
		private function clearAllListeners():void{
			_process.removeEventListener( ProcessLoader.ERROR, loadError )
			_process.removeEventListener( ProcessLoader.COMPLETE, configParse ) ;
			_process.removeEventListener( ProcessLoader.COMPLETE, dependenciesComplete ) ;
		}
		/**
		 * @private
		 * 
		 *	Does the xml parse and aplly all settings.
		 *	 
		 * */
		private function configParse( e:Event ) : void
		{
			log("starting application setup..." , LogEvent.VERBOSE );

			configXML  = configXML ? configXML : _process.dependencies.getContent("lazyLoader");

			clearAllListeners( );

			if (configXML && configXML.hasOwnProperty("config")){
				config.injectXML(configXML.config);
			}

			if (configXML &&
			 	configXML.hasOwnProperty("languages") && 
				configXML.languages.attribute("default") && 
				configXML.languages.attribute("default").toString().length>0
			){
				language().setLocale( configXML.languages.attribute("default") );
				config.locale = configXML.languages.attribute("default");
			}

			addRelativePathFromXML( );

			allowDomains( );

			dispatchEvent( new ProjectEvent(ProjectEvent.ON_CONFIG_LOADED) );
			
			_process.addEventListener( ProcessLoader.ERROR, loadError, false, 0, true )
			_process.addEventListener( ProcessLoader.COMPLETE, dependenciesComplete, false, 0, true ) ;
			_process.loadDependencies( );
		}
		/**
		*	updates the current locale at configXML
		**/
		private function updateLocale(e:Event):void{
			log( "currentLocale has changed", LogEvent.VERBOSE );
			config.locale = language( ).currentLocale;
		}
		/**
		 * @private
		 * 
		 * Verifica se ha no config.xml alguma regra para urls especificas, o projeto
		 * vai buscar a url do swf para fazer a comparacao com as possibilidades do xml.
		 * 
		 * @return String
		 * 
		 * */
		private function addRelativePathFromXML(  ) : void
		{
			if ( configXML && configXML.hasOwnProperty("relativePath") ){
				if (configXML.relativePath.item){
					for each( var item:XML in configXML.relativePath.item ){
						var a : String = item.attribute("affects");
						var p : String = item.attribute("path");
						var v : String = item.toString( );
						if (a && p && v){
							addRelativePath( a, p, v )
						}
					}
					checkRelativePath( );
				}
			}
		}
		/**
		*	
		*	registers a new relative path relation.
		*	
		*	@param affects	String	property into the <code>config()</code> to replace
		*	@param url		String	condicional url
		*	@param path		String	path to use
		*	
		*	@return Boolean
		*	
		*	@usage
		*	
		*	project.addRelativePath( "basePath", "www.google.com", "../../" );
		*	project.addRelativePath( "basePath", "www.apple.com", "../" );
		*	project.addRelativePath( "basePath", "standalone", "http://localhost/tmp/" );
		*	
		*	if(project.checkRelativePath()){
		*		trace( config("basePath") )
		*	}else{
		*		config()["basePath"] = "some/backup/url"
		*	}
		*	
		**/
		public function addRelativePath( affects:String, url:String, path:String ):Boolean{
			if ( !affects || !path || !url ){ return false; }
			_relativePaths.push(new RelativePath( affects,url,path ));
			return true;
		}
		/**
		*	
		*	runs thru all <code>relativePath</code> checking which matches with the <code>root.loaderInfo.url</code>
		*	@see <code>addRelativePath</code>
		*	
		**/
		public function checkRelativePath( ):Boolean{
			return relativePaths.some( function( item:RelativePath, ...rest ): Boolean{
				if ( (scope.root.loaderInfo.url == item.url) || (item.url=="standalone" && isStandAlone( )) ){
					config[ item.affects ] = item.path;
					return true;
				}
				return false;
			} );
		}
		/**
		 * @private
		 * 
		 *	Allow all registred domains
		 * 
		 */
		private function allowDomains( ):void
		{
			// allowing all related domains.
			if ( configXML && configXML.hasOwnProperty("domains") ){
				if (configXML.domains.hasOwnProperty("item")){
					for( var i:String in configXML.domains.item ) {
						var u:String = configXML.domains.item[ i ].toString( );
							u = printf( u, config );
						log( "domain: "+u, LogEvent.VERBOSE )
						Security.allowDomain( u );
						var isSecury:Boolean = toBoolean(valueFromXML( configXML.domains.item[i],"secure") );
						if( isSecury ){
							log("secure domain: " + u, LogEvent.VERBOSE )
							Security.allowInsecureDomain( u );
						}
					}
				}
			}
		}
		/**
		 * @public
		 * @dispatchs Event.COMPLETE when all main dependencies are loadeds.
		 * 
		 * */
		private function dependenciesComplete(e:*) : void
		{
			registerCopyDeck( );

			if (configXML){
				if (configXML.hasOwnProperty( "sessions" ) ){
					if ( configXML.sessions.attribute("src") && configXML.sessions.attribute("src").toString().length>0 ){
						log( "adding sessions from xml '"+ dependencies.get(configXML.sessions.attribute("src"))+"'.", LogEvent.VERBOSE);
						navigation.addSessionsFromXML( dependencies.getXML( configXML.sessions.attribute("src").toString( ) ) );
					}
					else{
						log( "adding sessions from <code>configXML.sessions</code>", LogEvent.VERBOSE );
						navigation.addSessionsFromXML( new XML(configXML.sessions) );
					}
				}
			}

			if (_contextMenu && !_menu ){
				contextMenu = true;
			}

			log( "dependencies loaded.", LogEvent.VERBOSE );
			dispatchEvent( new ProjectEvent(ProjectEvent.ON_DEPENDENCIES_LOADED) );
			clearAllListeners();
		}
		/**
		 * 
		 * Registra todas os copydecks listados em <language> 
		 * 
		 * @example
		 * 
		 * // config.xml
		 *	<languages default="eng-us">
		 *		<item file="us" locale="eng-us" />
		 *		<item file="br" locale="pt-br" contains="eng-us" />
		 *	</languages>
		 * 
		 * <dependencies>
		 *		<file id="br" url="copy-us.xml" />
		 *		<file id="us" url="copy-br.xml" />
		 * </dependencies>
		 * 
		 * 
		 * */
		private function registerCopyDeck( ) : void 
		{
			if (configXML &&
			 	configXML.hasOwnProperty( "languages" ) && 
				configXML.languages.hasOwnProperty("item"))
			{	
				var l : String;
				var f : String;
				var c : String;
				var n : *;

				for each( n in configXML.languages.item ){
					f = valueFromXML( n, "src" );
					l = valueFromXML( n, "locale" );
					c = valueFromXML( n, "contains");
					language( ).addDictionary( l, dependencies.getXML( f ), c );
				}
			}
		}
		/**
		*	Enables the right click context menu
		*	@param p_value Boolean;
		**/
		public function set contextMenu( p_value:Boolean ):void{
			_contextMenu = p_value;
			if ( configXML && _contextMenu ){
				if ( !_menu ){
					_menu = new ContextNavigation( this.scope );
					_menu.addEventListener( Event.OPEN, addItems )
					_menu.addEventListener( Event.CHANGE, checkContextMenu )
				}
			}else if( !p_value && _menu ){
				_menu.clear();
			}
		}
		/**
		*	@private
		*	Runtime contextMenu items
		**/
		private function addItems(e:Event):void{
			_menu.clear();
			_menu.add( ContextNavigation.COPY_LOG );
			navigation.listAllSessionsNames( ).forEach( function( p_item:String, ...rest ):void{
				var value : String = "# " + p_item + " : " + navigation.getSession( p_item ).status;
				value += (navigation.currentSession && navigation.currentSession.name == p_item ) ? " - current" : "";
				_menu.add( value );
			}, null )
		}
		/**
		*	@private
		*	manages context menu changes
		**/
		private function checkContextMenu(e:Event):void{
				if ( _menu && _menu.selected ){
				switch(_menu.selected.caption){

					case ContextNavigation.COPY_LOG:
						try{
							var h : String = logHistory.join("\n");
							System.setClipboard(h);
						}catch(err:Error){
							log("attempt to use clipboard event.", LogEvent.ERROR);
						}
						break;

					default:
						var s : String =  _menu.selected.caption.split(" :")[0].split("# ")[1];
						navigation.open( s );
						break;
				}
			}
		}
	}
}
internal class RelativePath
{

	public var url: 		String
	public var affects: 	String
	public var path: 		String

	public function RelativePath(p_affects:String,p_url:String,p_path:String)
	{
		affects = p_affects;
		url = p_url;
		path = p_path;
	}
	
	public function toString():String{
		return "[RelativePath] affects:" +affects+" url:"+url+" path:"+path;
	}

}