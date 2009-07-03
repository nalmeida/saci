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
	
    import project_name.sessions.vo.DependencyItemVO;
	import saci.collection.Collection;
	
	public class DependencyItemVOCollection extends Collection {
		
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
