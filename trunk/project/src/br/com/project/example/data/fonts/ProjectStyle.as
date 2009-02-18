package br.com.project.example.data.fonts {
	
	/**
    * @author Marcelo Miranda Carneiro
	*/
	
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	import saci.font.FontManager;
	import saci.font.Style;
	
	public class ProjectStyle {
		
		static public function init($rawData:Object):void {
			
			var i:int;
			for (i = 0; i < $rawData.styles.length; i++) {
				Style.add(
					$rawData.styles[i].name,
					new TextFormat(
						FontManager.getFontName($rawData.styles[i].fontName),
						$rawData.styles[i].size,
						uint($rawData.styles[i].color),
						$rawData.styles[i].bold,
						$rawData.styles[i].italic,
						$rawData.styles[i].underline,
						null,
						null,
						$rawData.styles[i].align,
						$rawData.styles[i].leftMargin,
						$rawData.styles[i].rightMargin,
						int($rawData.styles[i].indent),
						int($rawData.styles[i].leading)
					),
					null,
					$rawData.styles[i].optValue
				);
			}
			
			//Style.add("itemText", new TextFormat(FontManager.getFontName("helvetica"), 15, 0xD60101), null, {
				//wordWrap: false,
				//autoSize: TextFieldAutoSize.LEFT
			//});
			//Style.add("itemTextItalic", new TextFormat(FontManager.getFontName("helvetica"), 15, 0xD60101, null, true));
		}
	}
}
