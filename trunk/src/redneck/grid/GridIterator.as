/**
 * 
 * @author igor almeida.
 * @version 1.1
 * */
package redneck.grid
{
	public class GridIterator
	{
		private var grid : Grid
		private var width : int 
		private var height : int 
		public var pointer : Pointer
		
		public function GridIterator( arr : Grid )
		{
			grid = arr;
			width = grid.width-1;
			height = grid.height-1;
			pointer = new Pointer( 0 , 0 );
		}
		/**
		 *
		 * //
		 *  
		 * @param	loop	Boolean
		 * @return *
		 * 
		 * */
		public function next( loop:Boolean = false) : *
		{
			if( hasNext() && !loop )
			{
				if ( pointer.c == width )
				{
					pointer.c = 0
					pointer.r++;
				}
				else
				{
					pointer.c++;
				}
			}
			else if ( loop )
			{
				pointer.c = pointer.c==width ? 0 : pointer.c+1;
			}
			return grid.get( pointer.c , pointer.r );
		}
		/**
		 *
		 * //
		 *  
		 * @param	loop	Boolean
		 * @return *
		 * 
		 * */
		public function prev( loop:Boolean = false ):*
		{
			if( hasPrev() && !loop )
			{
				if ( pointer.c <= 0 )
				{
					pointer.c = width;
					pointer.r--;
				}
				else
				{
					pointer.c--;
				}
			}
			else if ( loop )
			{
				pointer.c = pointer.c==0 ? width : pointer.c-1;
			}
			return grid.get( pointer.c , pointer.r );
		}
		/**
		 *
		 * //
		 *  
		 * @param	loop	Boolean
		 * @return *
		 * 
		 * */
		public function up( loop:Boolean = false ):*
		{
			if( hasUp() && !loop )
			{
				if ( pointer.r <= 0 )
				{
					pointer.r = height;
					pointer.c--;
				}
				else
				{
					pointer.r--;
				}
			}
			else if ( loop )
			{
				pointer.r = pointer.r==0 ? height : pointer.r-1;
			}
			return grid.get( pointer.c , pointer.r );
		}
		/**
		 *
		 * //
		 *  
		 * @param	loop	Boolean
		 * @return *
		 * 
		 * */
		public function down( loop:Boolean = false ):*
		{
			if( hasDown() && !loop )
			{
				if ( pointer.r >= height )
				{
					pointer.r = 0;
					pointer.c++;
				}
				else
				{
					pointer.r++;
				}
			}
			else if ( loop )
			{
				pointer.r = pointer.r==0 ? height : pointer.r-1;
			}
			return grid.get( pointer.c , pointer.r );
		}
		/**
		 * 
		 * @param	p_pointer	Pointer
		 * @return Boolean
		 * 
		 * */
		public function hasNext( p_pointer: Pointer = null ) : Boolean
		{
			var pt : Pointer = p_pointer || pointer;
			return !( pt.c == width && pt.r == height )
		}
		/**
		 * 
		 * @param	p_pointer	Pointer
		 * @return Boolean
		 * 
		 * */
		public function hasPrev( p_pointer: Pointer = null ):Boolean
		{
			var pt : Pointer = p_pointer || pointer;
			return ( pt.r + pt.c !== 0 );
		}
		/**
		 * 
		 * @param	p_pointer	Pointer
		 * @return Boolean
		 * 
		 * */
		public function hasUp( p_pointer: Pointer = null ) : Boolean
		{
			var pt : Pointer = p_pointer || pointer;
			return hasPrev( pt );
		}
		/**
		 * 
		 * @param	p_pointer	Pointer
		 * @return Boolean
		 * 
		 * */
		public function hasDown( p_pointer: Pointer = null ) : Boolean
		{
			var pt : Pointer = p_pointer || pointer;
			return hasNext( pt );
		}
		/**
		 * 
		 * Check if the p_pointer is the end of line
		 * 
		 * @param	p_pointer	Pointer
		 * @return	Boolean
		 * 
		 * */
		public function isEOL( p_pointer: Pointer = null ) : Boolean
		{
			var pt : Pointer = p_pointer || pointer;
			return (pt.c == width && pt.r == height);
		}
		/**
		 * 
		 * reset the pointer to 0,0 position
		 * 
		 * @return Pointer
		 * 
		 * */
		public function reset() : Pointer
		{
			pointer.c = 0;
			pointer.r = 0;
			return pointer
		}
		/**
		*	returns the relative index of a point
		*	@return int
		**/
		public function getIndex( p_pointer : Pointer = null ):int{
			var pt : Pointer = p_pointer || pointer;
			return pt.c + grid.width*pt.r;
		}
		/**
		 * 
		 * Return the data to current pointer.
		 * 
		 * @return *
		 * 
		 * */
		public function get data () : *
		{
			return grid.get( pointer.c, pointer.r )
		}
	}
}