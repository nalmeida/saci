package project_name.data.sessions {
	
	/**
	* @author Marcelo Miranda Carneiro
	*/
	
	import saci.util.Logger;
	
	public class ProjectParams {
		
		private var _paramObject:Object = {};
		
		public function ProjectParams ($params:XMLList) {
			var currentParam:String;
			var paramsLength:int = $params.length();
			for (var i:int = 0; i < paramsLength; i++) {
				currentParam = $params[i].@id.toString();
				if (_paramObject[currentParam] != null){
					Logger.logWarning("[ProjectParams.ProjectParams] param \"" + currentParam + "\" already exists! Overriding.");
				}
				_paramObject[currentParam] = $params[i].@value.toString();
			}
			currentParam = null;
		}
		
		public function get($id:String):String {
			return _paramObject[$id];
		}
		
		public function getList():String {
			var toReturn:Array = [];
			for (var i:String in _paramObject){
				toReturn[toReturn.length] = i + ": " + _paramObject[i];
			}
			return toReturn.join("\n");
		}
	}
}
