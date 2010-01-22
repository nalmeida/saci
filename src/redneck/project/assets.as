/**
 * @author igor almeida.
 * */
package redneck.project
{
	public function assets( propName: String = null ) : *
	{
		if ( propName!=null ) return vo[ propName ];
		return vo;
	}
}
import redneck.util.ExtendedObject;
internal const vo : ExtendedObject = new ExtendedObject();