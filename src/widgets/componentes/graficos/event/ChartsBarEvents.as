package widgets.componentes.graficos.event
{
	import flash.events.Event;
		
	public class ChartsBarEvents extends Event
	{
		
		public static const CHART_ACTIVATED:String="chart_activated";
		public static const CHART_DESACTIVATED:String="chart_desactivated";
		
		public function ChartsBarEvents(type:String, bubbles:Boolean = false, cancelable:Boolean = false)
		{
			super(type, bubbles, cancelable);
		}
	}
}
