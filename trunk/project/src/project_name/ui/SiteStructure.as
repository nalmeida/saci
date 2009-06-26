package project_name.ui {
	
	/**
    * @author Marcelo Miranda Carneiro
	*/
	
    import project_name.data.sessions.ProjectParams;
    import project_name.sessions.Base;
	import com.adobe.serialization.json.JSON;
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.text.Font;
	import saci.util.ClassUtil;
	import saci.util.DocumentUtil;
	
	public class SiteStructure {
		
		static private var _base:Base;
		static private var _params:ProjectParams;
		static private var _json:Object; //TODOFBIZ: --- [SiteStructure._json] Gerar objeto StrongType

		static private var _container:DisplayObjectContainer;
		static private var _bg:DisplayObject;
		
		static public function init($container:DisplayObjectContainer, $base:Base):void {
			_base = $base;
			_container = $container;
			_params = new ProjectParams(_base.params);
			if(_base.loader.bulk.getText("config") != "")
				_json = JSON.decode(_base.loader.bulk.getText("config"));
			else {
				_json = {};
			}
			
			// registrar os elementos estruturais (de lay out) aqui
			
			update();
		}
		
		static public function update():void {
			// disparado no resize do flash (adicionado na Main.as)
		}
		
		static public function get json():Object { return _json; }
	}
}


