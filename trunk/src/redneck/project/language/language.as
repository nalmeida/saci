/**
 * 
 * @author igor almeida
 * @version 0.2
 * */
package redneck.project.language
{
	public function language( p_locale : String = null) : CopyDeck
	{
		if ( !p_locale && !copy.currentLocale ){
			return copy;
		}
		copy.setLocale( p_locale || copy.currentLocale ); 
		return copy;
	}
}
import redneck.project.language.CopyDeck;
internal const copy : CopyDeck = new CopyDeck();