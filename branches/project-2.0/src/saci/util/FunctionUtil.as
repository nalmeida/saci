package saci.util {
	import flash.utils.clearTimeout;
	import flash.utils.setTimeout;
	
	/**
	 * @author Marcelo Miranda Carneiro (mcarneiro@fbiz.com.br)
	 */
	public class FunctionUtil {
		
		/**
		 * Queue functions by time
		 * @param	methods array of functions OR a object containing a "method":Function and "params":Array
		 * @param	interval interval number (will be executed time by time) or array (will be executed index by index)
		 */
		private static var _queue:Object = {};
		public static function timeQueue(id:String, methods:Array, interval:*):void {
			_queue[id] = [];
			if (interval != null && methods != null) {
				var i:int = 0;
				switch(true) {
					case (interval is Array):
						var	currentInterval:Number;
						for (i = 0; Boolean(methods[i]); i++) {
							currentInterval = interval[i] != null && !isNaN(interval[i]) ? interval[i] : 0;
							if (currentInterval == 0) {
								if (methods[i] is Function) {
									methods[i]();
								}else{
									methods[i].method.apply(null, methods[i].params);
								}
							}else {
								if (methods[i] is Function) {
									_queue[id].push(setTimeout(methods[i], (i + 1) * (currentInterval*1000)));
								}else{
									_queue[id].push(setTimeout(methods[i].method.apply, (i + 1) * (currentInterval * 1000), null, methods[i].params));
								}
							}
						}
						break;
					case (!isNaN(interval)):
						for (i = 0; Boolean(methods[i]); i++) {
							if(methods[i] != null && (methods[i] is Function || methods[i].method is Function)){
								if (interval == 0) {
									if (methods[i] is Function) {
										methods[i]();
									}else{
										methods[i].method.apply(null, methods[i].params);
									}
								}else {
									if (methods[i] is Function) {
										_queue[id].push(setTimeout(methods[i], (i + 1) * (interval*1000)));
									}else{
										_queue[id].push(setTimeout(methods[i].method.apply, (i + 1) * (interval * 1000), null, methods[i].params));
									}
								}
							}
						}
						break;
					default:
						throw new Error("[FunctionUtil.timeQueue] ERROR: interval MUST be a Array OR Number. Current interval value: " + interval);
				}
			}else {
				throw new Error("[FunctionUtil.timeQueue] ERROR: methods and interval MUST be defined: methods: " + methods + " /  interval: " + interval);
			}
		}
		public static function stopQueue(id:String):void {
			if (_queue[id] != null && _queue[id].length > 0) {
				for (var i:int = 0; Boolean(_queue[id][i]); i++) {
					clearTimeout(_queue[id][i]);
				}
			}
		}
	}
	
}