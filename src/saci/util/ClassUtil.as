package saci.util {
	
	import flash.display.DisplayObject;
	
	/**
	 * Utilidades para Class
	 * @author Nicholas Almeida
	 * @since 12/2/2009 14:45
	 * @example
	 * <pre>
	 * 		var teste:Sprite = ClassUtil.cloneClassFromSwf(_loader.bulk.getMovieClip("lib_swf"), "lib_sprite") as Sprite;
	 * </pre>
	 */
	public class ClassUtil {
		
		/**
		 * Retorna a Class de um SWF externo
		 * @param	externalSwf	Objeto do SWF
		 * @param	className Nome da classe
		 * @return
		 */
		public static function getClassFromSwf(externalSwf:DisplayObject, className:String):Class {
			return (externalSwf.loaderInfo.applicationDomain.getDefinition(className) as Class);
		}
		
		/**
		 * Retorna uma nova instância de uma Classe de um SWF externo
		 * @param	externalSwf	Objeto do SWF
		 * @param	className Nome da classe
		 * @return
		 */
		public static function cloneClassFromSwf(externalSwf:DisplayObject, className:String):* {
			return new (getClassFromSwf(externalSwf, className) as Class)();
		}
	}
	
}