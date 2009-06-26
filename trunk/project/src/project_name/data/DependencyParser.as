package project_name.data {
	
	/**
    * @author Marcelo Miranda Carneiro
	*/
	
    import project_name.sessions.collections.DependencyItemVOCollection;
    import project_name.sessions.vo.DependencyItemVO;
	
	public class DependencyParser {
		
		static public var _serverData:ServerData = ServerData.getInstance();
		
		/**
		 * Lê o nó de cada seção para instancia-los recursivamente
		 * @param	$xml
		 * @param	$parent
		 */
		static public function parseXML($xml:XML, $shortcuts:Object):DependencyItemVOCollection {
			
			if ($xml == null) return null;
			
			var dependencies:DependencyItemVOCollection = new DependencyItemVOCollection();
			var dependencyXml:XML;
			var dependency:DependencyItemVO;
			var i:int;
			
			for (i = 0; i < $xml.item.length(); i++) {
				dependencyXml = $xml.item[i];
				dependencies.addItem(new DependencyItemVO(
					_serverData.parseString(_serverData.parseString(dependencyXml.@name.toString(), $shortcuts)),
					_serverData.parseString(_serverData.parseString(dependencyXml.@value.toString(), $shortcuts)),
					_serverData.parseString(_serverData.parseString(dependencyXml.@type.toString(), $shortcuts)),
					int(_serverData.parseString(_serverData.parseString(dependencyXml.@weight.toString(), $shortcuts))),
					_serverData.parseString(_serverData.parseString(dependencyXml.@version.toString(), $shortcuts))
				));
			}
			return dependencies;
		}
	}
}
