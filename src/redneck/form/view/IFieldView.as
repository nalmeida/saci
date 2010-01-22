package redneck.form.view {
	public interface IFieldView {
		function get index( ):int;
		function set index( value:int ):void;
		function set ignoreInitialValue (value:Boolean):void
		function get ignoreInitialValue ():Boolean
		function get label( ):String;
		function set label( value:String ):void;
		function get initialValue( ):*
		function set initialValue( value:* ):void
		function set value( value:* ):void;
		function get value( ):*;
		function markAsInvalid( p_errors:Array=null ):void;
		function markAsValid( ):void;
		function freeze():void;
		function unfreeze():void;
		function set regularColor( color:int ):void;
		function get regularColor( ) : int;
		function set errorColor( color:int ):void;
		function get errorColor( ) : int;
		/* 0 = horizontal and 1 is vertival */
		function set orientation( value:int ):void;
		function set fieldWidth(value:Number):void
		function get fieldWidth():Number
		function set fieldHeight(value:Number):void
		function get fieldHeight():Number
		function set padding(value:Number):void
		function get padding():Number;
		function destroy():void;
		function arrange():void;
	}
}