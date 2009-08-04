package project_name.sessions.collections {
	
	/**
	 * Coleção de dependências (assets que fazem parte de uma [Session])
	 * @author Marcelo Miranda Carneiro | Nicholas Pires de Almeida
	 * @version 0.1
	 * @since 4/2/2009 22:16
     * @see project_name.sessions.vo.DependencyLinkageVO
	 */
	
	import saci.collection.Collection;
	import project_name.data.ServerData;
	import project_name.sessions.DependencyLinkage;
	
	public class DependencyLinkageCollection extends Collection {
		
		public function DependencyLinkageCollection(...$itens) {
			_itemType = DependencyLinkage;
			super($itens);
		}
		
		/**
		 * Pega uma dependência por ID
		 * @param	$id
		 * @return
		 */
		public function getByName($name:String):DependencyLinkage {
			var i:int;
			for (i = 0; i < itens.length; i++) {
				if (itens[i].name == $name) {
					return itens[i];
				}
			}
			return null;
		}
		
		public function getClass($containerName:String, $linkageName:String):Class {
			var dependencyLinkage:DependencyLinkage = getByName($containerName);
			if(dependencyLinkage != null)
				return dependencyLinkage.getClass($linkageName);
			return null;
		}
		public function cloneInstance($containerName:String, $linkageName:String):*{
			var dependencyLinkage:DependencyLinkage = getByName($containerName);
			if(dependencyLinkage != null)
				return dependencyLinkage.cloneInstance($linkageName);
			return null;
		}
		public function getUniqueInstance($containerName:String, $linkageName:String):*{
			var dependencyLinkage:DependencyLinkage = getByName($containerName);
			if(dependencyLinkage != null)
				return dependencyLinkage.getUniqueInstance($linkageName);
			return null;
		}
		
		
	}
	
}