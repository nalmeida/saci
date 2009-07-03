package project_name.sessions.collections {
	
	/**
	 * Coleção de Strings
	 * @author Marcelo Miranda Carneiro | Nicholas Pires de Almeida
	 * @version 0.1
	 * @since 4/2/2009 22:16
     */
	
	import saci.collection.Collection;
	
	public class ExternalSessionURLCollection extends Collection{
		
		public function ExternalSessionURLCollection(...$itens) {
			_itemType = String;
			super($itens);
		}
		
		public function has($value:String):Boolean {
			
		}
		
	}
	
}