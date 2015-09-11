package widgets.componentes.informacoes.drag.event
{
	
	import org.openscales.core.events.OpenScalesEvent;
	import org.openscales.geometry.basetypes.Bounds;
	
	public class TotalRegistrosEvent extends OpenScalesEvent
	{
		
		private var _total:int;
		
		/**
		 * Event type dispatched when the box is drawn.
		 */
		public static const TOTAL_REGISTROS:String="totalregistros";
		
		public function TotalRegistrosEvent(type:String, total:int, bubbles:Boolean = false, cancelable:Boolean = false)
		{
			this._total = total;
			super(type, bubbles, cancelable);
		}
		
		public function get total():int{
			return this._total;
		}
		
		public function set bounds(value:int):void {
			this._total = value;	
		}
	}
}