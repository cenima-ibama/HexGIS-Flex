package widgets.componentes.seguranca.event
{
	import flash.events.Event;

	public class LogoutEvent extends Event
	{
		public static const LOGOUT:String = "logout";
		
		public function LogoutEvent(type:String, bubbles:Boolean = false, cancelable:Boolean = false)
		{
			super(type, bubbles, cancelable);
		}
	}
}