package project_name.sessions.vo {
	
	/**
	 * @author Marcelo Miranda Carneiro
	 */
	
	public class DependencyLinkageVO {
		
		private var _name:String;
		private var _className:String;
		
		public function DependencyLinkageVO($name:String, $className:String) {
			_name = $name;
			_className = $className;
		}
		
		public function toString():String {
			return "[DependencyItemLinkageVO] name: " + name + "; className: " + className + ";";
		}
		
		public function get name():String { return _name; }
		public function get className():String { return _className; }
	}
	
}