package widgets.componentes.webService
{
	public class UpdateWSPointObject extends Object
	{
		private var _fid:String;
		private var _shape:String;
		private var _x:Number;
		private var _y:Number;
		private var _tipo_geo:String;
		private var _index:int;
		
		public function UpdateWSPointObject(obj_id:String, shape:String, x:Number, y:Number, tipo_geo:String, index:int)
		{
			super();
			
			this._fid = obj_id;
			this._shape = shape;
			this._x = x;
			this._y = y;
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
		
		public function get x():Number
		{
			return this._x;
		}
		
		public function get y():Number
		{
			return this._y;
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