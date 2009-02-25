package saci.util {
	
	import flash.display.DisplayObject;
	import flash.utils.describeType;
	
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
		
		/**
		 * Retorna se uma Classe possui um método X
		 * @param	objClass	Objeto classe
		 * @param	methodName	Método que se deseja pesquisar
		 * @return
		 */
		public static function methodExists(objClass:Object, methodName:String):Boolean {
			var desc:XML = flash.utils.describeType(objClass);
			return (desc.method.(@name == methodName).length() > 0);
		}
		
		/**
		 * Retorna se uma Classe possui uma propriedade X
		 * @param	objClass	Objeto classe
		 * @param	propName	Propriedade que se deseja pesquisar
		 * @return
		 */
		public static function propertyExists(objClass:Object,propName:String):Boolean {
			var desc:XML=flash.utils.describeType(objClass);
			return (desc.accessor.(@name == propName).length() > 0);
		}
	
	}
	
}