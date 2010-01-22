package redneck.project.misc
{
	import br.com.stimuli.loading.BulkLoader;
	import br.com.stimuli.loading.loadingtypes.LoadingItem;
	import br.com.stimuli.loading.loadingtypes.SoundItem;
	
	import redneck.sound.SoundController;
	/**
	 * 
	 * Cria uma soudcontroller a partir de uma bulkloader
	 * (com os itens já carregados) e um nó de xml no 
	 * modelo de dependencies. (config.xml ou sessions.xml);
	 * 
	 * @param	libName	String
	 * @param	dp		BulkLoader
	 * @param	node	XML
	 * @return SoundController
	 * 
	 * */
	public function getSoundControllerByXML( libName:String, dp:BulkLoader, node:XML ) : SoundController
	{
		var sc:SoundController = SoundController.getController( libName );
		if ( !sc )
		{
			sc = new SoundController ( libName, false );
		}
		items : for each( var item : LoadingItem in dp._items )
		{
			if( item is SoundItem && item.isLoaded )
			{
				var props : Object =
				{
					volume		: Number( node.file.(id==item.id).volume.toString( ) ) || 1,
					loops  		: int( node.file.(id==item.id).loops.toString( ) ) || 0,
					id     		: item.id
				}
				sc.add( dp.getSound( item.id ), props );	
			}
		}
		return sc;
	}
}