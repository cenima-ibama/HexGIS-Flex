package widgets.componentes.informacoes.drag.event
{
	
	import org.openscales.core.events.OpenScalesEvent;
	import org.openscales.geometry.basetypes.Pixel;
	
	public class GetFeatureEvent extends OpenScalesEvent
	{
		
		/**
		 * Data returned by the WFSGetFeature request
		 */
		private var _data:Object = null;
		
		private var _layerName:String = null;
		
		private var _center:Pixel = null;
		
		public static const GET_FEATURE_DATA:String="openscales.getfeaturedata";
		
		public function GetFeatureEvent(type:String, data:Object, layerName:String, center:Pixel, bubbles:Boolean = false, cancelable:Boolean = false)
		{
			this._data = data;
			this._layerName = layerName;
			this._center = center;
			super(type, bubbles, cancelable);
		}
		
		public function get data():Object {
			return this._data;
		}
		
		public function set data(data:Object):void {
			this._data = data;	
		}
		
		public function get layerName():String {
			return this._layerName;
		}
		
		public function set layerName(value:String):void {
			this._layerName= value;	
		}
		
		public function get center():Pixel {
			return this._center;
		}
		
		public function set center(value:Pixel):void {
			this._center = value;	
		}
	}
}