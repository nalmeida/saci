package redneck.project.log 
{
	public function log( ...rest ) : LogHistory{
		if ( rest ){
			instance.add.apply(null, [].concat(rest));
		}
		return instance;
	}
}

import redneck.project.log.LogHistory
internal const instance: LogHistory= new LogHistory();