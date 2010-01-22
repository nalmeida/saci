/**
*
*	@author igor almeida
*	@version 1.2
*
*	@see Layout
*	@see Align
*	@see Arrange
*
**/
package redneck.layout {
	import redneck.arrange.*;
	import flash.geom.*;
	import flash.display.*;
	import flash.events.*;
	public class LayoutItem extends EventDispatcher{
		/**@internal**/
		//internal var bounds:Rectangle;
		internal var items : Array;
		internal var uid : String;
		internal var _props : ArrangeProperties;
		internal var onChange : Function;
		internal var onUpdate : Function;

		/**@private**/
		private var scope : Layout
		
		/**@public**/
		private var _toLeft : Boolean;
		private var _byLeft : Boolean
		
		private var _toRight : Boolean;
		private var _byRight : Boolean;
		
		private var _toTop:Boolean;
		private var _byTop:Boolean;
		
		private var _toBottom:Boolean;
		private var _byBottom:Boolean;
		
		private var _centerX:Boolean;
		private var _centerY:Boolean;
		private var _center:Boolean;
		
		private const h : Array = [ "_toLeft", "_toRight", "_byRight", "_byLeft" ];
		private const v : Array = [ "_toTop", "_toBottom", "_byTop", "_byBottom" ];
		/**
		*	
		*	Cria um vinculo de objects para fazer posicionamento.
		*	
		*	@param p_scope Layout
		*	@param p_items Array
		*	@param p_props ArrangeProperties
		*	
		*	@return LayoutItem
		*	
		**/
		public function LayoutItem( p_scope:Layout, p_items:Array, p_props:ArrangeProperties ):void{
			super();
			items = p_items;
			scope = p_scope;
			props = p_props;
		}
		internal function set props ( p_props : ArrangeProperties ) : void{
			_props = p_props;
		}
		internal function get props (  ) : ArrangeProperties{
			return _props;
		}
		/**
		*	
		*	É apenas um wrapper para <code>Layout.add</code> com a diferença de não precisar
		*	passar 2 argumentos como, pois o primeiro elemento nesse caso é o ultimo elemento passado
		*	no <code>Layout.add</code>.
		*	
		*	@usage
		*	var item1 : * = new Sprite()
		*	var item2 : * = new Sprite()
		*	var item3 : * = new Sprite()
		*	
		*	var layout : Layout = new Layout()
		*		layout.add(item1, item2).toRight().chaing(item3).toRight();
		*		layout.start();
		*		// item1, a esquerda item2, a esquerda de item3;
		*	
		*	@param p_item
		*	@param p_props
		*	
		*	@see Layout
		*	
		*	@return LayoutItem
		*	
		**/
		public function chain( p_item : DisplayObject, p_props: Object = null ):LayoutItem{
			return scope.add( items[1], p_item, p_props );
		}
		/**
		*	
		*	Cria um vinculo de contrario ao adicionado em <code>Laytou.add</code>, 
		*	com a vantagem de garantir o posicionamento em caso de qquer um dos objects sofrerem
		*	alteraçoes.
		*	
		*	@usage
		*	var item1 : * = new Sprite()
		*	var item2 : * = new Sprite()
		*
		*	var layout : Layout = new Layout()
		*		layout.add(item1, item2).toRight().crossover( );
		*		layout.start();
		*		// item 1sempre a esquerda de item2 mesmo quando item2 mudar de posicao/tamanho.
		*	
		*	@param p_props
		*	
		*	@see Layout
		*	
		*	@return LayoutItem
		**/
		public function crossover( p_props: Object = null ):LayoutItem{
			return scope.add( items[1],items[0], p_props );
		}
		/**
		*	
		*	@param p_padding Number
		*	
		**/
		public function toLeft( p_padding:Number = 0 ):LayoutItem{
			props.padding_x = p_padding!=0 ? p_padding : props.padding_x;
			clearH()
			_toLeft = true;
			change();
			return this
		}
		/**
		*	
		*	@param p_padding Number
		*	
		**/
		public function byLeft( p_padding:Number = 0 ):LayoutItem{
			props.padding_x = p_padding!=0 ? p_padding : props.padding_x;
			clearH();
			_byLeft = true;
			change();
			return this
		}
		/**
		*	
		*	@param p_padding Number
		*	
		**/
		public function toRight( p_padding:Number = 0 ):LayoutItem{
			props.padding_x = p_padding!=0 ? p_padding : props.padding_x;
			clearH()
			_toRight = true;
			change();
			return this
		}
		/**
		*	
		*	@param p_padding Number
		*	
		**/
		public function byRight( p_padding:Number = 0 ):LayoutItem{
			props.padding_x = p_padding!=0 ? p_padding : props.padding_x;
			clearH();
			_byRight = true;
			change();
			return this
		}
		/**
		*	
		*	@param p_padding Number
		*	
		*	@return LayoutItem
		*	
		**/
		public function toTop( p_padding:Number = 0 ):LayoutItem{
			props.padding_y = p_padding!=0 ? p_padding : props.padding_y ;
			clearV();
			_toTop = true;
			change();
			return this;
		}
		/**
		*	
		*	@param p_padding Number
		*	
		*	@return LayoutItem
		*	
		**/
		public function byTop( p_padding:Number = 0 ):LayoutItem{
			props.padding_y = p_padding!=0 ? p_padding : props.padding_y ;
			clearV();
			_byTop = true;
			change();
			return this;
		}
		/**
		*	
		*	@param p_padding Number
		*	
		*	@return LayoutItem
		*	
		**/
		public function toBottom( p_padding:Number = 0 ):LayoutItem{
			props.padding_y = p_padding!=0 ? p_padding : props.padding_y ;
			clearV();
			_toBottom = true;
			change();
			return this;
		}
		/**
		*	
		*	@param p_padding Number
		*	
		*	@return LayoutItem
		*	
		**/
		public function byBottom( p_padding:Number = 0 ):LayoutItem{
			props.padding_y = p_padding!=0 ? p_padding : props.padding_y ;
			clearV();
			_byBottom = true;
			change();
			return this;
		}
		/**
		*	
		*	@param p_paddingX Number
		*	@param p_paddingY Number
		*	
		*	@return LayoutItem
		*	
		**/
		public function center( p_paddingX:Number = 0, p_paddingY:Number = 0 ):LayoutItem{
			props.padding_y = p_paddingY!=0 ? p_paddingY : props.padding_y;
			props.padding_x = p_paddingX!=0 ? p_paddingX : props.padding_x;
			clearH();
			clearV();
			_center = true;
			change();
			return this;
		}
		/**
		*	
		*	@param p_padding Number
		*	
		*	@return LayoutItem
		*	
		**/
		public function centerX( p_padding : Number = 0 ):LayoutItem{
			props.padding_x = p_padding!=0 ? p_padding : props.padding_x;
			clearH()
			_centerX = true;
			change();
			return this;
		}
		/**
		*	
		*	@param p_padding Number
		*	
		*	@return LayoutItem
		*	
		**/
		public function centerY( p_padding:Number = 0 ):LayoutItem{
			props.padding_y = p_padding!=0 ? p_padding : props.padding_y ;
			clearV();
			_centerY = true;
			change();
			return this;
		}
		/**
		*	
		*	Atualiza as posicoes
		*	
		*	@param step Number
		*	
		**/
		internal function update( step:Number=1 ):void{
			props.step = step;
			if (_toLeft){
				Arrange.toLeft(items,props);
			}
			if (_byLeft){
				Arrange.byLeft(items,props);
			}
			if(_toRight){
				Arrange.toRight(items,props);
			}
			if(_byRight){
				Arrange.byRight(items,props);
			}
			if (_toTop){
				Arrange.toTop(items,props);
			}
			if (_byTop){
				Arrange.byTop(items,props);
			}
			if(_toBottom){
				Arrange.toBottom(items,props);
			}
			if(_byBottom){
				Arrange.byBottom(items,props);
			}
			if ((_centerX && _centerY) || _center){
				Arrange.center(items,props);
			}
			if (_centerX){
				Arrange.centerX(items,props);
			}
			if (_centerY){
				Arrange.centerY(items,props);
			}
			if(onUpdate!=null){
				onUpdate(this);
			}
		}
		/**
		*	
		*	Retorna o status das props que estao marcadas como true;
		*	
		*	@return String
		*	
		**/
		public function status():String{
			var result : String = this.uid;
			var prop : String;
				for each(prop in v){
					if( this[prop]==true ){
						result += "\n"+prop.replace("_","") +":true";
					}
				}
				for each(prop in h){
					if( this[prop]==true ){
						result += "\n"+prop.replace("_","") +":true";
					}
				}
			return result;
		}
		/**
		*	@private
		*	Zera todas as props de alinhamento horizontal
		**/
		private function clearH( ):void{
			for each(var prop:String in h){
				this[prop] = false;
			}
		}
		/**
		*	@private
		*	Zera todas as props de alinhamento vertical
		**/
		private function clearV( ):void{
			for each(var prop:String in v){
				this[prop] = false;
			}
		}
		/**
		*	@private
		*	avisa que alguma prop mudou
		**/
		private function change():void{
			if( onChange!=null ){
				onChange(this);
			}
		}
		/**
		*	@return String
		**/
		public override function toString():String{
			return "LayoutItem: " + uid;
		}
	}
}