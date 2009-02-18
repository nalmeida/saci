package br.com.project.ui {
	
	/**
    * @author Marcelo Miranda Carneiro
	*/
	
	import br.com.project.data.sessions.ProjectSessionParams;
	import br.com.project.sessions.Base;
	import com.adobe.serialization.json.JSON;
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	//import flash.text.Font;
	//import saci.font.FontManager;
	import saci.util.ClassUtil;
	
	public class SiteStructure {
		
		static private var _base:Base;
		static private var _params:ProjectSessionParams;
		static private var _config:Object; //TODOFBIZ: --- [SiteStructure._config] Gerar objeto StrongType

		static private var _container:DisplayObjectContainer;
		
		static public function init($container:DisplayObjectContainer, $base:Base):void {
			_base = $base;
			_container = $container;
			_params = new ProjectSessionParams(_base.params);
			
			//FontManager.add(
				//"helvetica", 
				//ClassUtil.getClassFromSwf(_base.loader.bulk.getContent("fonts"), _params.get("helveticaBlack")),
				//null,
				//ClassUtil.getClassFromSwf(_base.loader.bulk.getContent("fonts"), _params.get("helveticaBlackItalic"))
			//);
			
			_container.addChild(ClassUtil.cloneClassFromSwf(_base.loader.bulk.getContent("movieclipbase"), _params.get("bg")) as DisplayObject);
			
			_config = JSON.decode(_base.loader.bulk.getText("config"));
			
			_container.x = _config.left;
			_container.y = _config.top;
		}
	}
}
