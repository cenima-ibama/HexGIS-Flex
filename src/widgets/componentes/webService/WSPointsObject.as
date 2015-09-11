package widgets.componentes.webService
{
	public class WSPointsObject extends Object
	{
		private var _shape:String;
		private var _x:Number;
		private var _y:Number;
		private var _tipo_geo:String;
		private var _index:int;
		private var _attributes:Object;
		
		
		public function WSPointsObject(shape:String, attr:Object, x:Number, y:Number, tipo_geo:String, index:int)
		{
			super();
						
			this._shape = shape;
			this._x = x;
			this._y = y;
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