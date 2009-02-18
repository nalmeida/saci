package br.com.project.example.data.sessions {
	
	/**
    * @author Marcelo Miranda Carneiro
	*/
	
	public class ProjectSessionParams {
		
		private var _paramObject:Object = {};
		
		public function ProjectSessionParams ($params:XMLList) {
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
