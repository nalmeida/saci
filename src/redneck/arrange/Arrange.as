/**
 * 
 *	Arrange your life!
 *
 * 	Arrange is just a simple way to change the position of your objects.
 *	The basic ideia to use the Arrange class is understand how it works.
 *	For all methods you have to pass a <code>arr</code> parameter. 
 *	This parameter define the list of objects to arrange. 
 *	Always the refered object is the first item in the <code>arr</code> ( arr[0]) and all others will 
 *  be use it like reference.
 * 
 *	@example
 * 	
 * 	var sp1 :Sprite = new Sprite()
 * 	var sp2 :Sprite = new Sprite()
 *  addChild( sp1 )
 *  addChild( sp2 )
 * 
 * 	Arrange.toRight( [ sp1, sp2 ] ) // will put sp2 by the right side of sp1 using the sp1.x + sp1.width like reference..
 * 
 *	You can use almost also a Stage instance like reference:
 * 	
 *  var sp1 :Sprite = new Sprite()
 *  stage.addChild(sp)
 * 
 * 	Arrange.center( [stage, sp] ) // will put the sp in the center of the stage. Be careful with object with read only properties.
 * 
 * 	You can also use a virtual point:
 * 
 *  var sp1 :Sprite = new Sprite()
 *  stage.addChild(sp)
 * 
 * 	Arrange.toTop( [ new Point(10,10), sp1 ] );
 * 
 *	And finally, you can just check the position or anything else before arrange your items, 
 * 	in this case you can use any kind of object since it have a x, y, width and height properties. 
 *  Is recomended pass a <code>DisplayVO</code>.
 * 
 *	@author igor almeida
 *	@version 1.1.0
 *	@since 11.04.2008
 *	
 * 	@todo review byDepth
 * 	@todo profile test
 * 
 */
package redneck.arrange
{
	import flash.display.DisplayObjectContainer;
	import flash.display.Stage;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	
	import redneck.grid.*;
	
	public class Arrange
	{
		/*@private*/
		private static var count : int = 0;
		/*@private*/
		private static var bounds : Rectangle;
		/*@private*/
		private static var tempRect : Rectangle;
		/***/
		public function Arrange( ) : void
		{
			throw new Error( "Arrange is a static class and may not be instanceated." )
		}
		/**
		 * 
		 *	Put the itens on left side of the next
		 * 
		 *	@param	arr			Array
		 *	@param	props		Object	
		 * 	@see ArrangeProperties.ALLOWED_PROPERTIES 
		 * 
		 **/
		public static function toLeft( arr:Array, prop : Object = null) : void
		{
			var p : ArrangeProperties = prop != null ? (prop is ArrangeProperties) ? prop as ArrangeProperties : ArrangeProperties.fromObject( prop ) : ArrangeProperties.defaultInstance;
			placeTo( arr, "x", -1, p.padding_x, p.width, p.step);			
		}
		/**
		 * 
		 *	Put the itens on right side of the next
		 * 
		 *	@param	arr			Array
		 *	@param	props		Object	
		 * 	@see ArrangeProperties.ALLOWED_PROPERTIES 
		 * 
		 **/
		public static function toRight( arr:Array, prop : Object = null) : void
		{
			var p : ArrangeProperties = prop != null ? (prop is ArrangeProperties) ? prop as ArrangeProperties : ArrangeProperties.fromObject( prop ) : ArrangeProperties.defaultInstance;
			placeTo( arr, "x", 1, p.padding_x, p.width, p.step);
		}
		/**
		 * 
		 *	Put the itens on above position of the next.
		 * 
		 *	@param	arr			Array
		 *	@param	props		Object	
		 * 	@see ArrangeProperties.ALLOWED_PROPERTIES 
		 * 
		 **/
		public static function toTop( arr:Array, prop : Object = null) : void
		{
			var p : ArrangeProperties = prop != null ? (prop is ArrangeProperties) ? prop as ArrangeProperties : ArrangeProperties.fromObject( prop ) : ArrangeProperties.defaultInstance;
			placeTo( arr, "y", -1, p.padding_y, p.height, p.step );
		}
		/**
		 * 
		 *	Put the itens on under position of the next.
		 * 
		 *	@param	arr			Array
		 *	@param	props		Object	
		 * 	@see ArrangeProperties.ALLOWED_PROPERTIES 
		 * 
		 **/
		public static function toBottom( arr:Array, prop:Object = null ) : void
		{
			var p : ArrangeProperties = prop != null ? (prop is ArrangeProperties) ? prop as ArrangeProperties : ArrangeProperties.fromObject( prop ) : ArrangeProperties.defaultInstance;
			placeTo( arr , "y", 1, p.padding_y, p.height, p.step );
		}
		/**
		 * @private
		 **/
		private static function placeTo( arr:Array, prop:String, operator:int = 1, padding:Number = 0, forceSize:Number = NaN, step:Number = 1 ) : void
		{
			if ( arr[ 0 ]==null && arr.length<=1 ){
				return;
			}
			var items:Array = clone( arr );
			if ( items.length<=1 ){
				return;
			}
			var size:String = (prop == "x") ? "width" : "height";
			var c:int = 0;
			var s:Number;
			var reffSize : Number;
			var reffPos : Number;
			var objSize : Number;
			var objPos : Number;
			while ( c < items.length )
			{
				if (c > 0 && items[ c ] != null && items[ c-1 ] != null)
				{
					reffSize = items[ c - 1 ][ size ];
					reffPos = items[ c - 1 ][ prop ];
					objSize = items[ c ][ size ];
					objPos = items[ c  ][ prop ];
					s = ( isNaN(forceSize) ) ? ( operator < 0 ) ? objSize : reffSize : forceSize;
					items[ c ][ prop ] = items[ c ][ prop ] + ( ( ( reffPos - objPos ) * operator + s + padding ) * step ) * operator;	
				}
				s = forceSize;
				c++;
			}
 			items = null;
		}
		/**
		 * 
		 *	Align all itens by the top position of the first item
		 * 
		 *	@param	arr			Array	items list 
		 *	@param	props		Object	
		 * 	@see ArrangeProperties.ALLOWED_PROPERTIES 
		 * 
		 **/
		public static function byTop( arr:Array , prop:Object = null ) : void
		{
			var p : ArrangeProperties = prop != null ? (prop is ArrangeProperties) ? prop as ArrangeProperties : ArrangeProperties.fromObject( prop ) : ArrangeProperties.defaultInstance;
			placeBy( arr, "y", 1, p.padding_y, 0, p.step);
		}
		/**
		 * 
		 *	Align all itens by the bottom position of the first item.
		 * 
		 *	@param	arr			Array	items list 
		 *	@param	props		Object	
		 * 	@see ArrangeProperties.ALLOWED_PROPERTIES 
		 * 
		 **/
		public static function byBottom( arr:Array , prop:Object = null ) : void
		{
			var p : ArrangeProperties = prop != null ? (prop is ArrangeProperties) ? prop as ArrangeProperties : ArrangeProperties.fromObject( prop ) : ArrangeProperties.defaultInstance;
			placeBy( arr, "y", -1, p.padding_y, p.height, p.step );
		}
		/**
		 * 
		 *	Align all itens by the left side of the first item.
		 * 
		 *	@param	arr			Array	items list 
		 *	@param	props		Object	
		 * 	@see ArrangeProperties.ALLOWED_PROPERTIES 
		 * 
		 **/
		public static function byLeft( arr:Array , prop:Object = null ) : void
		{
			var p : ArrangeProperties = prop != null ? (prop is ArrangeProperties) ? prop as ArrangeProperties : ArrangeProperties.fromObject( prop ) : ArrangeProperties.defaultInstance;
			placeBy( arr, "x", 1, p.padding_x, 0, p.step);
		}
		/**
		 * 
		 *	Align all itens by the right side of the first item.
		 * 
		 *	@param	arr			Array	items list 
		 *	@param	props		Object	
		 * 	@see ArrangeProperties.ALLOWED_PROPERTIES 
		 * 
		 **/
		public static function byRight( arr:Array , prop:Object = null ) : void
		{
			var p : ArrangeProperties = prop != null ? (prop is ArrangeProperties) ? prop as ArrangeProperties : ArrangeProperties.fromObject( prop ) : ArrangeProperties.defaultInstance;
			placeBy( arr, "x", -1, p.padding_x, p.width, p.step);
		}
		/**
		 * @private
		 **/
		private static function placeBy( arr:Array, prop:String, operator:int = 1, padding:Number = 0, forceSize:Number = NaN, step:Number = 1 ) : void
		{
			if ( arr[ 0 ]==null && arr.length<=1 ){
				return;
			}
			var items : Array = clone( arr );
			if ( items.length<=1 ){
				return;
			}
			var size:String = (prop == "x") ? "width" : "height";
			var c:int = 0;
			var s : Number;
			var reffSize : Number;
			var reffPos : Number;
			var objSize : Number;
			var objPos : Number;

			reffSize = items[ 0 ][ size ];
			reffPos = items[ 0 ][ prop ];
			while ( c<items.length)
			{
				if( c>0 && items[ c ] != null && items[0]!=null )
				{
					objSize = items[ c ][ size ];
					objPos = items[ c ][ prop ];
					s = ( isNaN(forceSize) ) ? reffSize : forceSize;
					items[ c ][ prop ] = items[ c ][ prop ] + ( ( ( ( reffPos - objPos + ( operator==1 ? 0 : s - objSize ) ) ) * operator ) * operator ) * step + ( padding * operator )
				}
				s = forceSize;
				c++;
			}
			items = null;
		}
		/**
		 * 
		 * Align all itens by the center of the first item.
		 * 
		 *	@param	arr			Array	items list 
		 *	@param	props		Object	
		 * 	@see ArrangeProperties.ALLOWED_PROPERTIES 
		 * 
		 **/
		public static function center( arr:Array, prop:Object = null ) : void
		{
			centerY( arr, prop );
			centerX( arr, prop );
		}
		/**
		 * 
		 * Align all itens by the center Y of the first item.
		 * 
		 *	@param	arr			Array	items list 
		 *	@param	props		Object	
		 * 	@see ArrangeProperties.ALLOWED_PROPERTIES 
		 * 
		 **/
		public static function centerY( arr:Array, prop:Object = null ) : void
		{
			var p : ArrangeProperties = prop != null ? (prop is ArrangeProperties) ? prop as ArrangeProperties : ArrangeProperties.fromObject( prop ) : ArrangeProperties.defaultInstance;
			placeCenter( arr, "y", p.padding_y, p.height, p.step);
		}
		/**
		 * 
		 * Align all itens by the center X of the first item.
		 * 
		 *	@param	arr			Array	items list 
		 *	@param	props		Object	
		 * 	@see ArrangeProperties.ALLOWED_PROPERTIES 
		 * 
		 **/
		public static function centerX( arr:Array, prop:Object = null ) : void
		{
			var p : ArrangeProperties = prop != null ? (prop is ArrangeProperties) ? prop as ArrangeProperties : ArrangeProperties.fromObject( prop ) : ArrangeProperties.defaultInstance;
			placeCenter( arr, "x", p.padding_x, p.width, p.step);
		}
		/**
		 * @private
		 **/
		private static function placeCenter( arr:Array, prop:String, padding:Number = 0, forceSize:Number = NaN, step:Number = 1 ) : void
		{
			if ( arr[ 0 ]==null && arr.length<=1 ){
				return;
			}
			var items : Array = clone(arr);
			if ( items.length<=1 ){
				return;
			}
			var size:String = (prop == "x") ? "width" : "height";
			var c:int = 0;
			var s : Number;
			var reffSize : Number;
			var reffPos : Number;
			var objSize : Number;
			var objPos : Number;
			var reff : Number

			reffSize = items[ 0 ][ size ];
			reffPos = items[ 0 ][ prop ];
			reff = ( isNaN(forceSize) ? reffSize : forceSize ) * .5;

			while ( c<items.length )
			{
				if( c>0 && items[ c ] != null )
				{
					objSize = items[ c ][ size ];
					objPos = items[ c ][ prop ];
					s = isNaN(forceSize) ? objSize : forceSize;
					items[ c ][ prop ] = items [ c ][ prop ] - ( ( objPos - reffPos ) + ( s * .5 - reff ) + padding ) * step;
				}
				c++;
			}
			items = null;
		}
		/**
		 * 
		 *	Create a new Grid and arrange the items.
		 *	If the number of item in <code>arr</code> is greater then
		 *	grid size ( columns * rows ), the extras elements will not be arranged. 
		 *	In this case use the <code> verticalGrid </code> or <code> horizontalGrid </code> to fluid grid.
		 * 
		 *  @see Grid
		 * 
		 *	@param	arr			Array	items to arrange
		 *	@param	columns		uint
		 *	@param	rows		uint
		 *	@param	prop		Object
		 * 	@see ArrangeProperties.ALLOWED_PROPERTIES 
		 * 
		 * 	@return Grid
		 * 
		 **/
		public static function grid( arr:Array, columns:uint, rows:uint, props: Object = null) : Grid
		{
			if ( arr[ 0 ]==null && arr.length<=1 ){
				return null;
			}
			var grid : Grid = new Grid ( columns, rows );
			var size : int = grid.size;
			var count :int = 0;
			while ( count< size )
			{
				grid.set( grid.iterator.pointer.c, grid.iterator.pointer.r, arr[ count ] );	
				count++;
				grid.iterator.next( );
			}
			grid.iterator.reset( );
			count = 0;
			size = grid.getColumn ( 0 ).length;
			var lazyProp : ArrangeProperties = ArrangeProperties.defaultInstance.clone();
			if ( props) {
				lazyProp.step = props["step"] || 1;
				lazyProp.width = props["width"] || NaN;
				lazyProp.height = props["height"] || NaN;
			}
			byLeft( grid.getColumn ( 0 ), lazyProp );
			toBottom ( grid.getColumn ( 0 ), props );
			var toArrange : Array;
			while ( count < size )
			{
				toArrange = grid.getRow ( count );
				byTop( toArrange , lazyProp );
				toRight( toArrange , props );
				count++;
			}
			toArrange = null;
			lazyProp = null;
			return grid;
		}
		/**
		 *	@private
		 * 	@return Array
		 **/
		private static function gridSize( arr:Array, n:int ) : int
		{
			var mod:int = arr.length/n;
				mod += int(arr.length % n) > 0 ? 1 : 0 ;
			return mod;
		}
		/**
		 * 
		 *	Create a vertical grid and arrange items. 
		 *  You just have to say the number of <code>columns</code> 
		 *  and the number of rows will be calculated using the size of <code>arr<code>
		 * 
		 *	@param	arr			Array	items to arrange
		 *	@param	columns		int		column number
		 *	@param	prop		Object
		 * 	@see ArrangeProperties.ALLOWED_PROPERTIES 
		 * 
		 * 	@return Grid
		 * 
		 **/
		public static function verticalGrid( arr:Array, columns:uint, prop:Object = null ) : Grid
		{
			return grid( arr, columns, gridSize( arr, columns ), prop);
		}
		/**
		 * 
		 *	Create a horizinotal grid and arrange items. 
		 *  You just have to say the number of <code>rows</code> 
		 *  and the number of columns will be calculated using the size of <code>arr<code>
		 * 
		 *	@param	rows		int		column number
		 *	@param	arr			Array	items to arrange
		 *	@param	prop		Object
		 * 	@see ArrangeProperties.ALLOWED_PROPERTIES 
		 * 
		 * 	@return Array
		 * 
		 **/
		public static function horizontalGrid( arr:Array, rows:uint, prop:Object = null ) : Grid
		{
			return grid( arr, gridSize( arr, rows ), rows, prop );
		}
		/**
		 * 
		 *	Change the depths in the same order of the array.
		 *  This action only works with DisplayObjectContainer
		 * 
		 *	@param	arr	Array 	items to order.
		 * 
		 **/
		public static function byDepth ( arr:Array ) : Boolean
		{
			var items : Array = clone( arr );
			if ( items.length<=1 ){
				return false;
			}
			var depths: Array = [];
			var count : int = 0;
			if ( !checkItems( items, DisplayObjectContainer ) )
			{
				trace("Arrange.byDepth : this method only works with DisplayObjectContainer already added like a child.");
				return false;
			}
			var scope : *  = items[0].parent;
			while( count < items.length )
			{
				depths.push( { item : items[ count ], z : scope.getChildIndex( items[ count ] ) } );
				count++;
			}
			var sorted:Array = depths.sortOn( "z" , Array.DESCENDING | Array.NUMERIC );
			count = 0;
			while( count<items.length )
			{
				scope.setChildIndex( items[ count ], sorted[ count ].z );
				count++;
			}
			return true;
		}
		/**
		 * 
		 *	Return the rectangle of all items
		 * 
		 *	To work fine, put in array objects at the same scope.
		 * 
		 *	@param arr	Array
		 *	@return Rectangle
		 * 
		 */
		public static function getRect( arr:Array ) : Rectangle
		{
			var a:Array = clone( arr );
			if (a && a.length>0){
				bounds = new Rectangle( a[ 0 ].x, a[ 0 ].y, a[ 0 ].width, a[ 0 ].height );
				a.shift();
				count = a.length;
				while(count--)
				{
					if ( a[ count ] == null ){
						continue;
					}
					bounds = bounds.union( new Rectangle( a[ count ].x, a[ count ].y, a[ count ].width, a[ count ].height ) );
				}
				return bounds;
			}
			return new Rectangle();
		}
		/**
		 * 
		 *	Return the total width of all items. 
		 *	To work fine, put on array objects in the same scope.
		 * 
		 *	@param	arr	Array
		 * 
		 *	@return Number
		 * 
		 */
		public static function width( arr:Array ) : Number
		{
			return getRect( arr ).width;
		}
		/**
		 * 
		 *	Return the total height of all items. 
		 *	To work fine, put on array objects in the same scope.
		 * 
		 *	@param	arr	Array
		 * 
		 *	@return Number
		 * 
		 **/
		public static function height( arr:Array ) : Number
		{
			return getRect( arr ).height;
		}
		/**
		 * 
		 * Rounds the 'x' and 'y' position.
		 * 
		 * @param	arr	Array	Items to round.
		 * 
		 **/
		public static function round( arr:Array ) : void
		{
			var a: Array = clone( arr );
			var count:int = a.length;
			while (count--)
			{
				if ( !a[ count ] ){
					continue;
				}
				a[ count ].x = int( a[ count ].x );
				a[ count ].y = int( a[ count ].y );
			}
		}
		/**
		 * 
		 * Check if the items are DisplayObjectContainer or not.
		 * 
		 * @param	arr	Array
		 * @return	Boolean
		 * 
		 * */
		private static function checkItems( arr:Array, type : Class ) : Boolean
		{
			var a : Array = clone( arr );
			var c : int = a.length
			while ( c-- )
			{
				if ( ! ( a[ c ] is type ) )
				{
					return false;
				}
			}
			return a.length > 0;
		}
		/**
		 * 
		 *	shallow clone
		 * 
		 *	@param	a	Array
		 *	@return Array
		 * 
		 **/
		private static function clone( a:Array ) : Array
		{
			var c:int = a.length;
			var array:Array = new Array();
			while( c-- )
			{
				if ( a[ c ]==null ){
					continue;
				}
				if (a[c] is Point || (a[ c ].hasOwnProperty("x") &&
					a[ c ].hasOwnProperty("y") &&
					a[ c ].hasOwnProperty("width") &&
					a[ c ].hasOwnProperty("height")) ) 
				{
					array.push( new DisplayWrapper(a[ c ]) );
				}
			}
			return array.reverse();
		}
	}
}