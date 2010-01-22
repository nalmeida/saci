/**
 * A ideia da TextBreaker é ser uma **simples** forma de separar caracteres de um textfield e anima-los separadamente.
 * Ela **não** foi desenvolvida para separa textos complexos como por exemplo htmlText com imagens, mas sim para labels, titles e textos comuns.
 *
 * @author igor almeida
 * @version 1.0
 *
 * @todo a classe ainda apresente problemas quando vc tem em um mesmo texto mais um um TextFormat com tamnhos de font diferentes e quebras de linha.
 * @todo testar caracteres especiais
 * @todo htmlText com todos os tipode de styles.
 *
 * @usage
 *
 *	<code>
 * public function TextBreakerTest()
 * {
 *		super();
 *		txt = new TextField();
 *		txt.multiline = true
 *		txt.htmlText = "<font size='25' color='#ff0000'><b>redneck</b><br></font>breakapart test!";
 *		addChild(txt);
 *
 *		box = TextBreaker.breakapart( txt, TextBreaker.BITMAP, true );
 *		addEventListener(Event.ENTER_FRAME, addWorld)
 *	}
 *	private function addWorld(e:Event):void{
 *		if (current == null){
 *			current = box[0];
 *		}
 *		current.x = current.finalX;
 *		current.y = current.finalY + 100;
 *		addChild(current)
 *		if (!current.next){
 *			removeEventListener(Event.ENTER_FRAME, addWorld);
 *		}
 *		current = current.next;
 *	}
 *	</code>
 */
package redneck.textfield {

	import flash.text.*;
	import flash.geom.*;
	import flash.display.*;
	public class TextBreaker{
		
		public static const TEXTFIELD : String = "render-textField";
		public static const BITMAP : String = "render-bitmap";
		/**
		 *	
		 * TextBreaker é uma simples static que tem aplica a um textfield uma especie de breakapart
		 * retornando um array com os elementos (TextBox) de cada caracter do textfield separadamente.
		 *	
		 * Esse elementos podem ser aplicados na tela como textfield novamente ou bitmat (melhor performance);
		 *	
		 *	@param p_field			TextField
		 *	@param p_render			String		TEXTFIELD or BITMAP
		 *	@param p_adjustPosition Boolean		true irá colocar os TextBox nas posicioes finais, senao fica todo mundo na posicao 0,0 caso queria fazer alguma animação para cada item, nesse caso é só usar a posicao finalX e finalY.
		 *
		 *	@return Array
		 *	
		 */
		public static function breakapart ( p_field : TextField, p_render: String = TEXTFIELD, p_adjustPosition:Boolean = true ) : Array
		{
			var result : Array = new Array
			if (!p_field || p_field.text.length<1) {
				return result;
			}
			var chars : int = p_field.text.length;
			var bounds : Rectangle;
			var metrix : TextLineMetrics;
			while(chars--){
				if(escape(p_field.text.charAt(chars)) == "%0D"){
					continue;
				}
				bounds = p_field.getCharBoundaries(chars);
				metrix = p_field.getLineMetrics( p_field.getLineIndexOfChar(chars) );
				bounds.x-= metrix.x;
				bounds.y-= 2 
				// 2 is a refrence to "pixel gutter".
				// @see http://livedocs.adobe.com/flash/9.0/ActionScriptLangRefV3/flash/text/TextLineMetrics.html.

				var box : TextBox = new TextBox( p_field.text.charAt(chars), bounds );
					box.id = chars;
					box.render( p_field.getTextFormat(chars) , p_render, p_adjustPosition );
					if (box.field){
						box.field.selectable = p_field.selectable;
					}
				box.next = result[ result.length-1 ] ? result[ result.length-1 ] : null;
				if ( result.length > 1 ){
					result[ result.length-1].prev = box;
				}
				result.push(box);
			}
			return result.reverse();
		}
		
		/**
		*	Apply <code>p_list</code> in a specific context
		*	
		*	@parma	p_list		Array;
		*	@param	p_context	DisplayObjectContainer
		*	@param	p_iniX		Number
		*	@param	p_iniY		Number
		*	
		*	@return Array
		*	
		**/
		public static function applyList ( p_list:Array, p_context:DisplayObjectContainer, p_iniX:Number = 0, p_iniY:Number = 0 ) : Array{
			if (p_list && p_context){
				var index : int = 0;
				var length : int  = p_list.length;
				var item : DisplayObject
				while (index<length ){
					item = p_context.addChild( p_list[index] );
					item.x += p_iniX;
					item.y += p_iniY;
					index++;
				}
				return p_list;
			}
			return null;
		}
	}
}

