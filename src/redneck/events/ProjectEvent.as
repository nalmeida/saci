package redneck.events
{
	import redneck.events.BaseEvent;
	public class ProjectEvent extends BaseEvent
	{
		public static const ON_CONFIG_LOADED : String = "projectConfigLoaded";
		public static const ON_DEPENDENCIES_LOADED : String = "projectOnDependenciesLoaded";
		public static const ON_ERROR: String = "projectOnError";
		
		public function ProjectEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
		
		public override function toString():String
		{
			return "[ProjectEvent ( type: "+type+" ) ]";
		}
		
	}
}