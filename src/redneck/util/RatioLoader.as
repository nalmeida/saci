/**
 *	@autor igor almeida
 *	@version 0.5
 * 
 * RatioLoader is a loading progress maanager.
 * Using the <code>RatioLoader</code> you can setup the number of
 * steps (</code>maxSteps</code>) your general loader has and in which step you are. 
 * This way you can join all process in one and make it easy to the final user.
 * 
 * Example: você tem um site que para iniciar vc carrega uma sessão 
 * e em seguida um video, mas para o usuário isso precisa ser transparente,
 * e exibir apenas um progresso geral.
 * 
 * Example:
 * // Primeiro vc precisa dizer o numero de steps
 * my_ratio = new RatioLoader();
 * my_ratio.maxSteps = 2
 * // Depois dizer em que step vc está. Neste caso, quando o 
 * // loading chegar a 1 (ou 100%) ele vai
 * my_ratio.step = 1
 * // Associar os progress para a <code>change</code> da ratio loader. 
 * // A RatioLoader já está preparada para receber um BulkProgressEvent, 
 * // nesse caso ela vai usar o <code>weightPercent</code> como referencia.  
 * myLoader.addEventListener(ProgressEvent.PROGRESS, my_ratio.change)
 * 
 * // Quando terminar o primeiro step (100%), o <code>percent</code> do ratio
 * será de <code>.5</code>. Agora, diga em qual step vc está
 * my_ratio.step = 2
 * // Iniciar o segundo carregamento
 * myAnotherLoader.addEventListener(ProgressEvent.PROGRESS, my_ratio.change)
 * 
 * </p>
 */
package redneck.util
{	
{
	import br.com.stimuli.loading.BulkProgressEvent;
	import flash.events.*;
	import redneck.events.*;
	/**
	*	Dispatched when the percent changes.
	*	@eventType flash.events.Event.CHANGE
	*/
	[Event(name="change", type="flash.events.Event")]
	/***/
	public class RatioLoader extends EventDispatcher
	{
		private var _buffer:Number = 0;
		private var _percent:Number
		private var _step:Number
		private var _lastBuffer:Number;
		/* percent filter show how is the max allowed value when the percent is 1. */
		public var percentFilter : Number = 1;
		/* set how many steps the ratio will has */
		public var maxSteps:int;
		/**
		 * RatioLoader
		 * 
		 *	@usage
		 *	<p>
		 * 		mypreloader  = new RatioLoader();
		 *		mypreloader.maxSteps = 3;
		 * 		mypreloader.step = 1;
		 * 		mypreloader.percent = 1;
		 * 		trace(mypreloader.percent+"%")
		 * 		// 0.33%
		 * 
		 *		mypreloader.step = 2;
		 *		mypreloader.percent = 1;
		 * 		trace(mypreloader.percent);
		 * 		// 0.66%
		 * 
		 *		mypreloader.step = 3;
		 * 		mypreloader.percentFilter = .99
		 *		mypreloader.percent = 1
		 * 		trace(mypreloader.percent+"%")
		 * 		// 0.99%
		 * 
		 * */
		public function RatioLoader() : void
		{
			super( );
		}
		/**
		 * 
		 * Set the current step. 
		 * The step must be less or equal to <code>maxSteps</code>  
		 * 
		 * @param s Number
		 * 
		 * */
		public function set step ( s:Number ) : void
		{
			s = (s>maxSteps) ? maxSteps : s;
			_buffer = s/maxSteps;
			_lastBuffer = ( s-1 < 0 ? 0 : s-1 ) / maxSteps;
			_step = s;
		}
		/**
		 * 
		 * Current step
		 * 
		 * @return Number
		 * 
		 * */
		public function get step ( ) : Number
		{
			return _step
		}
		/**
		 * 
		 * if the param is BulkProgressEvent the percent will be setted based 
		 * on weightPercent, else by the bytesLoaded/bytesTotal.
		 * 
		 * @param e	*	BulkProgressEvent or ProgressEvent
		 * 
		 * @usage
		 * <pre>
		 * 
		 * 	// managing the progress with ProgressEvent
		 * 	myLodaer.addEventListener( ProgressEvent.PROGRESS, my_ratio.change );
		 * 
		 *  // managing the progress with BulkProgressEvent
		 * 	myLodaer.addEventListener( BulkProgressEvent.PROGRESS, my_ratio.change );
		 * 
		 * </pre>
		 *  
		 * */
		public function change ( e : Event ) : void
		{
			if ( e ){
				percent = (e is BulkProgressEvent) ? e.weightPercent : e.bytesLoaded/e.bytesTotal;
			}
		}
		/**
		 * 
		 * Sets the relative percent by max steps ratio.
		 * 
		 * @param p Number
		 *  
		 * */
		public  function set percent ( p:Number ):void
		{
			_percent = (_buffer - _lastBuffer) * p + _lastBuffer;
			dispatchEvent( new Event( Event.CHANGE ) );
		} 
		/**
		 * 
		 * Return the ratio percent
		 * 
		 * @return Number
		 * 
		 * */
		public function get percent( ) : Number
		{
			return _percent * percentFilter;
		}
	}
}