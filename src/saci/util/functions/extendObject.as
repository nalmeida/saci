package carneiro.util.shortcuts {

	public function extendObject(...args):Object {
		var returnObject:Object = {};
		for (var i:int = 0; args[i]; i++) {
			for(var n:String in args[i]){
				if(args[i][n] != null && !(args[i][n] is String) && !(args[i][n] is Number) && !(args[i][n] is Array)){
					if(returnObject[n] == null) returnObject[n] = {};
					returnObject[n] = extendObject(returnObject[n], args[i][n]);
				}else{
					returnObject[n] = args[i][n];
				}
			}
		}
		return returnObject;
	}

}