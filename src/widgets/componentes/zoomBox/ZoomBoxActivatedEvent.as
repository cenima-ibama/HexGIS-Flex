package widgets.componentes.zoomBox
{
	import org.openscales.core.events.OpenScalesEvent;

	public class ZoomBoxActivatedEvent extends OpenScalesEvent
	{
		public static const ZOOMBOX_SELECIONADO:String="zoomboxativado";
		
		public function ZoomBoxActivatedEvent(type:String, bubbles:Boolean = false, cancelable:Boolean = false)
		{
			super(type, bubbles, cancelable);
		}
	}
}