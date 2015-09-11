package widgets.componentes.webService
{
	public class UpdateWayPointsAttributesObject extends Object
	{
		private var _id:String;
		private var _shape:String;
		private var _tipo_geo:String;
		private var _index:int;
		
		public function UpdateWayPointsAttributesObject(obj_id:String, shape:String, tipo_geo:String, index:int)
		{
			super();
			this._id = obj_id;
			this._shape = shape;
			this._tipo_geo = tipo_geo;
		}
		
		public function get id():String
		{
			return this._id;
		}
		
		public function get tipo_geo():String
		{
			return this._tipo_geo;
		}
		
		public function get shape():String
		{
			return this._shape;
		}
		
		public function get index():int
		{
			return this._index;
		}
	}
}