package redneck.events
{
	import redneck.events.BaseEvent;
	import flash.utils.*;
	import flash.events.*;
	public class ServiceEvent extends BaseEvent
	{
		
		public static const ON_START : String = "serviceStart"
		public static const ON_COMPLETE : String = "serviceComplete"
		public static const ON_PROGRESS : String = "serviceProgress"
		public static const ON_ERROR : String = "serviceError"
		public var url : String
		public var bytesLoaded : Number = 0
		public var bytesTotal : Number = 0
		public var _percentLoaded : Number = 0
		public function ServiceEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
		public function get percentLoaded():Number{
			return bytesLoaded/bytesTotal;
		}
		public override function toString( ) : String
		{
			return "( "+getQualifiedClassName(this)+" [ type:'"+type+"' text='"+text+"' url='"+url+"' ])";
		}
		public override function clone():Event{
			var evt : ServiceEvent = new ServiceEvent( this.type, this.bubbles, this.cancelable );
				evt.url = url;
				evt.bytesTotal = bytesTotal;
				evt.bytesLoaded = bytesLoaded;
				evt.text = text;
			return evt;
		}
	}
}