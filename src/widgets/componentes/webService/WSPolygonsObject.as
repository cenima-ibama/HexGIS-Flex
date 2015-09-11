package widgets.componentes.webService
{
	import org.openscales.core.feature.PolygonFeature;
	
	import widgets.componentes.ibama.feature.IbamaPolygonFeature;

	public class WSPolygonsObject extends Object
	{
		private var _shape:String;
		private var _area_ha:Number;
		private var _tipo_geo:String;
		private var _index:int;
		private var _attributes:Object;
		
		
		public function WSPolygonsObject(shape:String, attr:Object, area_ha:Number, tipo_geo:String, index:int)
		{
			super();
			
			this._shape = shape;
			this._area_ha = area_ha;
			this._tipo_geo = tipo_geo;
			this._index = index;		
			this._attributes = attr;
		}
		
		public function get shape():String
		{
			return this._shape;
		}
		
		public function get attributes():Object
		{
			return this._attributes;
		}
		
		public function get area_ha():Number
		{
			return this._area_ha;
		}
		
		public function get tipo_geo():String
		{
			return this._tipo_geo;
		}
		
		public function get index():int
		{
			return this._index;
		}
	}
}