package project_name.sessions {
	
	/**
	 * @author Marcelo Miranda Carneiro
	 */

	import flash.display.DisplayObject;
	import saci.util.ClassUtil;
	import saci.util.Logger;
	import project_name.sessions.collections.DependencyLinkageVOCollection;
	import project_name.sessions.vo.DependencyLinkageVO;
	 
	public class DependencyLinkage {
		
		protected var _ready:Boolean;
		protected var _name:String;
		protected var _parent:DisplayObject;
		protected var _info:DependencyLinkageVOCollection;
		protected var _instances:Object = {};
		
		public function DependencyLinkage($name:String, $info:DependencyLinkageVOCollection) {
			_name = $name;
			_info = $info;
		}
		
		public function init($parent:DisplayObject):void {
			_parent = $parent;
			if(_parent != null) _ready = true;
		}
		
		/**
		 * Get the class by linkage name from the dependency
		 * @param	$name
		 * @return
		 */
		public function getClass($name:String):Class {
			_verifyReady();
			var currentInstance:DependencyLinkageVO = _info.getByName($name);
			if(currentInstance != null)
				return ClassUtil.getClassFromSwf(_parent, currentInstance.name);
			return Object;
		}
		
		/**
		 * Get an instance by linkage name from the dependency
		 * @param	$name
		 * @return
		 */
		public function cloneInstance($name:String):* {
			_verifyReady();
			var currentInstance:DependencyLinkageVO = _info.getByName($name);
			var typeClass:Class; 
			if (currentInstance != null) {
				typeClass = getClass(currentInstance.className);
				if(typeClass != null)
					return ClassUtil.cloneClassFromSwf(_parent, currentInstance.name) as typeClass;
			}
			return null;
		}
		
		/**
		 * get a unique instance by linkage name from the dependency
		 * @param	$name
		 * @return
		 */
		public function getUniqueInstance($name:String):* {
			_verifyReady();
			if (_instances[$name] == null) 
				_instances[$name] = cloneInstance($name);
			return _instances[$name];
		}
		
		protected function _verifyReady():void {
			if (!_ready)
				Logger.logWarning("[DependencyLinkage] The dependency \"" + _name + "\" is not ready (probably not finished loading).");
		}
		
		/**
		 * the name of the dependency
		 */
		public function get name():String { return _name; }
		
		/**
		 * linkage collection VO (info) of the dependency
		 */
		public function get linkageCollection():DependencyLinkageVOCollection { return _info; }
		
		/**
		 * if the dependency is ready (exists and was built)
		 */
		public function get ready():Boolean { return _ready; }
		
	}
	
}