/**
 * Grid is a bi-dimensional Array to stores any kind of data.
 * The positions are defined by notation Column x Row
 *  
 * @author igor almeida
 * @version 0.4
 * 
 * */
package redneck.grid
{
	public class Grid
	{
		private var matrix : Array
		private var _iterator : GridIterator
		private var _shape : GridShapes
		public var _height: int;
		public var _width : int;
		/**
		 * 
		 * Create a new Grid instance.
		 * 
		 * @param	p_columns	int
		 * @param	p_lines		in 
		 * 
		 * */
		public function Grid( p_columns:uint = 1, p_lines:uint = 1 ) : void
		{
			_width = Math.max( p_columns,1 );
			_height = Math.max( p_lines, 1 );
			clean();
		}
		/**
		 * 
		 * Return a instance of <code>GridIterator</code> 
		 * with this grid as data provider.
		 * 
		 * @return GridIterator
		 * 
		 * */
		public function get iterator () : GridIterator
		{
			return _iterator
		}
		/**
		 * 
		 * Return a instance of <code>GridShapes</code> 
		 * with this grid as data provider.
		 * 
		 * @return GridShapes
		 * 
		 * */
		public function get shapes () : GridShapes
		{
			return _shape
		}
		/**
		 * 
		 * Set a value for a specific cell.
		 * If the p_c or p_l is invalid, return false.
		 * 
		 * @param p_c	int	column
		 * @param p_r	int line
		 * @param value	*	value to insert
		 * @return Boolean
		 * 
		 * */
		public function set(p_c:int, p_r:int, value : *) : Boolean
		{
			if ( !hasCell( new Pointer( p_c, p_r ) ) ) return false;
			matrix[ p_c ][ p_r ] = value;
			return true;	
		}
		/**
		 * 
		 * Get the value for a specific cell
		 * 
		 * @param p_c	int
		 * @param p_r	int
		 * @return *
		 * 
		 * */
		public function get( p_c:int, p_r:int ) : *
		{
			if ( hasCell( new Pointer(p_c, p_r) ) ) return matrix[ p_c ][ p_r ];
			return null
		}
		/**
		 * 
		 * Fill all cells with <code>value</code>
		 * 
		 * @param	value	*
		 * 
		 * */
		public function fill( value:* = null) : void
		{
			var startPointer : Pointer = iterator.pointer;
			iterator.reset();
			var counter : int = 0
			var max: int = size;
			while ( counter<max)
			{
				set( iterator.pointer.c, iterator.pointer.r, value || ("'"+iterator.pointer.c+","+iterator.pointer.r+"'") );
				iterator.next();
				counter++;
			}
			iterator.pointer = startPointer;
		}
		/**
		 * 
		 * Clean all grid cells.
		 * 
		 */
		public function clean():void
		{
			matrix = new Array( );
			for (var c:int=0 ; c < width; c++)
			{
				matrix[ c ] = new Array( height );
			}
			_iterator = new GridIterator ( this );
			_shape = new GridShapes( this );
		}
		/**
		 * 
		 * Return specific row
		 * 
		 * @param	p_line	int
		 * @return Array
		 * 
		 * */
		public function getRow( p_line:int ) : Array
		{
			if ( p_line >= height)
			{
				return null;
			}
			var arr : Array = new Array();
			for (var line:int = 0; line < width; line++)
			{
				arr.push( matrix[ line ][ p_line ] );
			}
			return arr;
		}
		/**
		 * 
		 * Return specific colmun.
		 * 
		 * @param	p_line	int
		 * @return Array
		 * 
		 * */
		public function getColumn( p_column:uint ) : Array
		{
			if ( p_column >= width ){
				return null
			}
			return matrix[ p_column ];
		}
		/**
		 * 
		 * Return with <code>pt<code> is a valid pointer.
		 * 
		 * @return Bollean
		 * 
		 * */
		public function hasCell(pt:Pointer):Boolean
		{
			return (pt.c<width && pt.r<height && pt.r>=0 && pt.c>=0);	
		}
		/**
		 * 
		 * Runs through <code>arr</code> and get the
		 * content stored on the grid by arr[<c,r>] position.
		 * 
		 * @param	arr	Array Array with <code>Pointer</code>.
		 * @return Array
		 * 
		 * */
		public function parsePointers( arr:Array ) : Array
		{
			var result :Array = new Array();
			var count:int = 0;
			var total : int = arr.length;
			var pt : Pointer;
			while(count<total)
			{
				pt = arr[count] as Pointer;
				if ( pt && hasCell( pt ) )
				{ 
					result.push( get ( pt.c, pt.r ) ); 
					count++;
				}
			}
			return result;
		}
		/**
		 * 
		 * @return int
		 * 
		 * */
		public function get width ( ) : int
		{
			return  _width;
		}
		/**
		 * 
		 * @return int
		 * 
		 * */
		public function get height ( ) : int
		{
			return  _height;
		}
		/**
		 * 
		 * @return int
		 * 
		 * */
		public function get columns ( ) : int
		{
			return  width;
		}
		/**
		 * 
		 * @return int
		 * 
		 * */
		public function get rows( ) : int
		{
			return  height;
		}
		/**
		 * 
		 * @return int
		 * 
		 * */
		public function get size () : int
		{
			return width*height
		}
		/**
		 * 
		 * trace matrix
		 * 
		 * */
		public function debug() : void
		{
			trace("Grid ( "+_width+" , "+_height+" ) :");
			for (var row : int = 0; row<_height; row++)
			{
				var value : Array = new Array();
				for (var col : int = 0; col<_width; col++)
				{
					value.push( get(col, row) );
				}
				trace(value)
			}
		}
	}
}