/**
*
*	Layout é uma especie de wrapper para a Arrange.
*	A ideia principal é posicionar elementos num layout de forma que eles possam ter suas posicoes/tamanhos 
*	alteradas e dinamicamente seu posicionamento é corrigido.
*
*	Essa atualização pode ser feita automaticamente <code>start</code> , ou vc pode atualizar manulamente 
* 	mudando o setter <code>update</code> entre 0 e 1 (opção para quem quer atualizar com alguma engine de tween).
*
*	Equanto <code>start</code> ou algum <code>update</code> nao for executado, nenhum alinhamento irá acontecer.
*
*	@see start
* 	@see update
*	@see Arrange
*	@see LayoutItem
*	
*	@author igor almeida
*	
*	@version 1.2
*	
*	@usage
*	<code>
*		var reff : * = addChild(getPlaceHolder(100,100))
*		var toChange : * =  addChild(getPlaceHolder(50,100));
*		layout = addChild(new Layout());
*		layout.add(reff, toChange ).toRight( )
*		layout.start( );
*	</code>
*
*	No exemplo, se <code>reff</code> mudar de posicao/tamanho, <code>toChange</code> irá se reposicionar a 
*	esquerda de <code>reff</code> novamente.
*
*	O interessante desse approach para layout de objects é que a instacia de <code>LayoutItem</code> 
*	retornada no metodo <code>add</code> sempre retorna uma instancia dela propria após qualquer metodo de posicionamento,
*	permitindo em uma unica linha fazer varios tipo de pocisionamentos:
*
*	<code>
*		layout.add(reff, toChange ).toRight( ).toBottom( ) // sempre a direita e abaixo de reff
* 	</code>
*
*	Caso vc precisa plugar outro elemento no layout, vc pode usar o metodo <code>LayoutItem.chain</code>
*
*	<code>
*		var toChange2 : * =  addChild(getPlaceHolder(50,50));
*		layout.add(reff, toChange ).toRight( ).chaing( toChange2 ).toRight( )
* 		// <code>toChange</code> a esquerda e abaixo de reff e 
*		//<code>toChange2</code> a esquerda de <code>toChange</code>
*	</code>
*
* 	Quando o <code>chain</code> é chamado ele pluga <code>toChange2</code> a <code>toChange</code>, fazendo o mesmo que:
*	layout.add(toChange, toChange2).toRight();
* 
**/	
package redneck.layout {

	import flash.events.*;
	import flash.geom.*;
	import flash.display.*;
	import redneck.arrange.*;
	
	public final class Layout extends Sprite{
		
		private var _list : Array;
		private var _updateStep : Number = 0;
		private var _isStarted : Boolean;
		private var _isLocked : Boolean;
		private var _hasSkiped : Boolean;

		public function Layout( ):void
		{
			super( );
			_list = [];
		}
		/**
		*	@private
		**/
		private function startEngine():void{
			addEventListener( Event.ENTER_FRAME, arrange );
		}
		/**
		*	@private
		**/
		private function stopEngine():void{
			removeEventListener( Event.ENTER_FRAME, arrange );
		}
		/**
		*	@return Boolean
		**/
		public function get isStarted():Boolean
		{
			return _isStarted;
		}
		/**
		*	
		*	Creates the link between two objects.
		*	
		*	@param p_reff	object which will be checked
		*	@param p_change object wich will change the position
		*	@param p_props	object no modelo ArrangeProperties
		*	
		*	@return LayoutItem
		*	
		*	@usage
		*	var layout:layout = new Layout()
		*		layout.add( square1, square2 ).toRight( ).
		*		// will move square2 on the right site of square1 and keep then always beside then if square1 changes the site/position
		*		layout.start( );
		*	
		**/
		public function add( p_reff:Object, p_change:Object, p_props:Object = null ) : LayoutItem
		{
			if ( (p_reff==null || p_change==null) || 
				 (p_reff==p_change || p_change is Stage) ||
				 ( (!p_reff.hasOwnProperty("width") || !p_reff.hasOwnProperty("height")) && 
				   (!p_change.hasOwnProperty("width") || !p_change.hasOwnProperty("height")))
			){
				return null;
			}
			var uid : String = getUID( [p_reff, p_change] );
			var layoutItem : LayoutItem = getItemByUID( uid );
			if ( !layoutItem ){
				layoutItem = new LayoutItem( this, [ p_reff,p_change ], p_props ? ArrangeProperties.fromObject(p_props) : ArrangeProperties.defaultInstance );
				layoutItem.uid = uid;
				_list.push(layoutItem);
			}
			return layoutItem;
		}
		
		/**
		*	
		*	Removes a <code>LayoutItem</code>
		*	
		*	@param p_item	String or LayoutItem
		*	
		*	@return Boolean true if the remove has successful
		*	
		**/
		public function remove( p_item: * ):Boolean{
			var toRemove : LayoutItem;
			if ( p_item is LayoutItem){
				toRemove = p_item;
			}else if ( p_item is String ){
				toRemove = getItemByUID( p_item );
			}else{
				return false;
			}
			var item : LayoutItem
			var index : int = 0
			var length : int = _list.length
			for ( index= 0; index<length; index++ ){
				item = _list[index];
				if ( item.uid == toRemove.uid ){
					toRemove.onChange = null;
					toRemove = null;
					_list.splice( index,1 );
					return true;
				}
			}
			return false;
		}
		/**
		*
		*	Returns a <code>LayoutItem</code> by a relation between two instances
		*		
		*	@param p_reff
		*	@param p_change
		*	
		*	@return LayoutItem
		*	
		*	@usage
		*	var layout:Layout = new Layout();
		*		layout.add(square1, square2)
		*		layout.start
		*	
		*	var layoutItem : LayoutItem = layout.getItem(square1, square2).top( );
		*	
		**/
		public function getItem( p_reff:Object, p_change:Object ):LayoutItem{
			if ( !p_reff || !p_change){
				return null;
			}
			return getItemByUID( getUID([p_reff, p_change]) );
		}
		/**
		*	
		*	Returns a <code>LayoutItem</code> by UID;
		*	
		*	@see LayoutItem.uid
		*	
		*	@return LayoutItem
		*	
		**/
		public function getItemByUID(p_uid:String):LayoutItem{
			var item : LayoutItem; 
			var p_item : LayoutItem;
			for each( p_item in _list) {
				if (p_item.uid == p_uid) {
					return p_item;
				}
			}
			return item;
		}
		/**
		*	
		*	Start auto-checking. 
		*	
		*	When started the engine <code>Layout</code> will performes an updated
		*	on each ENTER_FRAME event. If you just want to update once you must 
		*	use the <code>update</code> to save your frame rate.
		*	
		*	@see stop
		*	@see update
		*	
		**/
		public function start(e:*=null):void{
			_isStarted = true;
			startEngine();
		}
		/**
		*	
		*	Stop auto-udpating
		*	
		*	@see start
		*	@see update
		*	
		**/
		public function stop(e:*=null):void{
			_isStarted = false;
			stopEngine();
		}
		/**
		*	@private
		*	auto update items
		**/
		private function arrange(e:Event):void{
			_isLocked = false;
			if ( _isStarted ){
				update = 1;
			}
			else if( _hasSkiped ){
				_hasSkiped = false;
				update = _updateStep;
			}else{
				stopEngine();
			}
		}
		/**
		*	
		*	Update layout.
		*	
		*	The advantage using directly the update is because you can updated your layout
		*	using some tween engine or because after updating the engine will stops.
		*	
		*	@param step	Number Between 0 and 1.
		*	@see start
		*	
		*	@example
		*		var l : Layout = new Layout();
		*	
		**/
		public function set update( step:Number ):void{

			// avoiding invalid steps, empty list.
			if ( step <= 0 || _list.length==0 ){
				_isLocked = false;
				return;
			}

			// force starting the engine in case to update be called without <code>start</code>.
			if ( !hasEventListener(Event.ENTER_FRAME) ){
				startEngine();
				_isLocked = false;
			}

			// storing step.
			_updateStep = step;
			if ( _isLocked ){
				_hasSkiped = true;
				return;
			}
			
			// updating instances.
			var length : int = _list.length;
			var index : int  = 0;
			var item : LayoutItem;
			while( index < length ){
				item = _list[index];
				if( item!=null && ( item.items[0]!=null && item.items[1]!=null ) ){
					item.update( _updateStep );
				}
				index++;
			}
			
			// updating status
			_isLocked = true;
			_updateStep = 0;
		}
		/**
		*	
		*	Returns the current update step
		*	
		*	@return Number
		*	
		**/
		public function get update():Number{
			return _updateStep;
		}
		/**
		*	Clear everything.
		**/
		public function destroy():void{
			stop();
			_list = null;
		}
		/**
		*	@private
		*	@return String
		**/
		private function getUID( p_items:Array ):String{
			var	n : String = p_items[0] is Stage ? "stage" : p_items[0].hasOwnProperty("name") ? p_items[0].name.toString() : p_items[0].toString( );
				n += "<->";
				n += p_items[1].hasOwnProperty("name") ? p_items[1].name.toString() : p_items[1].toString( );
			return n;
		}
	}
}

