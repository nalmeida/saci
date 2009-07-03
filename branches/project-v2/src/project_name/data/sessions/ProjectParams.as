package project_name.data.sessions {
	
	/**
    * @author Marcelo Miranda Carneiro
	*/
	
	public class ProjectParams {
		
		private var _paramObject:Object = {};
		
		public function ProjectParams ($params:XMLList) {
			if ($params == null) return;
			var i:int;
			for (i = 0; i < $params.children().length(); i++) {
				_paramObject[$params.children()[i].@id.toString()] = $params.children()[i].@value.toString();
			}
		}
		
		public function get($id:String):String {
			return _paramObject[$id];
		}
		
	}
	
}
