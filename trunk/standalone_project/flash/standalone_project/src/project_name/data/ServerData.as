package project_name.data {
	
	/**
	 * Dados dinâmicos externos para um projeto
	 * @author Marcelo Miranda Carneiro | Nicholas Almeida
	 * @version 0.1
	 * @since 4/2/2009 22:16
	 */

	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.external.ExternalInterface;
	import saci.util.DocumentUtil;
	import saci.util.Logger;
	
	public class ServerData extends EventDispatcher{
		
		/**
		 * Static stuff
		 */
		private static var _instance:ServerData;
		private static var _allowInstance:Boolean;
		
		public static function getInstance():ServerData {
			if (ServerData._instance == null) {
				ServerData._allowInstance = true;
				ServerData._instance = new ServerData();
				ServerData._allowInstance = false;
			}
			return ServerData._instance;
		}
		
		/**
		 * Dynamic stuff
		 */
		private var _mockData:Object;
		private var _obj:Object;
		public var isLocal:Boolean;
		
		public function ServerData():void {
			if (ServerData._allowInstance !== true) {
				throw new Error("Use the singleton ServerData.getInstance() instead of new ServerData().");
			}
		}
		
		/**
		 * Carrega dados do javascript (usando ExternalInterface)
		 * @param	$functionName Nome da função que retorna um objeto
		 */
		public function loadDataFromJs($functionName:String, $mockData:Object):void {
			
			//TODOFBIZ: --- [ServerData.loadDataFromJs] USE MOCK FLAG
			
			_mockData = $mockData;
			if (
				ExternalInterface.available
				&& DocumentUtil.isWeb()//mroque: não funciona abrindo a index.html direto no disco
			) {
				_obj = ExternalInterface.call($functionName);
				isLocal = false;
			} else{
				_obj = mockData;
				isLocal = true
			}
			_obj = parseObject(_obj);
			dispatchEvent(new Event(Event.COMPLETE));
		}
		
		/**
		 * Interpreta um objeto para usar os "shortcuts" presentes nele.
		 * @param	$obj
		 * @return Novo objeto com strings substituídas
         * @see lux.data.ServerData#parseString
		 * @example
		 * <pre>
		 * 	// Num objeto
		 * 	var carneiro:Object = {
		 * 		nome: "marcelo",
		 * 		sobrenome: "miranda carneiro",
		 * 		nomeCompleto: "{nome} {sobrenome}"
		 * 	};
		 * 	//É possível reutilizar qualquer item do objeto em outro objeto.
		 * </pre>
		 */
		public function parseObject($obj:Object):Object {
			var i:String;
			for(i in $obj){
				$obj[i] = parseString($obj[i].toString());
			}
			return $obj;
		}
		
		/**
		 * Interpreta uma String com base em um Objeto, usando-o como fonte de "shortcuts".
		 * @param	$value Texto a ser substituído
		 * @param	$obj Objeto fonte, caso não seja passado, usa-se o objeto definido em ServerData
         * @see lux.data.ServerData#parseObject
		 * @return
		 */
		public function parseString($value:String, $obj:Object = null):String {
			
			$obj = ($obj == null) ? _obj : $obj;
			var values:Array = [];
			var finalOrder:Array = [];
			var finalObject:Object = { };
			var orderRegexp:RegExp = new RegExp("\\{(.[^\\}]*)\\}");
			var orderRegexpResult:Array;
			var n:String;
			
			// grava shorcuts usados
			for(n in $obj){

				orderRegexpResult = $obj[n].match(orderRegexp);
				if (orderRegexpResult != null) {
					if (orderRegexpResult[1] != null) {
						if(values.indexOf(orderRegexpResult[1]) < 0){
							values[values.length] = orderRegexpResult[1];
						}
					}
				}
			}
			
			// ordena shortcuts
			var i:int;
			for (i = 0; i < values.length; i++) {
				if($obj[values[i]] != null){
					if ($obj[values[i]].match(orderRegexp) != null) {
						finalOrder.splice(0, 0, values[i]);
					} else {
						finalOrder[finalOrder.length] = values[i];
					}
				}
			}
			
			// substitui itens que usam outros itens
			for (i = 0; i < finalOrder.length; i++) {
				for (n in $obj) {
					$obj[n] = $obj[n].replace(new RegExp("{" + finalOrder[i] + "}", "g"), $obj[finalOrder[i]]);
				}
			}
			
			// substitui string com base no objeto
			for (n in $obj) {
				$value = $value.replace(new RegExp("{" + n + "}", "g"), $obj[n]);
			}
			
			return $value;
		}
		
		/**
		 * Pega uma propriedade
		 * @param	$prop Nome da propriedade do objeto definido em ServerData
		 * @return
		 */
		public function get($prop:String):* {
			return _obj[$prop];
		}
		
		/**
		 * Lista todos as propriedades e valor da ServerData
		 */
		public function list():void {
			var str:String = "\n[ServerData.list]\n";
			for (var name:String in _obj) {
				str += (" > " + name + ": " + _obj[name] + "\n");
			}
			Logger.logWarning(str);;
		}
		
		/**
		 * Dados utilizados caso não seja possível pegar os dados através da loadDataFromJs
         * @see lux.data.ServerData#loadDataFromJs
		 */
		public function get mockData():Object { return _mockData; }
	}
	
}
