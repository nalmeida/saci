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
	import project_name.sessions.vo.DependencyLinkageVO;
	
	public class DependencyLinkageVOCollection extends Collection {
		
		static private var _serverData:ServerData = ServerData.getInstance();
		
		/**
		 * Lê o nó de cada seção para instancia-los recursivamente
		 * @param	$xml
		 * @param	$parent
		 */
		static public function parseXML($itemList:XMLList, $shortcuts:Object):DependencyLinkageVOCollection {
			
			if ($itemList == null) return null;
			
			var linkages:DependencyLinkageVOCollection = new DependencyLinkageVOCollection();
			var linkageXml:XML;
			
			for (var i:int = 0; i < $itemList.length(); i++) {
				linkageXml = $itemList[i];
				
				linkages.addItem(new DependencyLinkageVO(
					_serverData.parseString(_serverData.parseString(linkageXml.@name.toString(), $shortcuts)),
					_serverData.parseString(_serverData.parseString(linkageXml.@className.toString(), $shortcuts))
				));
			}
			return linkages;
		}
		
		public function DependencyLinkageVOCollection(...$itens) {
			_itemType = DependencyLinkageVO;
			super($itens);
		}
		
		/**
		 * Pega uma dependência por ID
		 * @param	$id
		 * @return
		 */
		public function getByName($name:String):DependencyLinkageVO {
			var i:int;
			for (i = 0; i < itens.length; i++) {
				if (itens[i].name == $name) {
					return itens[i];
				}
			}
			return null;
		}
		
	}
	
}