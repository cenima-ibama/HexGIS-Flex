package widgets.componentes.mapa
{
	import mx.controls.Alert;
	
	import org.openscales.core.Map;
	import org.openscales.core.events.LayerEvent;
	import org.openscales.core.layer.Layer;
	
	import widgets.componentes.layerGroup.LayerGroup;
	
	
	public class HexMap extends Map
	{
		private var _layerGroups:Vector.<LayerGroup> = new Vector.<LayerGroup>();
		
		
		public function HexMap(width:Number=600, height:Number=400, projection:*=null)
		{
			super(width, height, projection);
		}
				
		public function addLayerGroup(layerGroup:LayerGroup, redraw:Boolean = true):Boolean 
		{
			if(this._layerGroups.indexOf(layerGroup)!= -1)
				return false;
			
			//this.addChildAt(layer,this._layers.length);
			this._layerGroups.push(layerGroup);
			
			for each (var l:Layer in layerGroup.layers)
			{
				super.addLayer(l, redraw);
			}

			return true;
		}
		
		public function getLayerGroups():Vector.<LayerGroup> 
		{
			return this._layerGroups;
		}
		
		public function getNonGroupLayers():Vector.<Layer>
		{
			var layerArray:Vector.<Layer> = new Vector.<Layer>();
			var i:int = super.layers.length - 1;
			var j:int;
			var s:Layer;
			var estaEmGrupo:Boolean;
			var grpLayers:Vector.<Layer>;
			
			for (i;i>-1;--i) 
			{
				s = super.layers[i];
				
				j = 0;
				estaEmGrupo = false;
				
				while ((j < _layerGroups.length) && (!estaEmGrupo))
				{
					grpLayers = _layerGroups[j].layers;
					if (grpLayers.indexOf(s) != -1)
					{
						estaEmGrupo = true;
					}
					j++;
				}
				
				if(!estaEmGrupo) 
				{
					layerArray.push(s);
				}
			}
			return layerArray.reverse();
		}

		
	}
}