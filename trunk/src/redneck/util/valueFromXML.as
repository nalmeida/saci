/**
 * thanks for gabriel laet
 * */
package redneck.util
{
	public function valueFromXML( p_node: * , p_prop: String ) : *
	{
		if (p_node){
			return p_node.hasOwnProperty(p_prop) ? p_node[ p_prop ] : p_node.attribute( p_prop ).toString();	
		}
		return null;
	}
}