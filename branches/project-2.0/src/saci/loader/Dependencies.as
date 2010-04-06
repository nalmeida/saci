package saci.loader {
	
	import flash.events.EventDispatcher;
	import br.com.stimuli.loading.BulkLoader;
	import flash.events.Event;
	import flash.events.ErrorEvent;
	import saci.events.ListenerManager;
	import br.com.stimuli.loading.loadingtypes.LoadingItem;
	import flash.display.DisplayObject;
	import saci.util.ClassUtil;
	import flash.media.SoundLoaderContext;
	import flash.system.LoaderContext;
	
	/**
	 * Extension (by composition) of BulkLoader class with some properties pre-defined and the hability to register linkages for swf files and get instances easier than usual.
	 * @author Marcelo Miranda Carneiro - e-mail: mcarneiro@gmail.com
	 */
	public class Dependencies extends EventDispatcher {
		
		/**
		 * Creates Dependencies Instance via XMLList
		 * @param p_value list of "item" to be parsed and added to the loader
		 * @return Dependencies Instance
		 * @example
		 * 	<p>Example XMLList:</p>
		 * <listing version="3.0">
		 * var xml:XMLList = &lt;root&gt;
		 *                       &lt;item id="config" url="base.txt" preventCache="false" priority="0" maxTries="3" weight="5000" pausedAtStart="false" /&gt;
		 *                       &lt;item id="teste" url="teste.swf" &gt;
		 *                           &lt;linkage name="lib_frame" className="flash.display.MovieClip" /&gt;
		 *                       &lt;/item&gt;
		 *                   &lt;/root&gt;
		 * var dependencies:Dependencies = Dependencies.parseXML(xml.item);</listing>
		 * @see http://media.stimuli.com.br/projects/bulk-loader/docs/br/com/stimuli/loading/BulkLoader.html#add()
		 */
		static public function parseXML(p_value:XMLList, p_loader:BulkLoader = null, p_logLevel:int = 4):Dependencies {
			var returnValue:Dependencies = new Dependencies(p_loader);
			var options:Object = {};
			var attributes:XMLList;
			for (var i:int = 0; Boolean(p_value[i]); i++){
				if(p_value[i].name() == "item"){
					attributes = p_value[i].attributes();
					for (var j:int = 0; Boolean(attributes[j]); j++){
						switch(String(attributes[j].name())){
							case "id":
								options[String(attributes[j].name())] = String(attributes[j]);
								break;
							case "priority":
							case "maxTries":
							case "weight":
								options[String(attributes[j].name())] = int(attributes[j]);
								break;
							case "pausedAtStart":
							case "preventCache":
								options[String(attributes[j].name())] = String(attributes[j]) == "true";
								break;
						}
					}
					returnValue.add(String(p_value[i].@url), options);
					for (var h:int = 0; Boolean(p_value[i].linkage[h]); h++){
						returnValue.addLinkage(String(p_value[i].@id), String(p_value[i].linkage[h].@name), String(p_value[i].linkage[h].@klass));
					}
				}
			}
			return returnValue;
		}

		protected var _listenerManager:ListenerManager;
		protected var _loader:BulkLoader;
		protected var _dependencies:Array;
		protected var _linkages:Array = [];
		protected var _uniqueInstances:Object;

		/**
		 * Can have a existing BulkLoader Instance or will create a unique one
		 * @see http://media.stimuli.com.br/projects/bulk-loader/docs/br/com/stimuli/loading/BulkLoader.html
		 */
		public function Dependencies(p_loader:BulkLoader = null, p_logLevel:int = 4) {
			super();
			_listenerManager = ListenerManager.getInstance();
			_loader = p_loader != null ? p_loader : new BulkLoader(BulkLoader.getUniqueName(), BulkLoader.DEFAULT_NUM_CONNECTIONS, p_logLevel);
			_listenerManager.addEventListener(_loader, Event.COMPLETE, _onLoadSuccess);
			_listenerManager.addEventListener(_loader, ErrorEvent.ERROR, _onLoadError);
			_dependencies = [];
		}
		
		/**
		 * Add linkage data to be used when item is available
		 * @param p_id Bulkloader ID
		 * @param p_name linkage name 
		 * @param p_klass linkage extended class
		 */
		public function addLinkage(p_id:String, p_name:String, p_klass:String):void{
			var currItem:Object = getLinkageData(p_id);
			if(currItem == null){
				currItem = {id: p_id, linkages:[]};
				_linkages.push(currItem);
			}
			if(currItem.linkages == null){
				currItem.linkages = [];
			}
			if(getLinkageItem(p_id, p_name) == null){
				currItem.linkages.push({"name":p_name, "klass":p_klass});
			}
		}
		/**
		 * Gets all linkage data by Bulkloader ID
		 */
		public function getLinkageData(p_id:String):Object {
			for (var i:int = 0; Boolean(_linkages[i]); i++){
				if(_linkages[i].id == p_id){
					return _linkages[i];
				}
			}
			return null;
		}
		/**
		 * Gets specific linkage data
		 * @param p_id Bulkloader ID
		 * @param p_name linkage name
		 */
		public function getLinkageItem(p_id:String, p_name:String):Object {
			var linkagesObj:Object = getLinkageData(p_id);
			var currItem:Array = linkagesObj != null ? linkagesObj.linkages : null;
			if(currItem != null){
				for (var i:int = 0; Boolean(currItem[i]); i++){
					if(currItem[i].name == p_name){
						return currItem[i];
					}
				}
			}
			return null;
		}
		/**
		 * Get unique instance based on setted linkages (only available after completeLoad on Dependencies)
		 * @param p_id Bulkloader ID
		 * @param p_value linkage name
		 * @return unique instance of the called class
		 * @see saci.loader.Dependencies#start()
		 */
		public function getUniqueInstance(p_id:String, p_value:String):*{
			if(_uniqueInstances[p_id] == null){
				_uniqueInstances[p_id] = {};
			}
			if(_uniqueInstances[p_id][p_value] == null){
				_uniqueInstances[p_id][p_value] = cloneInstance(p_id, p_value);
			}
			return _uniqueInstances[p_id][p_value];
		}
		/**
		 * Create new instance based on setted linkages (only available after completeLoad on Dependencies)
		 * @param p_id Bulkloader ID
		 * @param p_value linkage name
		 * @return instance of the called class
		 * @see saci.loader.Dependencies#start()
		 */
		public function cloneInstance(p_id:String, p_name:String):*{
			var loadedElm:* = _loader.getContent(p_id) as DisplayObject;
			var linkage:Object = getLinkageItem(p_id, p_name);
			if(loadedElm != null && linkage != null && ClassUtil.hasClassInSwf(loadedElm, linkage.name)){
				return ClassUtil.cloneClassFromSwf(loadedElm, linkage.name) as Class(ClassUtil.getClassFromSwf(loadedElm, linkage.klass));
			}
			return null;
		}
		/**
		 * Create class based on setted linkages (only available after completeLoad on Dependencies)
		 * @param p_id Bulkloader ID
		 * @param p_value linkage name
		 * @see saci.loader.Dependencies#start()
		 */
		public function getClass(p_id:String, p_value:String):Class{
			var loadedElm:* = _loader.getContent(p_id) as DisplayObject;
			var linkage:Object = getLinkageData(p_value);
			if(loadedElm != null && linkage != null && ClassUtil.hasClassInSwf(loadedElm, linkage.name)){
				return ClassUtil.getClassFromSwf(loadedElm, linkage.name);
			}
			return null;
		}
		
		
		/**
		 * Same as Bulkloader#add() (extended by composition)
		 * @see http://media.stimuli.com.br/projects/bulk-loader/docs/br/com/stimuli/loading/BulkLoader.html#add()
		 */
		public function add(p_url:String, p_options:Object):LoadingItem{
			switch(true){
				case (p_url.match(/\.(?:jpg|jpeg|gif|png|bmp)/i) != null):
					p_options.context = new LoaderContext(true);
					break;
				case (p_url.match(/\.(?:aif|aiff|mp3|wav|wave)/i) != null):
					p_options.context = new SoundLoaderContext(1000, true);
					break;
			}
			return _loader.add(p_url, p_options);
		}
		/**
		 * Same as Bulkloader#remove() (extended by composition)
		 * @see http://media.stimuli.com.br/projects/bulk-loader/docs/br/com/stimuli/loading/BulkLoader.html#remove()
		 */
		public function remove(p_id:String):Boolean{
			return _loader.remove(p_id);
		}
		
		/**
		 * Same as Bulkloader#getContent() (extended by composition)
		 * @see http://media.stimuli.com.br/projects/bulk-loader/docs/br/com/stimuli/loading/BulkLoader.html#getContent()
		 */
		public function getContent(p_id:String):*{
			return _loader.getContent(p_id);
		}
		/**
		 * Same as Bulkloader#start() (extended by composition)
		 * @see http://media.stimuli.com.br/projects/bulk-loader/docs/br/com/stimuli/loading/BulkLoader.html#start()
		 */
		public function start(p_connections:int = -1):void{
			_loader.start(p_connections);
		}

		protected function _onLoadSuccess(e:Event):void{
			dispatchEvent(e.clone());
		}
		protected function _onLoadError(e:ErrorEvent):void{
			_loader.removeFailedItems();
			dispatchEvent(e.clone());
		}
		
		/**
		 * Bulkloader instance
		 */
		public function get loader():BulkLoader { return _loader; }
		
		/**
		 * Same as Bulkloader#isFinished (extended by composition)
		 * @see http://media.stimuli.com.br/projects/bulk-loader/docs/br/com/stimuli/loading/BulkLoader.html#isFinished
		 */
		public function get isFinished():Boolean { return _loader.isFinished; }
		/**
		 * Same as Bulkloader#isRunning (extended by composition)
		 * @see http://media.stimuli.com.br/projects/bulk-loader/docs/br/com/stimuli/loading/BulkLoader.html#isRunning
		 */
		public function get isRunning():Boolean { return _loader.isRunning; }
		/**
		 * Same as Bulkloader#itemsLoaded (extended by composition)
		 * @see http://media.stimuli.com.br/projects/bulk-loader/docs/br/com/stimuli/loading/BulkLoader.html#itemsLoaded
		 */
		public function get itemsLoaded():int { return _loader.itemsLoaded; }
		/**
		 * Same as Bulkloader#itemsTotal (extended by composition)
		 * @see http://media.stimuli.com.br/projects/bulk-loader/docs/br/com/stimuli/loading/BulkLoader.html#itemsTotal
		 */
		public function get itemsTotal():int { return _loader.itemsTotal; }
		/**
		 * Same as Bulkloader#percentLoaded (extended by composition)
		 * @see http://media.stimuli.com.br/projects/bulk-loader/docs/br/com/stimuli/loading/BulkLoader.html#percentLoaded
		 */
		public function get percentLoaded():Number { return _loader.percentLoaded; }
		/**
		 * Same as Bulkloader#logFunction (extended by composition)
		 * @see http://media.stimuli.com.br/projects/bulk-loader/docs/br/com/stimuli/loading/BulkLoader.html#logFunction
		 */
		public function set logFunction(value:Function):void { 
			if(_loader.logFunction !== value){
				_loader.logFunction = value;
			}
		}
		public function get logFunction():Function { return _loader.logFunction; }
	}
}