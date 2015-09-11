package widgets.componentes.webService
{
	public class WSLinesObject extends Object
	{
		private var _shape:String;
		private var _length:Number;
		private var _tipo_geo:String;
		private var _index:int;
		private var _attributes:Object;
		
		
		public function WSLinesObject(shape:String, attr:Object, length:Number, tipo_geo:String, index:int)
		{
			super();
			
			this._shape = shape;
			this._length = length;
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