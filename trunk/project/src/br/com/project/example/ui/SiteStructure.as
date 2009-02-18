package br.com.project.example.ui {
	
	/**
    * @author Marcelo Miranda Carneiro
	*/
	
	import br.com.project.example.data.fonts.ProjectStyle;
	import br.com.project.example.data.sessions.ProjectSessionParams;
	import br.com.project.sessions.Base;
	import com.adobe.serialization.json.JSON;
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.text.Font;
	import saci.font.FontManager;
	import saci.util.ClassUtil;
	import saci.util.DocumentUtil;
	
	public class SiteStructure {
		
		static private var _base:Base;
		static private var _params:ProjectSessionParams;
		static private var _json:Object; //TODOFBIZ: --- [SiteStructure._json] Gerar objeto StrongType

		static private var _container:DisplayObjectContainer;
		static private var _bg:DisplayObject;
		
		static public function init($container:DisplayObjectContainer, $base:Base):void {
			_base = $base;
			_container = $container;
			_params = new ProjectSessionParams(_base.params);
			_json = JSON.decode(_base.loader.bulk.getText("config"));
			
			//{ register fonts
			FontManager.add(
				_json.fonts.helveticaBlack, 
				ClassUtil.getClassFromSwf(_base.loader.bulk.getContent("fonts"), _params.get("helveticaBlack")),
				null,
				ClassUtil.getClassFromSwf(_base.loader.bulk.getContent("fonts"), _params.get("helveticaBlackItalic"))
			);
			ProjectStyle.init(_json);
			//}

			_bg = ClassUtil.cloneClassFromSwf(_base.loader.bulk.getContent("movieclipbase"), _params.get("bg")) as DisplayObject;
			_bg.alpha = .1;
			_container.addChild(_bg);
			
			update();
			
		}
		
		static public function update():void {
			_bg.x = Number(_json.background.left);
			_bg.y = Number(_json.background.top);
			_bg.width = DocumentUtil.stage.stageWidth - (_bg.x*2);
			_bg.height = DocumentUtil.stage.stageHeight - (_bg.y*2);
		}
		
		static public function get json():Object { return _json; }
	}
}


