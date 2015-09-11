package widgets.componentes.seguranca
{
	import flash.display.DisplayObject;
	import flash.events.MouseEvent;
	import flash.net.URLRequest;
	import flash.net.navigateToURL;
	
	import mx.core.FlexGlobals;
	import mx.managers.PopUpManager;
	
	import spark.components.Button;
	
	import widgets.componentes.seguranca.event.LoginEvent;
	
	
	public class LoginButton extends Button
	{
		private var formLogin:LoginWindow;
		
		public function LoginButton()
		{
			super();

			this.addEventListener(MouseEvent.CLICK, showLoginWindow);
		}
		
		private function showLoginWindow(event:MouseEvent):void
		{				
			formLogin = PopUpManager.createPopUp(FlexGlobals.topLevelApplication as DisplayObject, LoginWindow, true) as LoginWindow;
			formLogin.addEventListener(LoginEvent.LOGGED_IN, loginResult);
			PopUpManager.centerPopUp(formLogin);
		}
		
		private function loginResult(event:LoginEvent):void
		{
			navigateToURL(new URLRequest(FlexGlobals.topLevelApplication.url), "_self");
		}
	}
}