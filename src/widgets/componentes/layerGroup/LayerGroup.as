package widgets.componentes.layerGroup
{
	import org.openscales.core.Map;
	import org.openscales.core.events.LayerEvent;
	import org.openscales.core.layer.Layer;
	import org.openscales.core.layer.originator.DataOriginator;
	import org.openscales.proj4as.ProjProjection;
	
	import spark.components.Group;

	public class LayerGroup
	{
		private var _layers:Vector.<Layer> = new Vector.<Layer>();
		private var _identifier:String;
		private var _displayedName:String;
		private var _visible:Boolean;
		private var _map:Map;
		private var _alpha:Number = 1.0;
		

		public function LayerGroup(identifier:String, map:Map=null, layers:Vector.<Layer>=null)
		{
			if(!identifier || identifier=="")
			{
				this._identifier = "NewLayer_"+new Date().time;
			}
			else 
			{
				this._identifier = identifier;
			}
			
			if (map)
			{
				this.map = map;
			}
			
			this._displayedName = this._identifier;
			this.visible = true;
			
			if (layers)
			{
				for each (var l:Layer in layers)
				{
					addLayer(l);
				}
			}
		}
		
		public function get map():Map
		{
			return this._map;
		}
		
		public function set map(value:Map):void
		{
			if (value)
			{
				this._map = value;
				
				//this._map.removeEventListener(LayerEvent.LAYER_VISIBLE_CHANGED, onLayerVisibilityChange);
			}
		}
		
		/*public function onLayerVisibilityChange(event:LayerEvent):void
		{
			if(this._layers)
			{
				if (this.layers.indexOf(event.layer as Layer)  != -1)
				event.layer = this._layer.visible;
			}
		}*/
		
		public function get layers():Vector.<Layer>
		{
			return this._layers;
		}
		
		public function get identifier():String
		{
			return this._identifier;
		}
		
		public function get displayedName():String
		{
			return this._displayedName;
		}
		
		
		public function get visible():Boolean
		{
			return this._visible;
		}
		public function set visible(value:Boolean):void 
		{
			this._visible = value;
			
			if (this.layers)
			{
				for each (var l:Layer in this.layers)
				{
					l.visible = this.visible;
					l.redraw();
				}
			}
		}
		
		
		public function get alpha():Number
		{
			return this._alpha;
		}
		public function set alpha(value:Number):void 
		{
			this._alpha = value;
			
			if (this.layers)
			{
				for each (var l:Layer in this.layers)
				{
					l.alpha = this.alpha;
				}
			}
		}
		
		
		public function addLayer(layer:Layer):void
		{
			if (layer)
			{
				//layer.groupName = this._identifier;
				layer.visible = this._visible;
				this._layers.push(layer);
			}
		}
	}
}