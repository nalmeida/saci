package project_name.sessions.vo {
	
	/**
	 * Value Object de dependência (assets que fazem parte de uma [Session])
	 * @author Marcelo Miranda Carneiro | Nicholas Pires de Almeida
	 * @version 0.1
	 * @since 4/2/2009 22:16
     * @see project_name.sessions.collections.DependencyItemVOCollection
     * @see project_name.sessions.Session
     * @see project_name.sessions.SessionManager
	 */
	
	public class DependencyItemVO{
		
		private var _name:String;
		private var _value:String;
		private var _type:String;
		private var _weight:int;
		private var _version:String;
		
		public function DependencyItemVO($name:String, $value:String, $type:String, $weight:int, $version:String) {
			_name = $name;
			_value = $value;
			_type = $type;
			_weight = $weight;
			_version = $version;
		}
		
		public function toString():String {
			return "[DependencyItemVO] name: " + name + "; value: " + value + "; type: " + type + "; weight: " + weight + "; " + version + "; ";
		}
		
		/**
		 * ID da dependência
		 */
		public function get name():String { return _name; }
		
		/**
		 * URL da dependência
		 */
		public function get value():String {
			if (version != "" && version != null) {
				_value += ((_value.match(/\?/) == null) ? "?" : "&") + "v=" + version;
			}
			return _value;
		}
		
		/**
		 * Tipo da dependência (movieclip, bitmap, text...)
		 */
		public function get type():String { return _type; }
		
		/**
		 * Peso da dependência (para weightPercent preciso)
		 */
		public function get weight():int { return _weight; }
		
		/**
		 * Versão da dependência (usado para anti-cache)
		 */
		public function get version():String {
			if (_version == "auto") {
				return Math.random().toString() + (new Date().getDate());
			}
			return _version;
		}

	}
}
