package widgets.componentes.ibama.event
{
	import flash.events.Event;
	
	import org.openscales.core.feature.Feature;

	public class EditingDisabledEvent extends Event
	{
		public static const ATTRIBUTES_EDITING_DISABLED:String="attreditingdisabled";
		private var _feature:Feature;
		
		public function EditingDisabledEvent(type:String, feat:Feature, bubbles:Boolean = false, cancelable:Boolean = false)
		{
			super(type, bubbles, cancelable);
			this.feature = feat;
		}
		
		public function get feature():Feature
		{
			return this._feature;
		}	
		public function set feature(value:Feature):void
		{
			this._feature = value;
		}
	}
}