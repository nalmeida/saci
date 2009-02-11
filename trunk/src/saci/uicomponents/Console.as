package saci.uicomponents {
	
	import flash.events.Event;
	import flash.events.MouseEvent
	import flash.events.KeyboardEvent;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import net.hires.debug.Stats;
	
	import saci.events.ListenerManager;
	import saci.ui.SaciSprite;
	
	/**
	 * Classe que cria uma console visual e exibe os eventos que recebe. Funciona como uma tracer.
	 * @author Nicholas Almeida
	 * @since	27/1/2009 18:30
	 * @example
	 * <pre>
	 * var console:Console = new Console();
	 * addChild(console);
	 * </pre>
	 * 
	 * @example usando a console para receber os dados da Logger
	 * <pre>
	 * var console:Console = new Console();
	 * Logger.init(Logger.LOG_VERBOSE, console.log);
	 * addChild(console);
	 * </pre>
	 * @see saci.util.Logger
	 */
	public class Console extends SaciSprite{
		
		public var bgColor:uint;
		public var consoleWidth:int;
		public var consoleHeight:int;
		public var isPaused:Boolean;
		
		private var _stats:Stats;
		private var _fldText:TextField;
		private var _bgBox:SaciSprite;
		private var _dragBox:SaciSprite;
		
		private static var _isInstanceCreated:Boolean;
		
		/**
		 * Construtora da Console. Só pode aceita criar uma única instancia
		 * @param	$bgColor	Cor de fundo do console
		 * @param	$consoleWidth	Largura inicial do console
		 * @param	$consoleHeight	Altura inicial do console
		 */
		public function Console($bgColor:uint = 0x33, $consoleWidth:int = 400, $consoleHeight:int = 200) {
			super();
			
			if (Console._isInstanceCreated == true) {
				throw new Error("[Console Constructor] ERROR: Console instance is  already created.");
			}
			
			bgColor = $bgColor;
			consoleWidth = $consoleWidth;
			consoleHeight = $consoleHeight;
			
			isPaused = false;
			
			super._listenerManager.addEventListener(this, Event.ADDED_TO_STAGE, _onAddedToStage);
			
			Console._isInstanceCreated = true;
		}
		
		/**
		 * Escreve dentro do textfield a mensagem
		 * @param	$txt	Texto que se deseja logar
		 */
		public function log($txt:*):void {
			if (!isPaused) {
				appendText($txt);
			}
		}
		
		/**
		 * Reposiciona os elementos do console baseado na posição do _dragBox
		 */
		public function refresh():void {
			_bgBox.x = _stats.width;
			_bgBox.width = _dragBox.x + _dragBox.width - _stats.width;
			_bgBox.height = _dragBox.y + _dragBox.height;
			
			_fldText.width = _bgBox.width - 4;
			_fldText.height = _bgBox.height - 12;
			_fldText.x = _bgBox.x + 2;
		}
		
		/**
		 * Habilida o logger
		 */
		public function play():void {
			isPaused = false;
			appendText("-- PLAY --");
		}
		
		/**
		 * Desabilita o logger
		 */
		public function pause():void {
			isPaused = true;
			appendText("-- PAUSED --");
		}
		
		/**
		 * Exibe o console e força o textfield a exibir a última linha escrita
		 */
		override public function show():void {
			super.show();
			_fldText.scrollV = _fldText.textHeight;
		}
		
		/**
		 * Adiciona a linha ao textfield com o timestamp na frente
		 * @param	$txt
		 */
		private function appendText($txt:*):void {
			_fldText.appendText("[" + _getTimestamp() + "] " + $txt + "\n");
			_fldText.scrollV = _fldText.textHeight;
		}
		
		/**
		 * Retorna a hora:minuto:segundo
		 * @return
		 */
		private function _getTimestamp():String {
			var d:Date = new Date();
			return String(_normalizeTime(d.getHours()) + ":" + _normalizeTime(d.getMinutes()) + ":" + _normalizeTime(d.getSeconds()));
		}
		
		/**
		 * Handler de quando o console for adicionado ao stage
		 * @param	e
		 */
		private function _onAddedToStage(e:Event):void{
			super._listenerManager.removeEventListener(this, Event.ADDED_TO_STAGE, _onAddedToStage);
			
			_bgBox = new SaciSprite();
			_bgBox.graphics.beginFill(bgColor, 1);
			_bgBox.graphics.drawRect(0, 0, consoleWidth, consoleHeight);
			_bgBox.graphics.endFill();			
			
			_fldText = new TextField();
			_fldText.background = true;
			_fldText.y = 10;
			_fldText.defaultTextFormat = new TextFormat("_sans", 10, 0x000000);
			_fldText.wordWrap = true;
			
			_dragBox = new SaciSprite();
			_dragBox.graphics.beginFill(bgColor, 1);
			_dragBox.graphics.drawRect(0, 0, 10, 10);
			_dragBox.graphics.endFill();	
			
			_stats = new Stats();
			
			addChild(_stats);
			addChild(_bgBox);
			addChild(_fldText);
			addChild(_dragBox);
			
			_dragBox.x = consoleWidth - _dragBox.width;
			_dragBox.y = consoleHeight - _dragBox.height;
			
			refresh();
			
			super._listenerManager.addEventListener(_bgBox, MouseEvent.MOUSE_DOWN, _onClick);
			super._listenerManager.addEventListener(_bgBox, MouseEvent.MOUSE_UP, _onRelease);
			super._listenerManager.addEventListener(_fldText, MouseEvent.MOUSE_DOWN, _stopPropagation);
			super._listenerManager.addEventListener(_dragBox, MouseEvent.MOUSE_DOWN, _onClickDragBox);
			
			if (this.stage) {
				super._listenerManager.addEventListener(this.stage, Event.MOUSE_LEAVE, _onRelease);
			}
			
			super._listenerManager.addEventListener(this.stage, KeyboardEvent.KEY_UP, _onKeyPress);
			
			hide();
		}
		
		/**
		 * Handler de drag da _dragBox
		 * @param	e
		 */
		private function _onClickDragBox(e:MouseEvent):void{
			_stopPropagation(e);
			_dragBox.startDrag();
			super._listenerManager.addEventListener(this, Event.ENTER_FRAME, _onRefresh);
			super._listenerManager.addEventListener(_dragBox, MouseEvent.MOUSE_UP, _onReleaseDragBox);
		}
		
		/**
		 * Handler de drag da _dragBox
		 * @param	e
		 */
		private function _onReleaseDragBox(e:MouseEvent):void {
			super._listenerManager.removeEventListener(this, Event.ENTER_FRAME, _onRefresh);
			super._listenerManager.removeEventListener(_dragBox, MouseEvent.MOUSE_UP, _onReleaseDragBox);
			_dragBox.stopDrag();
			refresh();
		}
		
		/**
		 * Função que para a propagação dos eventos de mouse
		 * @param	e
		 */
		private function _stopPropagation(e:MouseEvent):void{
			e.stopPropagation();
		}
		
		/**
		 * Handler do fundo
		 * @param	e
		 */
		private function _onClick(e:MouseEvent):void{
			this.startDrag();
		}
		
		/**
		 * Handler do fundo
		 * @param	e
		 */
		private function _onRelease(e:*):void{
			this.stopDrag();
		}
		
		/**
		 * Handler de quando a _dragBox é largada
		 * @param	e
		 */
		private function _onRefresh(e:Event):void{
			refresh();
		}
		
		/**
		 * Handler de teclas de atalho
		 * @param	e
		 */
		private function _onKeyPress(e:KeyboardEvent):void {
			if (e.shiftKey && e.ctrlKey &&  e.altKey) {
				if (e.keyCode == 186) { // ;
					if(visible) hide();
					else show();
				} else if (e.keyCode == 80) { // p
					if (isPaused) play();
					else pause();
				}
			}
		}
		
		/**
		 * Recebe o um número e se ele for menor que 10 retorna ele como string e com o zero a esquerda.
		 * @param	$time
		 * @return
		 */
		private function _normalizeTime($time:int):String {
			return $time < 10 ? "0" + $time : $time.toString();
		}
	}
	
}