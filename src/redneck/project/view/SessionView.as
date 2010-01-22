/**
 *
 * @author igor almeida
 * @version 0.3
 * 
 * */
package redneck.project.view
{
	import br.com.stimuli.loading.BulkLoader;

	import redneck.core.BaseDisplay;
	import redneck.project.view.ISession;
	import redneck.project.control.Navigation;
	import redneck.project.Project;
	import redneck.sound.SoundController;
	public class SessionView extends BaseDisplay implements ISession
	{
		public function SessionView():void{ super(); }

		public function setup (  ) :void { }

		public function transitionComplete (  ) :void { }

		public function update( ):void{ }

		private var _navigation  : Navigation;
		public function get navigation ( ) : Navigation {return _navigation;}
		public function set navigation ( p_nav:Navigation ) : void {
			_navigation = p_nav;
		}

		private var _dependencies: BulkLoader
		public function get dependencies (  ) : BulkLoader {return _dependencies;}
		public function set dependencies ( p_loader : BulkLoader ) : void{
			_dependencies = p_loader;
		}

		private var _soundController: SoundController
		public function get soundController (  ) : SoundController {return _soundController;}
		public function set soundController ( p_soundController : SoundController ) : void{
			_soundController = p_soundController;
		}

		private var _project : Project;
		public function get project (  ) : Project{return _project;}
		public function set project ( p_project : Project ) : void{
			_project = p_project;
		}

		private var _sessionNode : XML;
		public function get sessionNode (  ) : XML{return _sessionNode;}
		public function set sessionNode ( p_node: XML ) : void{
			_sessionNode = p_node;
		}
	}
}