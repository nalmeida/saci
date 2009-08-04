package project_name.sessions.collections {
	
	/**
	 * Coleção de dependências (assets que fazem parte de uma [Session])
	 * @author Marcelo Miranda Carneiro | Nicholas Pires de Almeida
	 * @version 0.1
	 * @since 4/2/2009 22:16
     * @see project_name.sessions.vo.DependencyItemVO
     * @see project_name.sessions.Session
     * @see project_name.sessions.SessionManager
	 */
	
	import project_name.data.ServerData;
    import project_name.sessions.vo.DependencyItemVO;
	import saci.collection.Collection;
	
	public class DependencyItemVOCollection extends Collection {
		
		static private var _serverData:ServerData = ServerData.getInstance();
		
		/**
		 * Lê o nó de cada seção para instancia-los recursivamente
		 * @param	$xml
		 * @param	$parent
		 */
		static public function parseXML($itemList:XMLList, $shortcuts:Object):DependencyItemVOCollection {
			
			if ($itemList == null) return null;
			
			var dependencies:DependencyItemVOCollection = new DependencyItemVOCollection();
			var dependencyXml:XML;
			
			for (var i:int = 0; i < $itemList.length(); i++) {
				dependencyXml = $itemList[i];
				dependencies.addItem(new DependencyItemVO(
					_serverData.parseString(_serverData.parseString(dependencyXml.@name.toString(), $shortcuts)),
					_serverData.parseString(_serverData.parseString(dependencyXml.@value.toString(), $shortcuts)),
					_serverData.parseString(_serverData.parseString(dependencyXml.@type.toString(), $shortcuts)),
					DependencyLinkageVOCollection.parseXML(dependencyXml.linkage, $shortcuts),
					int(_serverData.parseString(_serverData.parseString(dependencyXml.@weight.toString(), $shortcuts))),
					_serverData.parseString(_serverData.parseString(dependencyXml.@version.toString(), $shortcuts))
				));
			}
			return dependencies;
		}
		
		public function DependencyItemVOCollection(...$itens) {
			_itemType = DependencyItemVO;
			super($itens);
		}
		
		/**
		 * Pega uma dependência por ID
		 * @param	$id
		 * @return
		 */
		public function getById($id:String):DependencyItemVO {
			var i:int;
			for (i = 0; i < itens.length; i++) {
				if (itens[i].id == $id) {
					return itens[i];
				}
			}
			return null;
		}
		
	}
	
}
