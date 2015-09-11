package widgets.componentes.seguranca.event
{
	import flash.events.Event;
	
	import widgets.componentes.seguranca.UserObject;

	public class LoginEvent extends Event
	{
		public static const LOGGED_IN:String = "loggedin";
		
		private var _login:UserObject;
		
		
		public function LoginEvent(type:String, l:UserObject=null, bubbles:Boolean = false, cancelable:Boolean = false)
		{
			this.login = l;
			super(type, bubbles, cancelable);
		}
		
		public function get login():UserObject
		{
			return this._login;
		}
		
		public function set login(value:UserObject):void
		{
			this._login = value;
		}
	}
}