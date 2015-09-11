package widgets.componentes.webService
{
	public class DeleteFeatureObject extends Object
	{
		private var _fid:String;
		private var _tipo_geo:String;
		private var _index:int;
		
		public function DeleteFeatureObject(obj_id:String, tipo_geo:String, index:int)
		{
			super();
			
			this._fid = obj_id;
			this._tipo_geo = tipo_geo;
		}
		
		
		public function get fid():String
		{
			return this._fid;
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