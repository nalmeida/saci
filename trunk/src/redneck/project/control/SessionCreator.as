/**
 * @author igor almeida
 * @versio 1.0
 * */
package redneck.project.control
{
	import br.com.stimuli.loading.*;
	import br.com.stimuli.string.*;
	
	import flash.events.*;
	import flash.geom.*;
	import flash.net.*;
	import flash.utils.*;
	
	import redneck.project.*;
	import redneck.project.view.*;
	import redneck.project.log.*;
	import redneck.project.misc.*;
	import redneck.events.*;
	import redneck.util.*;
	import redneck.listener.*;
	public class SessionCreator extends ProcessLoader
	{
		public var sessionNode:XML;
		
		private var _viewClass : String;
		private var _display : SessionView;
		private var _transition : ATransition;
		private var _currentTransition : ATransition;
		private var _status : String;

		internal const STATUS_LOADED : String = "loaded";
		internal const STATUS_LOADING : String = "loading";
		internal const STATUS_ERROR : String = "error";
		internal const STATUS_IDLE : String = "idle";
		internal var title : String;
		internal var allowHistory : Boolean = true;
		internal var deeplink : String;
		internal var keepFiles : Boolean;
		
		public function SessionCreator( p_name:String, p_viewClass:String ):void
		{
			super( p_name );
			_viewClass = p_viewClass;
			_status = STATUS_IDLE;
		}
		
		public function get status():String
		{
			return _status;
		}

		public function set transition( p_transition:ATransition ):void{_transition = p_transition;}
		public function get transition():ATransition{return _transition || new ATransition( );}
		
		public function set currentTransition( p_transition:ATransition ):void{_currentTransition = p_transition;}
		public function get currentTransition():ATransition{ return _currentTransition || transition;}

		public function get display () : SessionView {return _display;}

		public function load( ) : void
		{
			if ( (sessionNode && valueFromXML( sessionNode, "dependencies")) || dependencies.items.length>0 ){
				_status = STATUS_LOADING;
				super.addEventListener( ProcessLoader.COMPLETE, createView, false, int.MAX_VALUE, true );
				super.loadDependencies( sessionNode );
			}else{
				createView( null );
			}
		}

		private function createView( e:Event ) : void
		{
			e ? e.stopImmediatePropagation() : null;
			super.removeEventListener( ProcessLoader.COMPLETE, createView );

			if( display ){
				log("ops! why create this view again?", LogEvent.VERBOSE);
				dispatchEvent( new Event( ProcessLoader.COMPLETE ) );
				return;
			}
			try{
				_display = createClass( _viewClass ) as SessionView;
				_display.name = this.name;
				_display.dependencies = this.dependencies;
				_display.soundController = this.soundController;
				_display.sessionNode = this.sessionNode;

				log("session view created:'"+display+"'");

				dispatchEvent( new Event( ProcessLoader.COMPLETE ) );
				_status = STATUS_LOADED;
			}
			catch ( err:Error ){
				log("impossible to create the view class '" + _viewClass + "' Check if this class is already compiled or the class path/name is right.", err.getStackTrace(), LogEvent.ERROR);
			}
		}
		
		public override function dispose( ...rest ):void
		{
			removeEventListener( BulkLoader.COMPLETE, createView );
			if (!keepFiles){
				super.dispose();
			}
			if ( display ){
				display.dispose( );
			}
			_display = null;
			try {
			   new LocalConnection().connect('foo');
			   new LocalConnection().connect('foo');
			} catch (e:*) {}
		}

		public override function toString():String{
			return "[Process::"+name+"]";
		}
	}
}