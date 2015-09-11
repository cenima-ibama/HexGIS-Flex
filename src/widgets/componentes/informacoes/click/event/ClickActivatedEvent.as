package widgets.componentes.informacoes.click.event
{
	import flash.events.Event;

	public class ClickActivatedEvent  extends Event
	{
		public static const INFO_CLICK_ATIVADO:String="infoclickativado";
		
		public function ClickActivatedEvent(type:String, bubbles:Boolean = false, cancelable:Boolean = false)
		{
			super(type, bubbles, cancelable);
		}
	}
}