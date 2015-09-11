package widgets.componentes.webService
{
	public class UpdateWSLineObject extends Object
	{
		private var _fid:String;
		private var _shape:String;
		private var _length:Number;
		private var _tipo_geo:String;
		private var _index:int;
		
		public function UpdateWSLineObject(obj_id:String, shape:String, length:Number, tipo_geo:String, index:int)
		{
			super();
			
			this._fid = obj_id;
			this._shape = shape;
			this._length = length;
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
		
		public function get length():Number
		{
			return this._length;
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