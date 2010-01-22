/**
 * 
 * @author igor almeida
 * @version 0.3
 * 
 * */
package redneck.grid
{
	import redneck.util.array.*
	
	public class GridShapes
	{
		private var grid : Grid
		private var pointer : Pointer
		private var fakePoint : Pointer;
		private var defaultPosition : Pointer;
		/**
		 * 
		 * @param p_grid	Grid  to use like data provider.
		 * 
		 * */
		public function GridShapes( p_grid: Grid )
		{
			grid = p_grid;
		}
		/**
		 * 
		 * Return the Array with "cross items" or the pointer <code>pt</code>
		 * 
		 * @param	pt 			Pointer Pointer to analyze
		 * @param	usePoints	Boolean Define if the result Array will be filled with Pointer or Grid values in the clockwise way
		 * @return Array
		 * 
		 * @example
		 * considering the Grid(3,3) filled with Pointers :
		 *		[0,0] [1,0] [2,0]
		 * 		[0,1] [1,1] [2,1]
		 * 		[0,2] [1,2] [2,2] 
		 * 
		 * and the interator Pointer on e o Pointer <1,1> the result Array would be this:
		 * grid = new Grid(3,3);
		 * var arr: Array = grid.shapes.cross(new Pointer(1,1));
		 * // [ [1,1], [1,0], [2,1], [1,2], [0,1] ]
		 * 
		 **/
		public function cross( pt:Pointer = null, usePoints:Boolean = false ):Array
		{
			pt = pt==null ? grid.iterator.pointer : pt
			
			if ( !grid.hasCell( pt ) ) 
				return null
			
			defaultPosition = new Pointer( grid.iterator.pointer.c,grid.iterator.pointer.r );
			pointer = pt;
			var result:Array = new Array();
			
			// add target
			fakePoint = new Pointer( pointer.c, pointer.r )
			result.push( fakePoint );

			// add up
			fakePoint = new Pointer( pointer.c, pointer.r-1 )
			if ( grid.hasCell( fakePoint ) )
				result.push( fakePoint );

			// add right
			fakePoint = new Pointer( pointer.c+1, pointer.r ) 
			if ( grid.hasCell( fakePoint ) )
				result.push( fakePoint );
			
			// add bottom
			fakePoint = new Pointer( pointer.c, pointer.r+1 ) 
			if ( grid.hasCell( fakePoint ) )
				result.push( fakePoint );

			// add left
			fakePoint = new Pointer( pointer.c-1, pointer.r )
			if ( grid.hasCell( fakePoint ) )
				result.push( fakePoint );

			// reset iterator pointer
			grid.iterator.pointer = defaultPosition;
			
			return usePoints ? result : grid.parsePointers( result )
		}
		/**
		 * 
		 * Return the neighbours cell for a specific <code>Pointer</code>
		 * 
		 * @param	pt 			Pointer If null the pointer user will be the current iterator pointer.
		 * @param	usePoints	Boolean Define if the result Array will be filled with Pointer or Grid values in the clockwise way
		 * @return Array
		 * @example
		 * considering the Grid(3,3) filled with Pointers :
		 *		[0,0] [1,0] [2,0]
		 * 		[0,1] [1,1] [2,1]
		 * 		[0,2] [1,2] [2,2] 
		 * 
		 * and the interator Pointer on e o Pointer <1,1> the result Array would be this:
		 * grid = new Grid(3,3);
		 * var arr: Array = grid.shapes.square( new Pointer(1,1) );
		 * // [ [1,1], [1,0], [2,0], [2,1], [2,2], [1,2], [0,2], [0,1], [0,0, ]
		 * */		
		public function square( pt: Pointer = null, usePoints:Boolean = false ) : Array
		{
			pt = (pt == null) ? grid.iterator.pointer : pt
			
			if ( !grid.hasCell( pt ) ) 
				return null
			
			defaultPosition = new Pointer( grid.iterator.pointer.c,grid.iterator.pointer.r );
			pointer = pt
			var result:Array = new Array()
			
			// add target
			fakePoint = new Pointer( pointer.c, pointer.r )
			result.push( fakePoint );
			
			// add up
			fakePoint = new Pointer( pointer.c, pointer.r-1 )
			if ( grid.hasCell( fakePoint ) )
				result.push( fakePoint );
			
			// add up-right
			fakePoint = new Pointer( pointer.c+1, pointer.r-1 )
			if ( grid.hasCell( fakePoint ) )
				result.push( fakePoint );

			// add right
			fakePoint = new Pointer( pointer.c+1, pointer.r ) 
			if ( grid.hasCell( fakePoint ) )
				result.push( fakePoint );
				
			// add right-bottom
			fakePoint = new Pointer( pointer.c+1, pointer.r+1 )
			if ( grid.hasCell( fakePoint ) )
				result.push( fakePoint );
			
			// add bottom
			fakePoint = new Pointer( pointer.c, pointer.r+1 ) 
			if ( grid.hasCell( fakePoint ) )
				result.push( fakePoint );
				
			// add bottom-left
			fakePoint = new Pointer( pointer.c-1, pointer.r+1 )
			if ( grid.hasCell( fakePoint ) )
				result.push( fakePoint );

			// add left
			fakePoint = new Pointer( pointer.c-1, pointer.r )
			if ( grid.hasCell( fakePoint ) )
				result.push( fakePoint );

			// add left-up
			fakePoint = new Pointer( pointer.c-1, pointer.r-1 ) 
			if ( grid.hasCell( fakePoint ) )
				result.push( fakePoint );
				
			// reset iterator pointer
			grid.iterator.pointer = defaultPosition;

			return usePoints ? result : grid.parsePointers(result)
		}
		/**
		 * 
		 * @param	pt			Pointer
		 * @param	level		int
		 * @param 	usePoints	Boolean
		 * @return	Array	
		 * 
		 * */
		public function spiral( pt:Pointer = null , level:int = 1, usePoints:Boolean = false ) : Array
		{
			pt = pt==null ? grid.iterator.pointer : pt;
			
			if ( !grid.hasCell( pt ) ) 
				return null
			
			var firstRing : Array = square( pt, true );
			var result : Array = [ [ firstRing[ 0 ] ] ];
			result.push( firstRing ); 

			defaultPosition = new Pointer( grid.iterator.pointer.c, grid.iterator.pointer.r );
			pointer = pt;

			// creating rings by level
			build_rings : for (var l:int=1 ; l<level; l++ )
			{
				result.push( getDifference( result[ l ] , getRing( result[ l ] ) , Pointer.isDifferent ) );
			}
			
			// clean duplicated items
			filter_result : for (var pos : int = result.length-1; pos>0; pos-- )
			{
				result[ pos ] = getDifference( result[ pos-1 ], result[ pos ] );
			}
			
			// reset iterator pointer
			grid.iterator.pointer = defaultPosition;
			
			// return level rings
			return usePoints ? result : grid.parsePointers( getFlattedArray(result) );
		}
		/**
		 * @private
		 * 
		 * @param	dp	Array
		 * @return Array
		 * 
		 * */
		private function getRing( dp:Array ) : Array
		{
			var arr :Array = cloneArray( dp );
			var uniquePoints : Array = new Array( );
			for each( var pt : Pointer in arr )
			{
				var lazySquare : Array = square( pt , true );
				if ( uniquePoints.length == 0 )
				{
					uniquePoints = uniquePoints.concat( lazySquare )
				}
				else
				{
					// concatenating points
					uniquePoints = uniquePoints.concat( getDifference( uniquePoints, lazySquare, Pointer.isDifferent ) )
				}
			}
			return uniquePoints;
		}
		/**
		 *	
		 *	
		 *	@param p_arr Array
		 *	@return Array
		 *	
		 */
		public function rowNeighbours( pt:Pointer = null , usePoints:Boolean = true ) : Array
		{
			var result : Array = new Array
			pt = pt==null ? grid.iterator.pointer : pt;
			
			if ( !grid.hasCell( pt ) ) 
				return null
			
			var tmp : Array = grid.getRow( pt.r );
			result = tmp.slice ( pt.c+1, tmp.length );
				
			// return level rings
			return usePoints ? result : grid.parsePointers( getFlattedArray(result) );
		}
		/**
		 *	
		 *	
		 *	@param p_arr Array
		 *	@return Array
		 * 
		 */
		public function columnNeighbours( pt:Pointer = null ) : Array
		{
			var result : Array = new Array
			return result;
		}
	}
}