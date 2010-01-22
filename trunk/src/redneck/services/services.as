package redneck.services
{
	/**
	*	wrapper para ServiceLocator like a singleton
	*	
	*	@param p_id	String	service id
	*	
	*	@return ServiceLocator if p_id == null or Service
	*	
	**/
	public function services( p_id: String = null ) : * {
		if (p_id){
			return instance.get( p_id );
		}
		return instance;
	}
}

import redneck.services.*
internal const instance: ServiceLocator= new ServiceLocator();