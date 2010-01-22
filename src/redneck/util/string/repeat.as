package redneck.util.string
{
	/**
	 *
	 * Repeat "level" times the "txt".
	 * 
	 * @example : 
	 *  trace( repeat ( "teste ", 1 ) ) // teste teste
	 * 
	 * @param	txt		String
	 * @para	level	int
	 * @return String
	 *  
	 * */
	public function repeat ( txt:String, level : int ):String
	{
		var str : String = txt;
		while ( level-- )
		{
			str += txt;
		}
		return str;
	}
}