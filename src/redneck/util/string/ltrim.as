package redneck.util.string 
{
	public function ltrim(value:String):String
	{
		return value.replace(/^[\s|\t|\v|\n]/,"");
	}
}