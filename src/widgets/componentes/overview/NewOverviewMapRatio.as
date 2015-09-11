package widgets.componentes.overview
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Shape;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import mx.controls.Alert;
	import mx.controls.Image;
	
	import org.openscales.core.Map;
	import org.openscales.core.basetypes.Resolution;
	import org.openscales.core.control.Control;
	import org.openscales.core.events.LayerEvent;
	import org.openscales.core.events.MapEvent;
	import org.openscales.core.layer.Layer;
	import org.openscales.geometry.basetypes.Location;
	import org.openscales.geometry.basetypes.Pixel;
	import org.openscales.geometry.basetypes.Size;
	import org.openscales.proj4as.ProjProjection;
	
	/**
	 * Display an overview linked with the map.
	 * The map and the overview resolutions are linked with a ratio.
	 * This ratio will be kept when you zoom on the map.
	 * The overview map is a single layer
	 * 
	 * @author Viry Maxime
	 * 
	 */	
	public class NewOverviewMapRatio extends Control
	{
		
		/**
		 * @private
		 * Current map of the overvew
		 */
		private var _overviewMap:Map;
		
		/**
		 * @private
		 * Ratio between the overview resolution and the map resolution
		 * The ratio is MapResolution/OverviewMapResolution
		 */
		private var _ratio:Number = 1;
		
		/**
		 * @private
		 * Icon that will be displayed at the center of the overview map
		 * to show the location
		 */
		private var _centerIcon:Class = null;
		
		/**
		 * @private
		 * Shape that will be displayed at the center of the overview map
		 * to show the location if no icon is given
		 */
		private var _centerPoint:Shape;
		
		private var _esvaziarLista:Boolean = false;
		
		/**
		 * Constructor of the overview map
		 * 
		 * @param position Position of the overview map
		 * 
		 */
		public function NewOverviewMapRatio(position:Pixel = null, layer:Layer = null)
		{
			super(position);
			this._overviewMap = new Map();
			this._overviewMap.projection = new ProjProjection("EPSG:900913");
			//this._overviewMap.size = new Size(180, 180);
			this.layer = layer;
			addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
		}
				
		/**
		 * @private
		 * Icon that will be displayed at the center of the overview map
		 * to show the location
		 */
		public function get centerIcon():Class
		{
			return _centerIcon;
		}
		
		/**
		 * @private
		 */
		public function set centerIcon(value:Class):void
		{
			_centerIcon = value;
		}
		
		/**
		 * @private
		 * Draw the overview map when added to the map 
		 */
		private function onAddedToStage(event:Event):void
		{
			removeEventListener(Event.ADDED_TO_STAGE,onAddedToStage);
			this.mapChanged();
			this.draw();
		}
		
		/**
		 * Draw the overview map
		 */
		public override function draw():void 
		{
			this.addChild(this._overviewMap);
		}
		
		/**
		 * Draw the center point
		 */
		private function drawCenter():void
		{
			if (this._centerIcon) 
			{
				// Use icon
				if (this._centerPoint)
				{
					this._overviewMap.removeChild(this._centerPoint);
					this._centerPoint = null;
				}
				var bitmap:Bitmap = new _centerIcon;
				bitmap.x = this.width/2 - bitmap.width/2;
				bitmap.y = this.height/2 - bitmap.height/2;
				this._overviewMap.addChild(bitmap);
			}
			else 
			{
				// Draw cross shape
				if (this._centerPoint == null)
				{
					_centerPoint = new Shape();
				}
				_centerPoint.graphics.clear();
				_centerPoint.graphics.lineStyle(1, 0xFF0000);
				_centerPoint.graphics.moveTo(this.width/2 - 5, this.height/2);
				_centerPoint.graphics.lineTo(this.width/2 + 5, this.height/2);
				_centerPoint.graphics.moveTo(this.width/2, this.height/2 - 5);
				_centerPoint.graphics.lineTo(this.width/2, this.height/2 + 5);
				this._overviewMap.addChild(_centerPoint);
			}
		}
		
		/**
		 * The size of the overview map
		 */
		public function set size(value:Size):void 
		{
			if(!value)
				return;
			this._overviewMap.size = value;
			//mapChanged();
		}
		
		/**
		 * The map used to compute the ratio
		 * It may be the main map of the application
		 */
		public override function get map():Map
		{
			return super.map;
		}
		public override function set map(value:Map):void
		{
			if (value)
			{
				if (this.map)
				{
					this.map.removeEventListener(MapEvent.CENTER_CHANGED, mapChanged);
					this.map.removeEventListener(MapEvent.PROJECTION_CHANGED, mapChanged);
					this.map.removeEventListener(MapEvent.RESOLUTION_CHANGED, mapChanged);
					this.map.removeEventListener(MapEvent.RESIZE, mapChanged);
					this.map.removeEventListener(MapEvent.MAP_LOADED, mapChanged);
					this._overviewMap.removeEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
					
					this.map.removeEventListener(LayerEvent.LAYER_VISIBLE_CHANGED, setVisibility);
					//this.map.addEventListener(LayerEvent.LAYER_ADDED, esvaziaListaCamadas);
					this.map.removeEventListener(LayerEvent.LAYER_REMOVED, esvaziaListaCamadas);
				}
				
				super.map = value;
				
				if (this.map)
				{	
					this.map.addEventListener(MapEvent.CENTER_CHANGED, mapChanged);
					this.map.addEventListener(MapEvent.PROJECTION_CHANGED, mapChanged);
					this.map.addEventListener(MapEvent.RESOLUTION_CHANGED, mapChanged);
					this.map.addEventListener(MapEvent.RESIZE, mapChanged);
					this.map.addEventListener(MapEvent.MAP_LOADED, mapChanged);
					this.map.addEventListener(LayerEvent.LAYER_VISIBLE_CHANGED, setVisibility);
					//this.map.addEventListener(LayerEvent.LAYER_ADDED, esvaziaListaCamadas);
					this.map.addEventListener(LayerEvent.LAYER_REMOVED, esvaziaListaCamadas);
					
					this._overviewMap.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown,true);
					this._overviewMap.maxExtent = this._map.maxExtent.preciseReprojectBounds(this.overviewMap.projection);
					this._overviewMap.backTileColor = this._map.backTileColor;
					this.mapChanged();
				}
			}
		}
		/**
		 * @private
		 * Callback to recompute the zoom level of the overview when the zoom level of the map
		 * has changed 
		 */
		private function mapChanged(event:Event = null):void
		{
			//computeResolutionLevel();
			if (this.map != null)
			{
				this._overviewMap.center = this.map.center.reprojectTo(this._overviewMap.projection);
				var mapRes:Resolution = this._map.resolution;
				mapRes = mapRes.reprojectTo(this.overviewMap.projection);
				var mapsRatio:Number =(this.map.size.w / this._overviewMap.size.w); 
				var newRes:Resolution =  new Resolution(mapRes.value*ratio*mapsRatio, mapRes.projection);
				if (newRes.value > this._overviewMap.maxResolution.value)
				{
					newRes = this._overviewMap.maxResolution;
				}
				if (newRes.value < this._overviewMap.minResolution.value)
				{
					newRes = this._overviewMap.minResolution;
				}
				this._overviewMap.resolution = newRes
			}
			this.drawCenter();	
		}
		
		/**
		 * @private
		 * Callback to change the center of the general map when clicking on the minimap
		 * If the new center is out of the max extend of the base map the overview map center is not
		 * changed
		 */
		private function onMouseDown(event:MouseEvent):void 
		{
			var mousePosition:Pixel =  new Pixel(this._overviewMap.mouseX, this._overviewMap.mouseY);
			var newCenter:Location = this._overviewMap.getLocationFromMapPx(mousePosition);
			var oldCenter:Location = this._overviewMap.center;
			
			var newMapCenter:Location = newCenter.reprojectTo(this.map.projection);	
			
			this.map.center = newMapCenter;
			//If the new center is valid change the center of the overview
			if (this.map.center == newMapCenter)
			{
				this._overviewMap.center = newCenter;
			}
		}
		
		//public function setVisibility(identifier:String, visibility:Boolean):void
		private function setVisibility(event:LayerEvent):void
		{
			var auxLayer:Layer = _overviewMap.getLayerByIdentifier("overview_"+event.layer.identifier);
			
			if (auxLayer != null)
			{
				auxLayer.visible = event.layer.visible;
				//mx.controls.Alert.show("encontrado: "+auxLayer.identifier);
			}
		}
		
		private function esvaziaListaCamadas(event:LayerEvent):void
		{
			_esvaziarLista = true;
		}
		
		
		/**
		 * The curent layer of the overview map
		 * 
		 * @param layer The layer of the overview
		 * 
		 */
		public function set layer(layer:Layer):void
		{
			if (_esvaziarLista)
			{
				_overviewMap.removeAllLayers();
				_esvaziarLista = false;
			}
			
			if (layer != null)
			{
				//mx.controls.Alert.show("gravado: "+layer.identifier);
				_overviewMap.addLayer(layer, true);
				//Alert.show(_overviewMap.layers.length.toString());
			}
		}
		
		/**
		 * 
		 * @private
		 */
		public function get layer():Layer
		{
			return _overviewMap.layers[0];
		}
		
		/**
		 * Ratio between the overview resolution and the map resolution
		 * The ratio is MapResolution/OverviewMapResolution
		 * While setting a new ratio the oveview zoom level will be recomputed
		 * 
		 * @param ratio The curent ratio between the overview map and the map
		 */
		public function set ratio(ratio:Number):void
		{
			this._ratio = ratio;
			//this.mapChanged();
		}
		
		/**
		 * 
		 * @private
		 */
		public function get ratio():Number
		{
			return _ratio;
		}
		
		/**
		 * The overview map resolution
		 */
		public function get resolution():Resolution
		{
			return _overviewMap.resolution;
		}
		
		/**
		 * The overview map
		 */
		public function get overviewMap():Map
		{
			return _overviewMap;
		}
		
		override public function set width(value:Number):void{
			_overviewMap.size = new Size(value, _overviewMap.size.h);
			//mapChanged();
		}
		
		override public function get width():Number{
			return _overviewMap.size.w;
		}
		
		override public function set height(value:Number):void{
			_overviewMap.size = new Size(_overviewMap.size.w, value);
			//mapChanged();
		}
		
		override public function get height():Number{
			return _overviewMap.size.h;
		}
		
		/**
		 * The actual projection of the map. The default value is Geometry.DEFAULT_SRS_CODE
		 */
		public function set projection(value:*):void
		{
			this._overviewMap.projection = value;
		}
		
		/**
		 * @public
		 */
		public function get projection():ProjProjection
		{
			return this._overviewMap.projection;
		}
		
		/**
		 * The actual maxResolution of the overview map
		 */
		public function get maxResolution():Resolution
		{
			return this._overviewMap.maxResolution;
		}
		
		/**
		 * @private
		 */
		public function set maxResolution(value:Resolution):void
		{
			this._overviewMap.maxResolution = value;
		}
		
		/**
		 * The actual minResolution of the overview map
		 */
		public function get minResolution():Resolution
		{
			return this._overviewMap.minResolution;
		}
		
		/**
		 * @private
		 */
		public function set minResolution(value:Resolution):void
		{
			this._overviewMap.minResolution = value;
		}
	}
}