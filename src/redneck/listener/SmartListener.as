/**
 * 
 * 
 * @author igor almeida
 * @version 0.3
 * 
 * @todo documentar
 * 
 */
package redneck.listener
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.utils.Dictionary;
	/***/
	public class SmartListener extends Object
	{
		private static var library:Dictionary
		private static var groups:Dictionary
		private static var inited: Boolean;
		public static var CLEAN_AFTER_REMOVED: Listener = new Listener( Event.REMOVED_FROM_STAGE , SmartListener.removeAll );
		/**
		 * 
		 * */
		public function SmartListener()
		{
			throw new Error("SmartListener is a static class.")
		}
		private static function init () :void
		{
			if (inited )
			{
				return;
			}
			inited = true;
			library = new Dictionary( true );
			groups = new Dictionary( true );
		}
		/**
		 * 
		 * Adiciona listeners para um oject ou uma lista de objects.
		 * Os eventos deve ser no modelo ListenerVO.
		 * 
		 * @param	obj		*	Pode ser um Array ou um IEventDispatcher
		 * @param	events	*	Lista com os ListenerVO a serem registrados
		 * @return Boolean
		 * 
		 * @example
		 * 
		 *	// example 1
		 *	SmartListener.add( bt1 , new ListenerVO( MouseEvent.MOUSE_OVER , over), new ListenerVO( MouseEvent.MOUSE_OUT , out) );
		 * 	
		 *	// example 2
		 *	Voce pode adicionar os mesmos eventos para vários targets. 
		 *	SmartListener.add( [bt1, bt2 ], new ListenerVO( MouseEvent.MOUSE_OVER , over), new ListenerVO( MouseEvent.MOUSE_OUT , out));
		 * 
		 * 	// example 3
		 *	Voce pode adicionar novos eventos para o mesmo target, eles serao somados aos já existentes.
		 *  SmartListener.add( bt1 , new ListenerVO( MouseEvent.MOUSE_OVER , over), new ListenerVO( MouseEvent.MOUSE_OUT , out) );
		 *	SmartListener.add( bt1, new ListenerVO( MouseEvent.CLICK , click ) );
		 *	SmartListener.add( bt1, new ListenerVO( MouseEvent.CLICK , SmartListener.removeAll ) );
		 *  
		 * */
		public static function add( obj : * , ...events ) : Boolean
		{
			init();
			if ( events.length == 0 )
			{
				trace("SmartListener.add no events" )
				return false;
			}
			if ( events[0] is Array){
				trace("SmartListener.add impossible to add this events! Check the method documentation")
				return false;	
			}
			if ( obj is Array )
			{
				for (var index : String in obj )
				{
					 add.apply( SmartListener, [ obj[ index ] ].concat( events ) ); 
				}
			}
			else if ( obj is IEventDispatcher )
			{
				addListener.apply( SmartListener, [ obj ].concat( events ) );
			}
			else
			{
				trace("SmartListener.add invalid param type. You must have to use Array or EventDispatcher : '"+obj+"'")
				return false;
			}
			return true;
		}
		/**
		 * 
		 * Adiciona os eventos no object passado
		 * 
		 * @param	item		IEventDispatcher	object to register listeners
		 * @param 	events		ListenerVO			list of ListenerVO
		 * 
		 * */
		private static function addListener( item : IEventDispatcher , ...events ) : void
		{
			var args: Array = ( events.length > 1 ) ? events as Array : new Array( events[ 0 ] );
			if( library[ item ] )
			{
				library[ item ] = library[ item ].concat( args );
			}
			else
			{
				library[ item ] = args; 
			}
			for ( var evts : String  in library[ item ] )
			{
				var vo : Listener = library[ item ][ evts ] as Listener;
				item.addEventListener( vo.type, vo.method, vo.useCapture, vo.priority, vo.useCapture );	
			}
		}
		/**
		 * 
		 * Remove um evento especifico de um item.
		 * O evento pode ser especificado pela 'function' (ListenerVO.method) ou pelo type (ListenerVO.type).
		 * Somente os eventos registrados com a chave especificada para o 'obj' serão removidos.
		 * 
		 * @param obj	EventDispatcher		Object para remover
		 * @param kind	*					Function or String (Event type)
		 * @return Boolean
		 *
		 * @see removeAll
		 * @see ListenerVO
		 *  
		 * @example
		 * 
		 *	SmartListener.add( bt1, new ListenerVO( MouseEvent.CLICK , click ) , new ListenerVO( MouseEvent.CLICK , doAnotherThing ) );
		 * 
		 *	function click(e:MouseEvent) : void
		 *	{
		 * 		// example 1
		 * 		// Irará remover todos os listeners registrados para o evento de MouseEvent.CLICK
		 * 		// Nesse exemplo 'bt' ficará sem nenhum evento registrado. 
		 * 		SmartListener.remove ( bt1 , MouseEvent.CLICK );
		 * 
		 * 		// example 1
		 * 		// Irará remover todos os listeners registrados para o metodo 'click'. 
		 * 		// Nesse exemplo 'bt1' só terá o listener de new ListenerVO( MouseEvent.CLICK , doAnotherThing ) registrado.
		 * 		SmartListener.remove ( bt1 , click );
		 * 	}
		 * 
		 * 
		 * */
		public static function remove( obj : IEventDispatcher , kind : * ) : Boolean
		{
			init();
			if ( !library[ obj ] )
			{
				return false;
			}
			return removeSpecificListener.apply( SmartListener , [obj].concat( kind ) );
		}
		/**
		 * 
		 * Busca para um determinado 'obj' todas as incidencias com uma
		 * determinada 'kind' e remove aquele listener.
		 * 
		 * 
		 * @param	item		IEventDispatcher	object to register listeners
		 * @param 	kind		*					String for event type or method.
		 * 
		 * */
		private static function removeSpecificListener( obj : IEventDispatcher , kind : * ) : Boolean
		{
			var flag : Boolean = false;
			for(var nEvent : String in library[ obj ] )
			{
				var vo : Listener = library[ obj ][ nEvent ] as Listener;
				if ( kind is String && kind === vo.type )
				{
					flag = true;
					obj.removeEventListener( vo.type, vo.method );
					(library[ obj ] as Array).splice( int(nEvent) , 1 );
				}
				else if ( kind is Function && kind === vo.method )
				{
					flag = true;
					obj.removeEventListener( vo.type, vo.method );
					(library[ obj ] as Array).splice( int(nEvent) , 1 );
				}
			}
			return flag;
		} 
		/**
		 * 
		 * Remove todos os listeners de um objeto.
		 * 
		 * @param 	obj		*			EventDispatcher ou se for um Event o metodo vai tentar usar o Event.currentTarget,
		 * @param	quiet	Boolean		apenas para mostrar (trace) os eventos que foram removidos
		 * @return Boolean
		 * 
		 * @example
		 *  
		 * 	// example 1
		 *	SmartListener.add( bt1, new ListenerVO( MouseEvent.CLICK , click ) );
		 *	function click(e:MouseEvent)
		 *	{
		 * 		// do something else
		 * 		SmartListener.removeAll ( e.currentTarget );
		 * 		// or 
		 * 		SmartListener.removeAll ( sp1 );
		 * 	}
		 * 
		 *	// example 2
		 *	SmartListener.add( bt1, new ListenerVO( MouseEvent.CLICK , SmartListener.removeAll ) );
		 * 
		 *	// example 3
		 *	SmartListener.add( [bt1,bt2] , new ListenerVO( MouseEvent.CLICK , clear ) );
		 * 	function clear()
		 *	{
		 * 		// do something and....
		 * 		SmartListener.removeAll( [bt1,bt2] );
		 *	}
		 * 
		 * */
		public static function removeAll( obj:*, quiet:Boolean = true ) : Boolean
		{
			init();
			var weakObject : EventDispatcher;
			if(obj is Event)
			{
				weakObject = obj.currentTarget;
			}
			else if ( obj is IEventDispatcher )
			{
				weakObject = obj;
			}
			else if ( obj is Array )
			{
				for (var item:String in obj )
				{
					removeAll.apply( SmartListener , [ obj[item] ].concat(quiet) );
				}
				return true;
			}
			else
			{
				trace("SmartListener.removeAll: invalid param type. You must have to use Array, IEventDispatcher or Event  : '"+obj+"'")
				return false;
			}
			if( !library[ weakObject ] ) return false;
			return removeListener( weakObject , quiet )
		}
		/**
		 * 
		 * Remove todos os listener de um obj.
		 * 
		 * @param	obj		IEventDispatcher
		 * @param	quiet	Boolean
		 * @return Boolean
		 * 
		 * */
		private static function removeListener( obj : IEventDispatcher , quiet:Boolean = true ) : Boolean
		{
			if (!quiet) trace("[SmartListeners] removeAll : " + obj );
			for ( var evts : String  in library[ obj ] )
			{
				var vo : Listener = library[ obj ][ evts ] as Listener;
				obj.removeEventListener( vo.type, vo.method );
				if (!quiet) trace(" - removing event: " + vo.type );	
			}
			library[ obj ] = null;
			delete library[ obj ];
			return true;
		}
		/**
		 * 
		 * Agrupa em uma key uma lista de objects que ja foram adicionados.
		 * A ideia de dar um <code>group</code> em uma lista de objects é para facilitar
		 * no momento de remover baseados em um escopo, por exemplo quando vc precisa 
		 * remover uma sessao de um site, se vc agrupar tudo em um lugar é só remover
		 * aquele grupo e todos os listeners serao removidos.
		 * 
		 * @param	key 	*	chave de registro do group.
		 * @param	objects	*	lista de object registrados
		 * @return	Boolean
		 * 
		 * @see	add
		 * @see removeAllByGroup
		 * 
		 * @example
		 * 
		 * SmartListener.add( [bt1,bt2] , new ListenerVO( MouseEvent.MOUSE_OVER , over) );
		 * SmartListener.group( "footer" , bt1 , bt2 );
		 * 
		 *	function over(e:MouseEvent):void
		 *	{
		 * 		SmartListener.removelAllByGroup( "footer" );
		 *	}
		 * 
		 * */
		public static function group ( key: *, ...objects ) : Boolean
		{
			init();
			if ( objects.length == 0 )
			{
				return false;
			}
			var args: Array = ( objects.length > 1 ) ? objects as Array : new Array( objects[ 0 ] );
			if( groups[ key ] )
			{
				groups[ key ] = library[ key ].concat( args );
			}
			else
			{
				groups[ key ] = args; 
			}
			return true;
		}
		/**
		 * 
		 * Remove o listener de todos os objects registrados em uma key.
		 * 
		 * @param	scope	*		key usada para registrar o group
		 * @param	quiete	Boolean	
		 * @return Boolean
		 * 
		 * @see group
		 * 
		 * @example
		 * 
		 * SmartListener.add( [bt1,bt2] , new ListenerVO( MouseEvent.MOUSE_OVER , over) );
		 * SmartListener.group( "footer" , bt1 , bt2 );
		 * 
		 *	function over(e:MouseEvent):void
		 *	{
		 * 		SmartListener.removelAllByGroup( "footer" );
		 *	}
		 * 
		 * */
		public static function removelAllByGroup ( key: *, quiet: Boolean = true  ) : Boolean
		{
			init();
			if ( !groups[ key ] )
			{
				return false;
			}
			if (!quiet ) trace("SmartListener.removelAllByGroup : " , key)
			for (var item:String in groups[ key ] ) 
			{
				var obj : EventDispatcher = groups[ key ][ item ] as EventDispatcher;
				removeAll( obj , quiet );	
			}
			groups [ key ] = null;
			delete groups [ key ];
			return true; 
		}
	}
}