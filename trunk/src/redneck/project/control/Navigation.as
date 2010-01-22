/**
 * 
 * @author igor almeida
 * @version 1.4
 * 
 * @todo back( );
 * @todo next( );
 * 
 */
package redneck.project.control
{
	import br.com.stimuli.loading.BulkLoader;
	import br.com.stimuli.string.printf;
	
	import flash.display.*;
	import flash.events.*;
	import flash.utils.Dictionary;
	
	import redneck.project.*;
	import redneck.project.view.*;
	import redneck.project.log.*;
	import redneck.project.misc.*;
	import redneck.listener.*;
	import redneck.events.*;
	import redneck.util.*;

	public class Navigation extends EventDispatcher
	{
		public var allSessions: Dictionary;
		public var openedSessions: Dictionary;
		public var history: Array;
		public var useDeepLink: Boolean;
		public var currentSessionCreator: SessionCreator;
		public var currentSession: SessionView;
		public var scope: Sprite;
		public var project: Project;
		private var serializedXML: XML;
		private var queuedSessionCreator: SessionCreator;
		private var currentTransition: ATransition;
		private var queuedTransition: ATransition;
		private static const TRANSITION_DESTROYED : String = "onTransitionFinished";
		/**
		*	
		*	@param p_project	Project
		*	@param p_scope		Sprite
		*	
		**/
		public function Navigation( p_project : Project, p_scope:Sprite ):void
		{
			super(null)
			project = p_project;
			scope = p_scope;
			allSessions = new Dictionary( true );
			history = new Array( );
			useDeepLink = false;
		}
		/**
		 * 
		 *	Add a new <code>SessionCreator</code> to this <code>allSessions</code> list.
		 * 
		 *	@param	p_Process Process
		 *	
		 *	@return Boolean
		 * 
		 * */
		public function addSession( p_session : SessionCreator ) : SessionCreator
		{
			if ( !p_session || hasSession( p_session.name ) ) { return null; }
			p_session.config = project.config;
			allSessions[ p_session.name ] = p_session;
			return p_session;
		}
		/**
		 * 
		 *	Removes a specific <code>SessionCreator</code>
		 * 
		 *	@param p_session	String <code>SessionCreator</code> name
		 * 
		 *	@return Boolean
		 * 
		 * */
		public function removeSession( p_session : String ) : Boolean
		{
			if (!allSessions[p_session]){
				return false;
			}
			if (openedSessions[ p_session ]){
				close( p_session );
			}
			(allSessions[p_session] as SessionCreator).dispose( );
			allSessions[p_session] = null;
			delete allSessions[p_session];
			return true;
		}
		/**
		 *
		 *	Start loading <code>p_name</code>. 
		 *	To listen the loading progress use the returned <code>BulkLoader</code> instance
		 *	
		 *	@param 	p_name		String or Process or ASession
		 *	@see	BulkLoader
		 *
		 *	@return	BulkLoader
		 * 
		 */
		public function load( p_name: * ): BulkLoader
		{
			var p_session : SessionCreator;
			if ( p_name is String ){
				p_session = allSessions[ p_name ] as SessionCreator;
			}
			else if ( p_name is SessionCreator ){
				p_session = allSessions[ p_name.name ];
			}
			if ( !p_session ){
				log("invalid prop!" , p_name);
				return null;
			}
			log("load process: '" + p_session.name + "'");
			var event : NavigationEvent = new NavigationEvent(NavigationEvent.SESSION_LOAD_START)
			event.session = p_session.name;
			dispatchEvent(event);
			p_session.addEventListener( ProcessLoader.COMPLETE, onLoadProcess, false, 0, true );
			p_session.addEventListener( ProcessLoader.ERROR, loadError, false, 0, true );
			p_session.load( );
			return p_session.dependencies ;
		}
		/**
		*	@private
		 *	just log errors.
		 * */
		private function loadError( e:Event ) : void
		{
			if (e.currentTarget is SessionCreator){
				e.currentTarget.removeEventListener( ProcessLoader.COMPLETE, onLoadProcess );
				e.currentTarget.removeEventListener( ProcessLoader.ERROR, loadError );
			}
			log( "error loading: ",e,LogEvent.ERROR );
		}
		/**
		 *	@private
		 *	Adds the current loaded <code>SessionCreator</code> into display list.
		 */
		private function onLoadProcess( e:Event ):void
		{
			log( "'"+e.currentTarget.name+"' loaded!", LogEvent.VERBOSE );
			if ( e.currentTarget == queuedSessionCreator){
				e.currentTarget.removeEventListener( ProcessLoader.COMPLETE, onLoadProcess );
				e.currentTarget.removeEventListener( ProcessLoader.ERROR, loadError );
				addChild ( queuedSessionCreator );
				queuedSessionCreator = null;
			}else{
				log("ops! I think there is nothing to open! [" + [queuedSessionCreator, e.currentTarget] +"]" );
			}
			var event : NavigationEvent = new NavigationEvent(NavigationEvent.SESSION_LOAD_COMPLETE)
			event.session = e.currentTarget.name;
			dispatchEvent(event);
		}
		/**
		 * @private
		 * Finishes the <code>ATransition</code> and keep the last session into the <code>history</code>
		 * */
		private function createHistory( e:Event ):void
		{
			if (currentTransition!=e.currentTarget){
				log( "ops! somebody else call this method!", e.currentTarget, LogEvent.ERROR );
				return;
			}
			currentSessionCreator = getSession( currentTransition.queued.name );
			if( currentSessionCreator){
				if ( currentSessionCreator.allowHistory){
					history.push ( new HistorySession( currentSessionCreator.name, currentTransition ) );
				}
				if ( currentTransition.current ){
					removeChild( allSessions[currentTransition.current.name] );
				}else{
					log("something wrong happened!", [currentTransition,currentTransition.current,currentTransition.queued]);
				}
				if (currentSessionCreator.display){
					currentSessionCreator.display.transitionComplete( );
				}
			}
			else{
				log("no current? something wrong happened!", [currentTransition,currentTransition.current,currentTransition.queued]);
			}
		}
		/**
		 * 
		 * Start loading <code>p_name</code> and when it finishes adds <code>p_name</code> on the display list.
		 *	
		 *	@param	p_name
		 *	@param	p_transition	ATransition
		 *	
		 *	@see SessionView.
		 * 
		 *	@return Bulkloader.
		 * 
		 */
		public function open( p_name:*, p_transition:ATransition = null ) : BulkLoader
		{
			if ( queuedSessionCreator ){
				queuedSessionCreator.removeEventListener( ProcessLoader.COMPLETE, onLoadProcess );
				queuedSessionCreator.removeEventListener( ProcessLoader.ERROR, loadError );
				queuedSessionCreator.dependencies.removeAll();
				queuedSessionCreator = null;
			}
			if ( p_name is String ){
				queuedSessionCreator = allSessions[ p_name ];
			}
			else if( p_name is SessionCreator || p_name is SessionView ){
				queuedSessionCreator = allSessions[ p_name.name ];
			}
			if ( queuedSessionCreator!=null ){
				if ( queuedSessionCreator == currentSessionCreator ){
					log( "'"+queuedSessionCreator.name+"' this session is already opened!");
					queuedSessionCreator = null;
					return null;
				}
				if ( currentTransition && (currentTransition.queued.name == queuedSessionCreator.name ) ){
					log("wait babe, this process is currently being opened!");
					return null;
				}
				else{
					log("opening session: '" + p_name + "'");
					queuedSessionCreator.currentTransition = p_transition;
					return load( queuedSessionCreator );
				}
			}
			else{
				log("there is no session with name '"+p_name+"'");
			}
			return null;
		}
		/**
		 * 
		 *	Closes a specific session.
		 * 
		 *	@param	p_name			*				Sesion name, SessionView or SessionCreator
		 *	@param	p_transition	ATransition
		 *	
		 *	@return Boolean
		 * 
		 **/
		public function close( p_name:* , p_transition:ATransition = null ):Boolean
		{
			var toClose : SessionCreator;
			if ( p_name is String ){
				toClose = allSessions[ p_name ];
			}
			else if( p_name is SessionCreator || p_name is SessionView ){
				toClose = allSessions[ p_name.name ];
			}
			if ( toClose==null ){
				log("impossible to close '"+p_name+"'! it's not opened!" );
				return false;
			}
			if (currentTransition){
				if ( currentTransition.current.name == toClose.name ){
					log("wait babe, this process is currently being closed!");
					return false;
				}
			}
			toClose.currentTransition = p_transition;
			createTransition( toClose, null, toClose.currentTransition.clone( ), removeChild );
			if ( currentTransition ){
				log( "waiting another transition '"+currentTransition+"' finish." );
				currentTransition.notifyComplete( );
				return false;
			}
			else{
				log( "close session: ", toClose.name );
				startTransition( null );
			}
			return true;
		}
		/**
		 *	@private
		 *	Adds the current view into the DisplayList.
		 *	@param	p_session	SessionCreator
		 */
		private function addChild( p_session:SessionCreator ) : void
		{
			if ( p_session && p_session.display && scope && scope.contains( p_session.display )){
				log("there is something strange here! this display is already added!", p_session.display, LogEvent.ERROR);
				return;
			}

			if (p_session.sessionNode && p_session.sessionNode.hasOwnProperty("config")){
				project.config.injectXML( p_session.sessionNode.config );
			}

			currentSession = scope.addChild( p_session.display ) as SessionView;
			currentSession.project = this.project;
			currentSession.navigation = this;
			currentSession.setup( );

			log("'"+ p_session.name + "' added in display list!", LogEvent.VERBOSE);

			var event : NavigationEvent = new NavigationEvent(NavigationEvent.CHANGED_CURRENT_SESSION);
			event.session = currentSession.name;
			dispatchEvent(event);

			createTransition( currentSessionCreator, p_session, p_session.currentTransition.clone( ), createHistory );
			if ( currentTransition ){
				log("waiting the other transition '"+currentTransition+"' finish.");
				currentTransition.notifyComplete( );
			}
			else{	
				startTransition( null );
			}
		}
		/**
		*	@private
		*	Creates a new transition
		*	@param	p_current
		*	@param	p_queue
		*	@param	p_trans
		* */
		private function createTransition( p_current:SessionCreator, p_queue:SessionCreator, p_trans : ATransition, p_callback:Function ):void{
			var toCLose : SessionView = p_current? p_current.display ? p_current.display : new SessionView() : new SessionView();
			var toOpen : SessionView = p_queue? p_queue.display ? p_queue.display : new SessionView() : new SessionView();
			queuedTransition = p_trans;
			queuedTransition.create( toCLose, toOpen );
			queuedTransition.addEventListener( Event.COMPLETE, p_callback, false, 0, true );
			queuedTransition.addEventListener( ATransition.TRANSITION_DESTROYED, startTransition, false, 0, true );
			log("created transition: ", queuedTransition );
		}
		/**
		*	@private
		*	starts the queued transition
		**/
		private function startTransition( e:Event ) : void {
			if ( currentTransition ){
				currentTransition.removeEventListener( Event.COMPLETE, createHistory );
				currentTransition.removeEventListener( Event.COMPLETE, removeChild );
				currentTransition.removeEventListener( ATransition.TRANSITION_DESTROYED, startTransition );
				currentTransition = null;
			}
			if ( queuedTransition ) {
				if ( currentSessionCreator && (queuedTransition.current != currentSessionCreator.display) ){
					log("recreate transition!");
					queuedTransition.create( currentSessionCreator.display, queuedTransition.queued );
				}
				currentTransition = queuedTransition;
				queuedTransition = null;
				log( "start '"+currentTransition+"'");
				currentTransition.start( );	
			}else{
				log("transition finished!")
			}
		}
		/**
		*	@private
		*	removes a sepecific session
		* */
		private function removeChild( e:* = null ):void{
			//checking dynamic params
			var p_current : SessionCreator;
			if ( e is Event ){
				if ( currentTransition ){
					if ( currentTransition.current ){
						p_current = allSessions[(currentTransition.current).name];
					}
				}
			}
			else if ( e is SessionCreator ){
				p_current = e;
			}
			// check before remove
			if (p_current && p_current.display){
				if( scope.contains( p_current.display ) ){
					scope.removeChild( p_current.display );
					log("sesion '"+currentSessionCreator.name+"' has been removed from the display list!");
					p_current.dispose( );
				}
			}
			// when the session has just closed!
			if ( currentSessionCreator == p_current ){
				currentSessionCreator = null;
			}
			if ( currentTransition ){
				currentTransition.dispose( );
			}
		}
		/**
		 * 
		 *	Adiciona varias sessions serializadas em um mesmo xml.
		 *	Esse método retorna um array com os names de todas as sessions
		 *	que foram adicionadas.
		 * 
		 *	@param p_xml	XML
		 *	
		 *	@return Array	
		 * 
		 * */
		public function addSessionsFromXML( p_xml : XML ) : Array
		{
			serializedXML = p_xml;
			useDeepLink =  valueFromXML( serializedXML, "useDeepLink" ) ? toBoolean( valueFromXML(serializedXML, "useDeepLink" ) ) : useDeepLink; 
			for (var p_index: String in serializedXML.session )
			{
				var p_name: String = valueFromXML(serializedXML.session[ p_index ] , "name");
				var p_view : String = valueFromXML(serializedXML.session[ p_index ] , "view"); 
				if (p_name.length + p_view.length <= 1){
					log("skip node. required (name and view) information missing. node:'" + serializedXML[ p_index ] + "'");
					continue;
				}
				if ( hasSession(p_name) ){
					log("there is another process with name:'" + p_name + "'");
					continue;
				}
				
				var p_session : SessionCreator = new SessionCreator( p_name, p_view );
					p_session.sessionNode = new XML( serializedXML.session[ p_index ] );
					p_session.title = valueFromXML( serializedXML.session[ p_index ], "title");
					p_session.keepFiles = toBoolean( valueFromXML( serializedXML.session[ p_index ] , "keepFiles") )
					p_session.deeplink = valueFromXML( serializedXML.session[ p_index ],"deepLink" );
					p_session.allowHistory = valueFromXML(serializedXML.session[ p_index], "allowHistory" ) ? toBoolean(valueFromXML(serializedXML.session[ p_index], "allowHistory" ) ) : true;

					if( valueFromXML( serializedXML.session[ p_index ],"transition" ) ){
						try{
							p_session.transition = createClass( valueFromXML( serializedXML.session[ p_index ],"transition" ) ) as ATransition;
						} 
						catch (e:Error){
							log("impossible to create transition with:'"+valueFromXML(serializedXML.session[ p_index ],"transition")+"'.", LogEvent.ERROR);
						}
					}

				addSession ( p_session );
			}
			return listAllSessionsNames( );
		}
		/**
		* 
		*	Return whether <code>p_name</code> is a valid <code>SessionCreator</code> name
		*	
		*	@param	p_name
		*	
		*	@return Boolean
		*	
		**/
		public function hasSession( p_name:String ) : Boolean{
			return ( allSessions[ p_name ] );
		}
		/**
		* 
		*	Return a list with all existents <code>SessionCreator</code>
		* 
		*	@return Array
		* 
		**/
		public function listAllSessionsNames():Array
		{
			var result : Array = [];
			for (var name:String in allSessions){
				result.push(name);
			}
			return result;
		}
		/**
		*	
		*	Return a <code>Process</code>  by id <code>pd_id</code>
		*	
		*	@param	p_id	String;
		*	
		*	@return Process 
		*	
		**/
		public function getSession(p_id:String): SessionCreator {
			return allSessions[p_id]; 
		}
		/**
		*	
		*	Return a <code>ASession</code>  by id <code>pd_id</code>
		*	
		*	@param	p_id	String;
		*	
		*	@return ASession 
		*	
		**/
		public function getSessionView( p_name:String):SessionView{
			return getSession( p_name ) ? getSession( p_name ).display : null;
		}
	}
}