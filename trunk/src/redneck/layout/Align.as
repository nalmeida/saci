/**
*
* Align é apenas um wrapper para a Layout que por sua vez tem todas as facilidades da Arrange
* porem static e precisa de um stage para inicia-la.
*
* Caso deseje fazer a animação de reposicionamento de stage com tween, é só nao iniciar o metodo <code>start</code>
* da classe e usar o update, assim com na em <code>Layout</code>
*
* @see Layout
* @author igor almeida
* @version 1.0
*
**/
package redneck.layout {
	import flash.display.*;
	import flash.events.*;
	import flash.geom.*;
	public class Align {
		/*@private*/
		private static var stage : Stage;
		private static var layout : Layout;
		private static var stageBounds : Rectangle;
		/*@pubic*/
		public static var maxBounds : Rectangle;
		public static var minBounds : Rectangle;
		/**
		*	
		*	@param p_stage
		*	@param p_min	Rectangle min allowed area to check
		*	@param p_max	Rectangle max allowed area to check
		*	
		*	@return Boolean
		*	
		**/
		public static function create( p_stage:Stage, p_min:Rectangle = null, p_max:Rectangle=null ):Boolean{
			if (!p_stage||stage!=null){
				return false;
			}
			stage = p_stage;
			layout = new Layout();
			stage.addChild(layout);
			maxBounds = p_max;
			minBounds = p_min;
			stageBounds = new Rectangle(0,0,stage.stageWidth, stage.stageHeight);
			return true;
		}
		/**
		*	Atualiza o layout quando o stage mudar de tamanho
		**/
		public static function start():void{
			if (stage){
				stage.addEventListener(Event.RESIZE,render);
			}
		}
		/**
		*	Pára o monitoramento do tamanho do stage.
		**/
		public static function stop():void{
			if (stage){
				stage.removeEventListener(Event.RESIZE,render);
			}
		}
		/**
		*	
		*	@param p_reff
		*	@param p_quiet
		*	@see Layout.remove
		*	
		*	@return Boolean
		*	
		**/
		public static function remove( p_reff:*, p_quiet: Boolean = true):Boolean{
			if (stage){
				return layout.remove( layout.getItem(stage,p_reff) );
			}
			return false;
		}
		/**
		*	
		*	@param p_obj
		*	@param p_props
		*	@see Layout.add
		*	
		*	@return LayoutItem
		*	
		**/
		public static function add( p_obj :*, p_props:* = null ): LayoutItem {
			if (stage){
				var chain : LayoutItem = layout.add( stage, p_obj, p_props )
					chain.onChange = render;
					return chain;
			}
			return null;
		}
		/**
		*	Checa se as dimensoes estao dentro dos bounds permitidos para fazer o alinhamento.	
		*	@retunr Boolean
		**/
		private static function checkBounds ( ) :Boolean{
			stageBounds = new Rectangle(0,0,stage.stageWidth, stage.stageHeight);
			if ( maxBounds==null && minBounds==null ){
				return true;
			}
			var resultMax : Boolean = false;
			var resultMin : Boolean = false;
			if ( minBounds ){
				if (stageBounds.width>= minBounds.width && stageBounds.height>=minBounds.height){
					resultMin = true;	
				}
			}else{
				resultMin = true
			}
			if ( maxBounds){
				if(stageBounds.width<= maxBounds.width && stageBounds.height<=maxBounds.height){
					resultMax = true;
				}
			}else{
				resultMax = true
			}
			return resultMax && resultMin ;
		}
		/**
		*	Atualiza o layout	
		**/
		private static function render( p_item:* ):void{
			update = 1;
		}
		/**
		*	Setter para atualizar o layout
		*	@param p_step	Number
		**/
		public static function set update ( p_step : Number) : void{
			if (stage){
				if ( checkBounds( ) ){
					layout.update = p_step;
				}
			}
		}
		/**
		*	Retorna o current step
		*	@return Number
		**/
		public static function get update ( ) : Number{
			if (stage){
				return layout.update;
			}
			return 0;
		}
	}
}