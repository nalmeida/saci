package redneck.util.string 
{
	public function trim(value:String):String
	{
		return value.replace(/\s|\t|\v|\n/g,"");
	}
}

