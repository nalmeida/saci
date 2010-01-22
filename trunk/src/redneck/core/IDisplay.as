package redneck.core
{
	public interface IDisplay
	{
		function show( ...rest ) : void;
		function hide( ...rest ) : void;
		function finishShowing( ...rest ) : void;
		function finishHiding( ...rest ) : void;
	}
}