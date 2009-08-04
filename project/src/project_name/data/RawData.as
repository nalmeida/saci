package project_name.data {
	
	/**
	 * Based on 2 objects, uses the mockup object when the primary object value is null
	 * @author Marcelo Miranda Carneiro (mcarneiro@fbiz.com.br)
	 * @version 0.1
	 * @example
	 * <code>
	 *   var mockData:Object = {
	 *     "carneiro":{
	 *       "pessoal":{
	 *         "idade": 25,
	 *         "sexo": "M"
	 *       }
	 * 	   }
	 *   };
	 * 
	 *   var rawData:RawData = new RawData(RECEIVED_OBJECT_FROM_SERVER, mockData);
	 *   trace("idade: " + rawData.get("carneiro.pessoal.idade")) // idade: 25
	 * 
	 *   var dadosPessoais = rawData.cloneInstanceAt("carneiro.pessoal");
	 *   trace("idade: "+dadosPessoais.get("idade")); // idade: 25
	 * 
	 * </code>
	 */
	public class RawData {
		
		protected var _data:Object;
		protected var _mockup:Object;
		
		public function RawData($data:Object, $mockup:Object) {
			_data = $data != null ? $data : {};
			_mockup = $mockup != null ? $mockup : {};
		}
		
		/**
		 * returns the value
		 * @param	value string of the part of the object to be parsed.
		 * @return
		 * @example
		 * <code>
		 *   rawData.get("carneiro.pessoal.idade")
		 * </code>
		 */
		public function get(value:String):* {
			//TODOFBIZ: --- [RawData.get] Make array parser
			var returnValue:* = getByObject(value, _data);
			return returnValue != null ? returnValue : getByObject(value, _mockup);
		}
		
		/**
		 * get value by object (in case, "data" or "mockup data")
		 * @param	value
		 * @param	baseObject
		 * @return
		 */
		protected function getByObject(value:String, baseObject:Object):* {
			
			if (value == null)
				return null;
			
			if (value == "")
				return baseObject;
			
			var values:Array = value.split(".");
			var valuesLength:int = values.length;
			var currentObject:Object = baseObject;
			
			for (var i:int = 0; i < valuesLength; i++) {
                currentObject = currentObject[values[i]];
				if (!currentObject) {
					return null;
				}
			}
			
			return currentObject;
		}
		
		/**
		 * creates a new rawData instance based on the part or the original object.
		 * @param	value string of the part of the object to be cloned into a new rawData object.
		 * @return
		 * <code>
		 *   var dadosPessoais = rawData.cloneInstanceAt("carneiro.pessoal");
		 *   trace("idade: "+dadosPessoais.get("idade")); // idade: 25
		 * </code>
		 */
		public function cloneInstanceAt(value:String):RawData {
			return new RawData(getByObject(value, _data), getByObject(value, _mockup));
		}
	}
	
}
