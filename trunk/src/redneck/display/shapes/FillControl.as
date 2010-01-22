/**
* 
* @author igor almeida
* version 1.0
*
**/
package redneck.display.shapes
{
	import flash.display.*
	import flash.geom.*
	[Bindable]
	public class FillControl
	{	
		/*callback*/
		public var onChange : Function;
		internal function change():void{if(onChange!=null)onChange.apply(null);}
		/**
		*
		*	If the array has only one value, a <code>Graphics.beginFill</code> or <code>Graphics.lineStyle</code> will be performed. 
		*	Or else they will be applied as <code>Graphics.beginGradientFill</code> or <code>Graphics.lineGradientStyle</code>.
		*	
		*	@see Graphics.beginGradientFill
		*	@see Graphics.lineGradientStyle
		*	
		**/
		internal var _colors : Array
		public function get colors():Array{return _colors;}
		public function set colors(value:Array):void
		{
			_colors = value;
			change();
		}
		/**
		*
		*	If the array has only one value, a <code>Graphics.beginFill</code> or <code>Graphics.lineStyle</code> will be performed. 
		*	Or else they will be applied as <code>Graphics.beginGradientFill</code> or <code>Graphics.lineGradientStyle</code>.
		*	
		*	@see Graphics.beginGradientFill
		*	@see Graphics.lineGradientStyle
		*	
		**/
		internal var _alphas : Array;
		public function get alphas():Array{return _alphas;}
		public function set alphas(value:Array):void
		{
			_alphas = value;
			change();
		}
		/**
		*
		*	This is a just a percentage multiplier to performe at <code>FillControl.alphas</code>
		*	It is perfect when you have to tween your Shape without change the <code>DisplayObject.alpha</code> and
		*	at the same time you will preserve the stroke.
		*	
		*	@example:
		*	
		*	var box : Box =  new Box(new Rectangle(0,0,10,10));
		*		box.fill.colors = [0,0xffffff];
		*		box.fill.alphas = [1,0.5];
		*		box.fill.alphasStep = .5
		*	
		*		// when filling this shape the alphas will be changed to [.5,.25];
		*		//or 
		*	
		*	Tweener.addTween( box, {alphasStep:0, time:1} );
		*	
		*	@param Number between 0 and 1.
		*	@see FillControl.alphas
		*	
		**/
		internal var _alphasStep : Number = 1;
		public function get alphasStep():Number{return _alphasStep;}
		public function set alphasStep(value:Number):void{
			_alphasStep = value;
			change();
		}
		/**
		*
		*	@see Graphics.beginGradientFill
		*	@see Graphics.lineGradientStyle
		*	
		**/
		internal var _spreadMethod : String = SpreadMethod.PAD;
		public function get spreadMethod():String{return _spreadMethod;}
		public function set spreadMethod(value:String):void
		{
			_spreadMethod = value;
			change();
		}
		/**
		*
		*	@see Graphics.beginGradientFill
		*	@see Graphics.lineGradientStyle
		*	
		**/
		internal var _interpolationMethod : String = InterpolationMethod.RGB;
		public function get interpolationMethod():String{return _interpolationMethod;}
		public function set interpolationMethod(value:String):void{
			_interpolationMethod = value;
			change();
		}
		/**
		*
		*	@see Graphics.beginGradientFill
		*	@see Graphics.lineGradientStyle
		*	
		**/
		internal var _focalPointRatio: Number = 0;
		public function get focalPointRatio():Number{return _focalPointRatio;}
		public function set focalPointRatio(value:Number):void{
			_focalPointRatio = value;
			change();
		}
		/**
		*
		*	@see Matrix.createGradientBox
		*	
		**/
		internal var _gradientHeight: Number;
		public function get gradientHeight():Number{return _gradientHeight;}
		public function set gradientHeight(value:Number):void{
			_gradientHeight = value;
			change();
		}
		/**
		*
		*	@see Matrix.createGradientBox
		*	
		**/
		internal var _gradientWidth: Number;
		public function get gradientWidth():Number{return _gradientWidth;}
		public function set gradientWidth(value:Number):void{
			_gradientWidth = value;
			change();
		}
		/**
		*
		*	@see Graphics.beginGradientFill
		*	@see Graphics.lineGradientStyle
		*	
		**/
		internal var _gradientType: String = GradientType.LINEAR;
		public function get gradientType():String{return _gradientType;}
		public function set gradientType(value:String):void{
			_gradientType = value;
			change();
		}
		
		/**
		*
		*	@see Graphics.beginGradientFill
		*	@see Graphics.lineGradientStyle
		*	
		**/
		internal var _ratios : Array;
		public function get ratios():Array{return _ratios;}
		public function set ratios(value:Array):void{
			_ratios = value;
			change();
		}
		/**
		*
		*	@see Graphics.beginGradientFill
		*	@see Graphics.lineGradientStyle
		*	
		**/
		internal var _gradientX: Number = 0;
		public function get gradientX():Number{return _gradientX;}
		public function set gradientX(value:Number):void{
			_gradientX = value;
			change();
		}
		/**
		*
		*	@see Matrix.createGradientBox
		*	
		**/
		internal var _gradientY: Number = 0;
		public function get gradientY():Number{return _gradientY;}
		public function set gradientY(value:Number):void{
			_gradientY = value;
			change();
		}
		/**
		*
		*	@see Matrix.createGradientBox
		*	
		**/
		internal var _gradientRotation : Number = 0;
		public function get gradientRotation():Number{return _gradientRotation;}
		public function set gradientRotation(value:Number):void
		{
			_gradientRotation = value;
			change();
		}
		/**
		*
		*	@see Matrix.createGradientBox
		*	
		**/
		internal var _matrix : Matrix = new Matrix( );
		public function get matrix():Matrix{
			_matrix.createGradientBox( gradientWidth ,gradientHeight, gradientRotation*0.01745329251994, gradientX, gradientY );
			return _matrix;
		}
		/**
		*	
		*	Returns a colection of relative alphas based on the <code>alphasStep</code>
		*	
		*	@see alphasStep;
		*	
		*	@return Array
		*	
		**/
		internal var _relativeAlphas : Array;
		public function get relativeAlphas():Array{
			_relativeAlphas = null
			if (alphas){
				_relativeAlphas = new Array( alphas.length);
				alphas.forEach(evaluateAlphas);
			}
			else if ( colors && colors.length>0 ){
				_relativeAlphas = new Array( colors.length );
				var fakeAlphas:Array = new Array( );
				colors.forEach( function(...rest):void{ fakeAlphas.push( 1 ); });
				fakeAlphas.forEach( evaluateAlphas );
			}
			return _relativeAlphas;
		}
		/**
		*	
		*	Performs a step in each alphas value preserving the original array
		*	
		*	@param p_item
		*	@param p_index
		*	@param p_array
		**/
		private function evaluateAlphas( p_item:Number, p_index:int, p_arr:Array ):void{
			_relativeAlphas[p_index] = p_arr[p_index]*alphasStep;
		}
	}
}