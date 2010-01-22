package redneck.util
{
	public function toBoolean( p_value : * ) : Boolean
	{
		return (p_value==true || p_value=="true" || p_value=="TRUE" || p_value==1 || p_value=="t");
	}
}