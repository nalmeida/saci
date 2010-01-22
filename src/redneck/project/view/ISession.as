package redneck.project.view
{
	import br.com.stimuli.loading.BulkLoader;
	import redneck.project.control.Navigation;
	import redneck.sound.SoundController;
	import redneck.project.Project;
	public interface ISession
	{
		/*called when the <code>SessionView</code> is alredy loaded and on the stage*/
		function setup( ) : void;

		/*called when some parameters from url has changed*/
		function update( ):void;

		/*called when the transition has completed*/
		function transitionComplete( ) : void ;

		function set navigation ( p_nav:Navigation ) : void;
		function get navigation ( ) : Navigation ;

		function set soundController ( p_soundController:SoundController ) : void;
		function get soundController ( ) : SoundController ;

		function set dependencies ( p_loader : BulkLoader ) : void;
		function get dependencies (  ) : BulkLoader

		function set project ( p_project : Project ) : void;
		function get project (  ) : Project;

		/*xml reference for the session when it is created from a xml file.*/
		function set sessionNode ( p_node: XML ) : void;
		function get sessionNode (  ) : XML;
	}
}