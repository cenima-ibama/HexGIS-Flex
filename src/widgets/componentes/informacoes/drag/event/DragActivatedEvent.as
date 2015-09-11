package widgets.componentes.informacoes.drag.event
{
	import org.openscales.core.events.OpenScalesEvent;
	
	public class DragActivatedEvent extends OpenScalesEvent
	{
		public static const INFO_DRAG_ATIVADO:String="infodragativado";
		
		public function DragActivatedEvent(type:String, bubbles:Boolean = false, cancelable:Boolean = false)
		{
			super(type, bubbles, cancelable);
		}
	}
}