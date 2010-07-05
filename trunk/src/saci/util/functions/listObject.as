package carneiro.util.shortcuts {

	public function listObject(p_value:Object, p_indent:String = ""):String {
		var returnVal:String = "";
		var comma:String = "";
		var quote:String = "";
		var index:uint = 0;
		for(var n:String in p_value){
			comma = ++index == 1 ? "" : ",";
			switch(true){
				case (p_value[n] != null && !(p_value[n] is String) && !(p_value[n] is Number) && !(p_value[n] is Array)):
					if(String(Object(p_value[n]).constructor).match(/Object/)){
						returnVal = p_indent+n+":{\n"+listObject(p_value[n], p_indent+"  ")+p_indent+"}"+comma+"\n"+returnVal;
					}else{
						returnVal = p_indent+n+": "+String(p_value[n])+comma+"\n"+returnVal;
					}
					break;
				case (p_value[n] != null && p_value[n] is Array):
					returnVal += p_indent+n+": [\n";
					for(var i:uint = 0, len:uint = p_value[n].length; i < len; i++){
						comma = i != len-1 ? "," : "";
						if(p_value[n][i] && !(p_value[n][i] is String) && !(p_value[n][i] is Number) && !(p_value[n][i] is Array)){
							returnVal += p_indent+"  {\n"+listObject(p_value[n][i], p_indent+"    ")+p_indent+"  }"+comma+"\n";
						}else{
							returnVal += p_indent+"  "+p_value[n][i]+comma+"\n";
						}
					}
					returnVal += p_indent+"]"+comma+"\n";
					break;
				default:
					quote = p_value[n] is String ? "\"" : "";
					returnVal = p_indent+n+": "+quote+p_value[n]+quote+comma+"\n" + returnVal;
					break;
			}
		}
		return returnVal;
	}
}