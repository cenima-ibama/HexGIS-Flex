package widgets.componentes.vetorizar.desenhar.handler
{
	import flash.events.Event;
	
	import org.openscales.core.Map;
	import org.openscales.core.events.FeatureEvent;
	import org.openscales.core.events.MapEvent;
	import org.openscales.core.feature.Feature;
	import org.openscales.core.feature.MultiPointFeature;
	import org.openscales.core.feature.PointFeature;
	import org.openscales.core.handler.feature.draw.AbstractDrawHandler;
	import org.openscales.core.layer.VectorLayer;
	import org.openscales.core.style.Style;
	import org.openscales.geometry.MultiPoint;
	import org.openscales.geometry.Point;
	import org.openscales.geometry.basetypes.Location;
	import org.openscales.geometry.basetypes.Pixel;
	import org.openscales.proj4as.ProjProjection;
	
	import solutions.SiteContainer;
	
	import widgets.VetorizarWidget;
	import widgets.componentes.ibama.feature.IbamaPointFeature;
	
	
	/** 
	 * @eventType org.openscales.core.events.FeatureEvent.FEATURE_DRAWING_END
	 */ 
	[Event(name="org.openscales.feature.drawingend", type="org.openscales.core.events.FeatureEvent")]
	
	/**
	 * Handler to draw points.
	 */
	public class NewDrawPointHandler extends AbstractDrawHandler
	{
		
		/**
		 * The layer in which we'll draw
		 */
		private var _drawLayer:VectorLayer = null;
		
		/**
		 * Single ID for point
		 */		
		private var id:Number = 0;
		
		/**
		 * 
		 */
		private var _style:Style = Style.getDefaultPointStyle();
		
		//private var wayPts:String = "";
		
		[Bindable]
		private var _widget:VetorizarWidget;
				
		
		public function get widget():VetorizarWidget
		{
			return this._widget;
		}
		
		public function set widget(value:VetorizarWidget):void
		{
			this._widget = value;
		}
		
		public function NewDrawPointHandler(map:Map=null, active:Boolean=false, drawLayer:org.openscales.core.layer.VectorLayer=null)
		{
			super(map, active, drawLayer);
		}
		
		override protected function registerListeners():void
		{
			if (this.map) 
			{
				this.map.addEventListener(MapEvent.MOUSE_CLICK, this.drawPoint);
			}
		}
		
		override protected function unregisterListeners():void
		{
			if (this.map)
			{
				this.map.removeEventListener(MapEvent.MOUSE_CLICK, this.drawPoint);
			}
		}
		
		/**
		 * Create a point and draw it
		 */		
		protected function drawPoint(event:Event):void 
		{
			//We draw the point
			if (drawLayer != null)
			{
				drawLayer.scaleX = 1;
				drawLayer.scaleY = 1;
				
				if (this.widget)
				{
					this.style = this.widget.getPointStyle();
				}

				var pixel:Pixel = new Pixel(this.map.mouseX,this.map.mouseY );
				var lonlat:Location = this.map.getLocationFromMapPx(pixel); //this.map.getLocationFromLayerPx(pixel);
				var feature:Feature;
				
				//todo change this bad way
				if(drawLayer.geometryType == "org.openscales.geometry::MultiPoint")
				{
					var multiPoint:MultiPoint = new MultiPoint();
					multiPoint.projection = this.map.projection;
					multiPoint.addPoint(lonlat.lon,lonlat.lat);
					feature = new MultiPointFeature(multiPoint, null, this._style);
					feature.name = "point." + drawLayer.idPoint.toString();
					drawLayer.idPoint++;
					drawLayer.addFeature(feature);
					//must be after adding map
					feature.draw();
					
				}
				else
				{
					var point:Point = new Point(lonlat.lon,lonlat.lat);
					point.projection = this.map.projection;
					feature = new IbamaPointFeature(point, null, this._style);
					//feature = new PointFeature(point, null, this._style);
					feature.name = "point." + drawLayer.idPoint.toString();
					
					if (widget.configData.userData != null)
					{
						(feature as IbamaPointFeature).login_user = widget.configData.userData.cpf;
					}
					
					drawLayer.idPoint++;
					drawLayer.addFeature(feature);
					//must be after adding map
					feature.draw();
				}
				
				var loc:Location = new Location(lonlat.x, lonlat.y, this.map.projection);
				loc = loc.reprojectTo(new ProjProjection("EPSG:4326"));
				
				//wayPts = loc.lon.toString() + " " + loc.lat.toString();
							
				this.map.dispatchEvent(new FeatureEvent(FeatureEvent.FEATURE_DRAWING_END,feature));
			}
		}

		/**
		 * The style of the point
		 */
		public function get style():Style
		{
			return this._style;
		}
		public function set style(value:Style):void
		{
			this._style = value;
		}
	}
}

