package redneck.util.string 
{
	public function rtrim(value:String):String
	{
		return value.replace(/[\s|\t|\v|\n]$/,"");
	}
}