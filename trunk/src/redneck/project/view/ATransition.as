/**
 * 
 * @author igor almeida
 * @version 0.5
 * 
 */
package redneck.project.view
{
	import flash.events.*;
	import flash.utils.*;
	import redneck.util.Counter;
	import redneck.events.DisplayEvent;
	import redneck.util.createClass;
	import redneck.core.IDisposable;
	public class ATransition extends EventDispatcher implements IDisposable
	{
		public var _current : SessionView;
		public var _queued : SessionView;
		public var sequencer : Counter;
		public static const TRANSITION_DESTROYED : String = "onTransitionFinish";
		public function get current():SessionView{ return _current;}
		public function get queued():SessionView{ return _queued;}
		/**
		 * 
		 *	Create a transition between 2 views.
		 *	In this case, the transition will wait the SessionEvent.HIDE and the SessionEvent.SHOW finishes
		 *	to notify the application which everything is done.
		 *	
		 *	You can make your own transitions extending ATransition, just respect the <code>notifyComplete</code>
		 *	and the <code>dispose</code> because the <code>Navigation</code> will wait this callbacks to continue 
		 *	the site workflow.
		 * 
		 *	@param	p_current	ASession	current opened session
		 *	@param	p_queued	ASession	new session to show.
		 * 
		 * */
		public function create(p_current: SessionView, p_queued:SessionView):void
		{
			_current = p_current;
			_queued = p_queued;
		}
		/**
		*	Start the transition. When the both finishes the <p>notifyComplete</p> has to be called.
		**/
		public function start():void
		{
			sequencer = new Counter( );
			sequencer.add ( current, DisplayEvent.ON_HIDE );
			sequencer.add ( queued, DisplayEvent.ON_SHOW );
			sequencer.onComplete = notifyComplete;

			current.addEventListener( DisplayEvent.ON_HIDE, queued.show );
			current.hide();
		}
		/**
		*	notifyComplete means that the both sessions has finished and all intances has destroyed.
		**/
		public function notifyComplete( ):void
		{
			current.finishHiding( );
			queued.finishShowing( );
			dispatchEvent( new Event( Event.COMPLETE ) );
		}
		/**
		*	clear listeners and callbacks and warns the <code>Navigation</code> which is everything done!
		*	without this dispatch nothing happens on the main flux.
		**/
		public function dispose( ...rest ):void
		{
			if(sequencer){
				sequencer.clear();
				sequencer = null;
			}
			dispatchEvent( new Event(TRANSITION_DESTROYED) );
		}
		/**
		*	clone me!
		**/
		public function clone( ): ATransition{
			try{
				return createClass( getQualifiedClassName( this ) );
			}catch(e:Error){}
			return new ATransition();
		}
	}
}