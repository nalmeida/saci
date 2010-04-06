package saci.project.data {
	
import br.com.stimuli.string.printf;
	
	
	public class Config extends Object {

		/**
		 * Add data via XMLList
		 * @example
		 * <p>Example XMLList:</p>
		 * <listing version="3.0">
		 * var xml:XMLList = &lt;data&gt;
		 *                       &lt;root value="./" /&gt;
		 *                       &lt;localePath value="%(root)spt-BR/" &gt;
		 *                       &lt;globalPath value="%(root)sglobal/" &gt;
		 *                       &lt;/item&gt;
		 *                   &lt;/data&gt;
		 * configPath: "%(globalPath)sconfig/",
		 * var config:Config = new Config();
		 *     config.addDataFromXML(xml.children());</listing>
		 */
		public static function parseXML(p_value:XMLList):Config {
			var currentObject:Object = {};
			for (var i:int = 0; Boolean(p_value[i]); i++){
				currentObject[String(p_value[i].name())] = String(p_value[i].@value);
			}
			return parseJSON(currentObject);
		};

		/**
		 * Add data via JSON
		 * @example
		 * <p>Example XMLList:</p>
		 * <listing version="3.0">
		 * var configObj:Object = {
		 *     root: "./",
		 *     localePath: "%(root)spt-BR/",
		 *     globalPath: "%(root)sglobal/"
		 * };
		 * var config:Config = new Config();
		 *     config.addDataFromJSON(configObj);</listing>
		 */
		public static function parseJSON(p_value:Object):Config {
			var returnValue:Config = new Config();
			if(p_value != null){
				for (var p:String in p_value.data) {
					returnValue._data[p] = p_value.data[p];
				}
			}
			returnValue._replaceData();
			return returnValue;
		};

		protected var _data:Object;
		protected var _replace:Boolean;

		public function Config() {
			super();
			_data = {};
		}
		
		public function addData(p_name:String, p_value:String):void{
			if(p_name != null && p_value != null){
				_data[p_name] = printf(p_value, _data);
			}
		}
		public function getData(p_name:String):String {
			return _data[p_name];
		}
		
		//public function getListData():String{
		//	// todo: get list data as friendly string
		//}
		
		protected function _replaceData():void{
			_replace = false;
			for (var p:String in _data) {
				_data[p] = printf(_data[p], _data);
				if(_data[p].match(/\%\(.*?\)/) != null){
					_replace = true;
				}
			}
			if(_replace){ _replaceData(); }
		}

	}
}