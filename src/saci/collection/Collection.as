package saci.collection {
	
	/**
	* @author Marcelo Miranda Carneiro
	* @since 26/1/2009 17:12
	* @example Criação da classe que extende Collection
	*	<pre>
	*	public class CarneiroItemCollection extends Collection{
	*		public function CarneiroItemCollection(...$itens) {
	*			_itemType = CarneiroItem; // define a propriedade _itemType com a classe cujo elementos do array deverão ser
	*			super($itens);
	*		}
	*	}
	*	</pre>
	* @example Utilização 
	*	<p>
	*		Por questões de boas práticas e organização, o ideal é que o nome de um Collection seja sempre no formato [classe]Collection, como CarneiroItemCollection, que é uma "coleção" de "CarneiroItem".
	*	</p>
	*	<pre>
	*	var objeto:Object = {carneiro:marcelo};
	*	var carneiroItem1:CarneiroItemCollection = new CarneiroItem(PARAMS);
	*	var carneiroItem2:CarneiroItemCollection = new CarneiroItem(PARAMS);
	*	var carneiroItem3:CarneiroItemCollection = new CarneiroItem(PARAMS);
	*	var carneiro:CarneiroItemCollection = new CarneiroItemCollection(
	*		carneiroItem1,
	*		carneiroItem2
	*	);
	*	carneiro.addItem(carneiroItem3);
	*	carneiro.addItem(objeto); // Gera erro (throw) por causa do tipo que não bate
	*	carneiro.removeItem(carneiroItem2);
	*	trace(carneiro.itens) // returns a copy of the array
	*	</pre>
	*/
	
	import saci.util.Logger;
	import saci.interfaces.IDestroyable;
	
	public class Collection implements IDestroyable{
		
		protected var _itemType:Class;
		protected var _itens:Array = [];
		
		/**
		* Cria uma nova coleção (para substituir o array de loose-object). Não pode ser construída sem definir o _itemType com a Classe dos itens do array.
		* @param	...$itens
		*/
		public function Collection($itens:Array) {
			
			if (_itemType == null){
				throw new Error(this + " ERROR: ItemCollectionVO cannot be instantiated directly. There must be a class to extend it, defining the _itemType with a Class to 'strong-type' it");
			}
			
			var i:int;
			for (i = 0; i < $itens.length; i++) {
				if (_verifyValidType($itens[i]) === true) {
					_itens.push($itens[i]);
				}else {
					Logger.logWarning($itens[i]+" is not the same type as \""+_itemType+"\" and will not be added in this collection.");
				}
			}
		}
		
		/**
		* Remove um item da coleção por Objeto
		* @param	$item
		*/
		public function removeItem($item:Object):void {
			if (_verifyValidType($item) !== true) {
				throw new Error(this + ".removeItem " + _itemType + " is not a invalid type to be removed by this collection. Ignoring item.");
				return;
			}
			if (_itens.indexOf($item) >= 0) {
				_itens.splice(_itens.indexOf($item), 1);
			}
		}
		
		/**
		* Remove um item da coleção pelo índice
		* @param	$item
		*/
		public function removeItemByIndex($index:int):void {
			if ($index < _itens.length && $index >= 0) {
				itens.splice($index, 1);
			} else {
				throw new Error(this + ".removeItem " + _itemType + " is not a invalid type to be removed by this collection. Ignoring item.");
			}
		}
		
		/**
		* Adiciona um item à coleção
		* @param	$item
		*/
		public function addItem($item:Object, $index:int = -1):void {
			$index = ($index < _itens.length && $index >= 0) ? $index : -1;
			if (_verifyValidType($item) !== true) {
				throw new Error(this + ".addItem " + _itemType + " is not a invalid type to be added in this collection. Ignoring item.");
				return;
			}
			if(has($item) === false){
				if ($index < 0) {
					_itens.push($item);
				}else{
					_itens.splice($index, 0, $item);
				}
			}else {
				Logger.logWarning(this + ".has Instance of "+_itemType+" already added.");
			}
		}
		
		/**
		* Remove todos os itens da Coleção
		* @param	$item
		*/
		public function destroy():Boolean {
			var i:int;
			for (i = 0; i < _itens.length; i++) {
				if (_itens[i] is IDestroyable) {
					if(_itens[i].destroy() === false) return false;
				}
			}
			_itens = [];
			return true;
		}
		
		/**
		* Verifica o tipo do objeto inserido
		* @param	$item
		* @return
		*/
		protected function _verifyValidType($item:Object):Boolean {
			if (($item as _itemType) is _itemType) {
				return true;
			}
			return false;
		}
		
		/**
		* Verifica se o item já existe na coleção
		* @param	$item
		* @return
		*/
		public function has($item:Object):Boolean {
			var i:int;
			for (i = 0; i < _itens.length; i++) {
				if (_itens[i] === $item) {
					return true;
				}
			}
			return false;
		}
		
		/**
		 * Cópia da coleção
		 */
		public function get itens():Array { return _itens.concat(); }
		
		public function toString():String {
			return "[Collection] "+itens;
		}
	}
}