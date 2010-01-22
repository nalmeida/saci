/**
 * 
 *  Agrupa varios displays para movelos sem precisar coloca-los dentro de um contaier
 * 
 *	@author igor almeida
 *	@version 0.2
 *	@since 06.01.2009
 * 
 */
package redneck.display
{
	import flash.display.SimpleButton;
	
	import redneck.arrange.Arrange;
	
	public class DisplayGroup
	{
		private var items : Array;
		private var length : int;
		private var count : int;
		private var _width : Number;
		private var _height : Number
		public function DisplayGroup( p_items: Array )
		{
			if ( !p_items || p_items.length==0){
				return
			}
			items = p_items;
			count = length;
			length = items.length;
			_width = Arrange.width( items );
			_height = Arrange.height( items );
		}
		
		public function set x ( value : Number ) : void
		{
			while ( count-- ){
				if (items[ count ]){
					items[ count ].x += value;
				}
			}
		}
		
		public function set y ( value : Number ) : void
		{	
			while ( count-- ){
				if(items[ count ]){
					items[ count ].y += value;
				}
			}
		}
		
		public function get y (  ) : Number
		{
			return 0;
		}
		
		public function get x (  ) : Number 
		{
			return 0;
		}
		
		public function get width ( ) : Number
		{
			return _width;
		}
		 
		public function get height ( ) : Number
		{
			return _height;
		} 
		
		public function destroy ( ) : void
		{
			items = null;
		}
	}
}