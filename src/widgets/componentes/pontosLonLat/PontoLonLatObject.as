package widgets.componentes.pontosLonLat
{
	import org.openscales.core.feature.Feature;

	public class PontoLonLatObject extends Object
	{
		[Bindable]
		public var _coord:String;
		
		[Bindable]
		public var _point:Feature;
		
		/*[Bindable]
		public var label:Feature;*/
		
		public function PontoLonLatObject()
		{
			super();
		}
		
		public function get coord():String
		{
			return this._coord;
		}
		
		public function set coord(value:String):void
		{
			if (value)
			{
				this._coord = value;
			}
		}
		
		public function get point():Feature
		{
			return this._point;
		}
		
		public function set point(value:Feature):void
		{
			if (value)
			{
				this._point = value;
			}
		}
	}
}