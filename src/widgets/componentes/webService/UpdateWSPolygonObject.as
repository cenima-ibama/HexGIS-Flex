package widgets.componentes.webService
{
	public class UpdateWSPolygonObject
	{
		private var _fid:String;
		private var _shape:String;
		private var _area_ha:Number;
		private var _tipo_geo:String;
		private var _index:int;
		
		public function UpdateWSPolygonObject(obj_id:String, shape:String, area_ha:Number, tipo_geo:String, index:int)
		{
			super();
			
			this._fid = obj_id;
			this._shape = shape;
			this._area_ha = area_ha;
			this._tipo_geo = tipo_geo;
			this._index = index;
		}
		
		public function get fid():String
		{
			return this._fid;
		}
		
		public function get shape():String
		{
			return this._shape;
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