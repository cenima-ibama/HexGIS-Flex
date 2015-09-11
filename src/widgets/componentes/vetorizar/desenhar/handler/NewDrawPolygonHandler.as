package widgets.componentes.vetorizar.desenhar.handler
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import mx.controls.Alert;
	
	import org.openscales.core.Map;
	import org.openscales.core.events.FeatureEvent;
	import org.openscales.core.events.MapEvent;
	import org.openscales.core.feature.PointFeature;
	import org.openscales.core.handler.feature.draw.AbstractDrawHandler;
	import org.openscales.core.handler.mouse.ClickHandler;
	import org.openscales.core.layer.VectorLayer;
	import org.openscales.core.style.Style;
	import org.openscales.geometry.Geometry;
	import org.openscales.geometry.LinearRing;
	import org.openscales.geometry.Point;
	import org.openscales.geometry.Polygon;
	import org.openscales.geometry.basetypes.Location;
	import org.openscales.geometry.basetypes.Pixel;
	
	import widgets.VetorizarWidget;
	import widgets.componentes.ibama.feature.IbamaPolygonFeature;
	
	
	/** 
	 * @eventType org.openscales.core.events.FeatureEvent.FEATURE_DRAWING_END
	 */ 
	[Event(name="org.openscales.feature.drawingend", type="org.openscales.core.events.FeatureEvent")]
	
	/**
	 * This handler manage the function draw of the polygon.
	 * Active this handler to draw a polygon.
	 */
	public class NewDrawPolygonHandler extends AbstractDrawHandler
	{
		/**
		 * polygon feature which is currently drawn
		 * */
		
		protected var _IbamaPolygonFeature:IbamaPolygonFeature = null;
		
		/**
		 * @private
		 **/
		
		private var _firstPointFeature:PointFeature=null;
		
		/**
		 *  @private 
		 * */
		private var _newFeature:Boolean = true;
		
		/**
		 *@private
		 */
		private var _dblClickHandler:ClickHandler = new ClickHandler();
		
		/**
		 * As we draw a first point to know where we started the polygon
		 */
		private var _firstPointRemoved:Boolean = false;
		
		/**
		 * Single id of the polygon
		 */
		private var id:Number = 0;
		
		/**
		 * The Sprite used for drawing the temporary line
		 */
		private var _drawContainer:Sprite = new Sprite();
		/**
		 * position of the first point drawn
		 * */
		private var _firstPointLocation:Location=null;
		/**
		 * position of the last point drawn
		 * */
		private var _lastPointLocation:Location=null;
		
		/**
		 * The last point of the polygon. 
		 */
		private var _lastPoint:Point = null; 
		/**
		 * 
		 */
		private var _style:Style = Style.getDefaultSurfaceStyle();
		
		[Bindable]
		private var _widget:VetorizarWidget;
		
		/**
		 * Constructor of the polygon handler
		 * 
		 * @param map the map reference
		 * @param active determine if the handler is active or not
		 * @param drawLayer The layer on which we'll draw
		 */
		public function NewDrawPolygonHandler(map:Map=null, active:Boolean=false, drawLayer:org.openscales.core.layer.VectorLayer=null)
		{
			super(map, active, drawLayer);
		}
		
		
		override protected function registerListeners():void
		{
			this._dblClickHandler.active = true;
			this._dblClickHandler.doubleClick = this.mouseDblClick;
			if (this.map) 
			{
				this.map.addEventListener(MapEvent.MOUSE_CLICK, this.mouseClick);	
			}
		}
		
		override protected function unregisterListeners():void
		{
			this._dblClickHandler.active = false;
			if (this.map)
			{
				this.map.removeEventListener(MapEvent.MOUSE_CLICK, this.mouseClick);
			}
		}
		
		public function get widget():VetorizarWidget
		{
			return this._widget;
		}
		
		public function set widget(value:VetorizarWidget):void
		{
			this._widget = value;
		}
		
		protected function mouseClick(event:MapEvent):void 
		{
			if (drawLayer != null)
			{
				drawLayer.scaleX=1;
				drawLayer.scaleY=1;
				
				if (this.widget)
				{
					this.style = this.widget.getPolygonStyle();
				}
				
				_drawContainer.graphics.clear();
				//we determine the point where the user clicked
				var pixel:Pixel = new Pixel(map.mouseX ,map.mouseY);
				
				//this._lastPointPixel= new Pixel(map.mouseX ,map.mouseY);
				var lonlat:Location = this.map.getLocationFromMapPx(pixel);
				this._lastPointLocation = lonlat;
				var point:Point = new Point(lonlat.lon,lonlat.lat);
				var lring:LinearRing=null;
				var polygon:Polygon=null;
				
				//2 cases, and very different. If the user starts the polygon or if the user is drawing the polygon
				if(newFeature) 
				{
					var name:String = "polygon." + drawLayer.idPolygon.toString();
					drawLayer.idPolygon++;
					lring = new LinearRing(new <Number>[point.x,point.y]);
					lring.projection = this.map.projection;
					polygon = new Polygon(new <Geometry>[lring]);
					polygon.projection = this.map.projection;
					//this._firstPointPixel= new Pixel(map.mouseX ,map.mouseY);
					this._firstPointLocation = this.map.getLocationFromMapPx(new Pixel(map.mouseX ,map.mouseY));
					lastPoint = point;
					
					this._IbamaPolygonFeature = new IbamaPolygonFeature(polygon, null, null, true);
					this._IbamaPolygonFeature.name = name;
					
					//this._IbamaPolygonFeature=new IbamaPolygonFeature(				
					this._IbamaPolygonFeature.style = this.style;
					
					// We create a point the first time to see were the user clicked
					this._firstPointFeature=  new PointFeature(point, null, this.style);
					
					//add the point feature to the drawLayer, and the polygon (which contains only one point for the moment)
					drawLayer.addFeature(this._IbamaPolygonFeature);
					
					//Alert.show(widget.configData.userData.cpf);
					if (widget.configData.userData != null)
					{
						(_IbamaPolygonFeature as IbamaPolygonFeature).login_user = widget.configData.userData.cpf;
					}
					
					this._IbamaPolygonFeature.unregisterListeners();
					this._firstPointFeature.unregisterListeners();
					
					newFeature = false;
					
					this.map.addEventListener(MouseEvent.MOUSE_MOVE,drawTemporaryPolygon);
					this.map.addEventListener(MapEvent.CENTER_CHANGED, drawTemporaryPolygon);
					this.map.addEventListener(MapEvent.RESOLUTION_CHANGED, drawTemporaryPolygon);
				}
				else if(!point.equals(lastPoint))
				{
					if(this._firstPointFeature!=null)
					{
						drawLayer.removeFeature(this._firstPointFeature);
						this._firstPointFeature=null;
					}
					//add the point to the linearRing
					lring = (this._IbamaPolygonFeature.geometry as Polygon).componentByIndex(0) as LinearRing;
					lring.addPoint(point.x,point.y);
					lastPoint = point;
				}
				//final redraw layer
				drawLayer.redraw(true);
				
			}		
		}
		
		public function mouseDblClick(LastPX:Pixel = null):void 
		{
			drawFinalPoly();
		}
		
		
		public function drawTemporaryPolygon(event:Event=null):void
		{
			//position of the last point drawn
			_drawContainer.graphics.clear();
			_drawContainer.graphics.beginFill(0x00ff00,0.5);
			_drawContainer.graphics.lineStyle(2, 0x00ff00);		
			_drawContainer.graphics.moveTo(map.mouseX, map.mouseY);
			_drawContainer.graphics.lineTo(this.map.getMapPxFromLocation(this._firstPointLocation).x, this.map.getMapPxFromLocation(this._firstPointLocation).y);
			_drawContainer.graphics.moveTo(map.mouseX, map.mouseY);
			_drawContainer.graphics.lineTo(this.map.getMapPxFromLocation(this._lastPointLocation).x, this.map.getMapPxFromLocation(this._lastPointLocation).y);	
			_drawContainer.graphics.endFill();
		}
		/**
		 * Finish the polygon
		 */
		public function drawFinalPoly():void
		{
			//Change style of finished polygon
			//var style:Style = Style.getDefaultSurfaceStyle();
			//var style:Style = Style.getDefinedSurfaceStyle(0x00FFFF,0.2);
			_drawContainer.graphics.clear();
			//We finalize the last feature (of course, it's a polygon)
			//var feature:Feature = drawLayer.features[drawLayer.features.length - 1];
			
			if (this._IbamaPolygonFeature != null)
			{
				//the user just drew one point, it's not a real polygon so we delete it 
				
				(drawLayer as VectorLayer).removeFeature(this._firstPointFeature);
				//Check if the polygon (in fact, the linearRing) contains at least 3 points (if not, it's not a polygon)
				if ((this._IbamaPolygonFeature.polygon.componentByIndex(0) as LinearRing).componentsLength>2)
				{
					//Apply the "finished" style
					this._IbamaPolygonFeature.style = this._style;
					this._IbamaPolygonFeature.registerListeners();	
					this.map.dispatchEvent(new FeatureEvent(FeatureEvent.FEATURE_DRAWING_END,this._IbamaPolygonFeature));
				}
				else
				{
					drawLayer.removeFeature(this._IbamaPolygonFeature);
				}
				
				drawLayer.redraw(true);
			}
			//the polygon is finished
			newFeature = true;
			//remove listener for temporaries polygons
			this.map.removeEventListener(MouseEvent.MOUSE_MOVE,drawTemporaryPolygon); 
			this.map.removeEventListener(MapEvent.CENTER_CHANGED, drawTemporaryPolygon);
			this.map.removeEventListener(MapEvent.RESOLUTION_CHANGED, drawTemporaryPolygon);
		}
		
		override public function set map(value:Map):void 
		{
			super.map = value;
			this._dblClickHandler.map = value;
			if(map!=null) map.addChild(_drawContainer);
		}
		
		//Getters and Setters
		
		/**
		 * @private
		 * */
		public function set newFeature(value:Boolean):void 
		{
			if(value) {
				lastPoint = null;
			}
			_newFeature = value;
		}
		/**
		 * To know if we create a new feature, or if some points are already added
		 */
		public function get newFeature():Boolean
		{
			return _newFeature;
		}
		
		public function get drawContainer():Sprite
		{
			return _drawContainer;
		}
		
		/**
		 *this attribute is used to see a point the first time 
		 * the user clicks 
		 **/
		public function get firstPointRemoved():Boolean 
		{
			return _firstPointRemoved;
		}
		/**
		 * Handler which manage the doubleClick, to finalize the polygon
		 */
		public function get clickHandler():ClickHandler 
		{
			return _dblClickHandler;
		}
		
		/**
		 * The style of the path
		 */
		public function get style():Style
		{
			return this._style;
		}
		public function set style(value:Style):void
		{
			this._style = value;
		}
		
		public function get lastPoint():Point
		{
			return _lastPoint;
		}
		
		public function set lastPoint(value:Point):void 
		{
			_lastPoint = value;
		}
	}
}

