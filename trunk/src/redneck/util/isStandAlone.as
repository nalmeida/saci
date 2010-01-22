package redneck.util
{
	import flash.system.Capabilities;
	
	public function isStandAlone() : Boolean
	{
		return ( Capabilities.playerType=="External" || Capabilities.playerType=="StandAlone" );
	}
}