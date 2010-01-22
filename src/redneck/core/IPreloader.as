package redneck.core
{
	import flash.events.Event;
	public interface IPreloader extends IDisplay
	{
		function set percent ( p:Number ) : void;
		function get percent (  ) : Number;
		function change ( e:Event ) :void ;
	}
}