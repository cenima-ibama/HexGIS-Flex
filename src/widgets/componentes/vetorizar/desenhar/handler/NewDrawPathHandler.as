package widgets.componentes.vetorizar.desenhar.handler
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import org.openscales.core.Map;
	import org.openscales.core.events.FeatureEvent;
	import org.openscales.core.events.MapEvent;
	import org.openscales.core.feature.LineStringFeature;
	import org.openscales.core.handler.feature.draw.AbstractDrawHandler;
	import org.openscales.core.handler.mouse.ClickHandler;
	import org.openscales.core.layer.VectorLayer;
	import org.openscales.core.style.Style;
	import org.openscales.geometry.LineString;
	import org.openscales.geometry.Point;
	import org.openscales.geometry.basetypes.Location;
	import org.openscales.geometry.basetypes.Pixel;
	
	import widgets.VetorizarWidget;
	import widgets.componentes.ibama.feature.IbamaLineStringFeature;
	
	/** 
	 * @eventType org.openscales.core.events.FeatureEvent.FEATURE_DRAWING_END
	 */ 
	[Event(name="org.openscales.feature.drawingend", type="org.openscales.core.events.FeatureEvent")]
	
	/**
	 * This handler manage the function draw of the LineString (path).
	 * Active this handler to draw a path.
	 */
	public class NewDrawPathHandler extends AbstractDrawHandler
	{		
		/**
		 * Single id of the path
		 */ 
		private var _id:Number = 0;
		
		/**
		 * The lineString which contains all points
		 * use for draw MultiLine for example
		 */
		private var _lineString:LineString=null;
		
		/**
		 * The IbamaLineStringFeature currently drawn
		 * */
		protected var _LineStringFeature:LineStringFeature = null;
		
		/**
		 * The last point of the lineString. 
		 */
		private var _lastPoint:Point = null; 
		
		/**
		 * To know if we create a new feature, or if some points are already added
		 */
		private var _newFeature:Boolean = true;
		
		/**
		 * The container of the temporary line
		 */
		private var _drawContainer:Sprite = new Sprite();
		
		/**
		 * The start point of the temporary line
		 */
		private var _startLocation:Location=null;
		
		/**
		 * Handler which manage the doubleClick, to finalize the lineString
		 */
		private var _dblClickHandler:ClickHandler = new ClickHandler();
		
		/**
		 * 
		 */
		private var _style:Style = Style.getDefaultLineStyle();
		
		[Bindable]
		private var _widget:VetorizarWidget;
		
		
		/**
		 * DrawPathHandler constructor
		 *
		 * @param map
		 * @param active
		 * @param drawLayer The layer on which we'll draw
		 */
		public function NewDrawPathHandler(map:Map=null, active:Boolean=false, drawLayer:VectorLayer=null)
		{
			super(map, active, drawLayer);
		}
		
		override protected function registerListeners():void
		{
			this._dblClickHandler.active = true;
			this._dblClickHandler.doubleClick = this.mouseDblClick;
			
			if (this.map) 
			{
				this.map.addEventListener(MapEvent.MOUSE_CLICK, this.drawLine);
				this.map.addEventListener(MapEvent.MOVE_END, this.updateZoom);
			} 
		}
		
		override protected function unregisterListeners():void
		{
			this._dblClickHandler.active = false;
			
			if (this.map) 
			{
				this.map.removeEventListener(MapEvent.MOUSE_CLICK, this.drawLine);
				this.map.removeEventListener(MapEvent.MOVE_END, this.updateZoom);
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
		
		
		/**
		 * This function occured when a double click occured
		 * during the drawing operation
		 * @param Lastpx: The position of the double click pixel
		 * */
		public function mouseDblClick(Lastpx:Pixel=null):void
		{
			this.drawFinalPath();
		} 
		
		/**
		 * Finish the LineString
		 */
		public function drawFinalPath():void
		{			
			if (!newFeature)
			{
				newFeature = true;
				//clear the temporary line
				_drawContainer.graphics.clear();
				this.map.removeEventListener(MouseEvent.MOUSE_MOVE,temporaryLine);
				this.map.removeEventListener(MapEvent.CENTER_CHANGED, temporaryLine);
				this.map.removeEventListener(MapEvent.RESOLUTION_CHANGED, temporaryLine);
				
				if(this._LineStringFeature != null)
				{
					this._LineStringFeature.style = this._style;
					this.map.dispatchEvent(new FeatureEvent(FeatureEvent.FEATURE_DRAWING_END, this._LineStringFeature));
					drawLayer.redraw(true);
				}
			}	
		}
		
		protected function drawLine(event:MapEvent=null):void
		{
			drawLayer.scaleX = 1;
			drawLayer.scaleY = 1;
			//we determine the point where the user clicked
			var pixel:Pixel = new Pixel(this.map.mouseX,this.map.mouseY );
			var lonlat:Location = this.map.getLocationFromMapPx(pixel); //this.map.getLocationFromLayerPx(pixel);
			//manage the case where the layer projection is different from the map projection
			var point:Point = new Point(lonlat.lon,lonlat.lat);
			//initialize the temporary line
			_startLocation = lonlat;
			
			//The user click for the first time
			if(newFeature)
			{
				if (this.widget)
				{
					this.style = this.widget.getLineStyle();
				}
				
				_lineString = new LineString(new <Number>[point.x,point.y]);
				_lineString.projection = this.map.projection;
				lastPoint = point;
				//the current drawn IbamaLineStringFeature
				this._LineStringFeature = new IbamaLineStringFeature(_lineString, null, this.style, true);
				
				this._LineStringFeature.name = "path." + drawLayer.idPath.toString();
				drawLayer.idPath++;
				
				if (widget.configData.userData != null)
				{
					(this._LineStringFeature as IbamaLineStringFeature).login_user = widget.configData.userData.cpf;
				}
				
				drawLayer.addFeature(_LineStringFeature);
				
				newFeature = false;
				//draw the temporary line, update each time the mouse moves		
				this.map.addEventListener(MouseEvent.MOUSE_MOVE,temporaryLine);	
				this.map.addEventListener(MapEvent.CENTER_CHANGED, temporaryLine);
				this.map.addEventListener(MapEvent.RESOLUTION_CHANGED, temporaryLine);
			}
			else 
			{								
				if (!point.equals(lastPoint))
				{
					_lineString.addPoint(point.x,point.y);
					_LineStringFeature.geometry = _lineString;
					drawLayer.redraw(true);
					lastPoint = point;
				}								
			}
		}
		
		/**
		 * Update the temporary line
		 */
		public function temporaryLine(evt:Event):void
		{
			_drawContainer.graphics.clear();
			_drawContainer.graphics.lineStyle(2, 0x00ff00);
			_drawContainer.graphics.moveTo(this.map.getMapPxFromLocation(_startLocation).x, this.map.getMapPxFromLocation(_startLocation).y);
			_drawContainer.graphics.lineTo(map.mouseX, map.mouseY);
			_drawContainer.graphics.endFill();
		}
		
		/**
		 * @inherited
		 */
		override public function set map(value:Map):void
		{
			super.map = value;
			this._dblClickHandler.map = value;
			if(map != null)
			{
				map.addChild(_drawContainer);
			}
		}
		
		protected function updateZoom(evt:MapEvent):void
		{
			if(evt.zoomChanged)
			{
				_drawContainer.graphics.clear();
				//we update the pixel of the last point which has changed
				var tempPoint:Point = _lineString.getLastPoint();
				_startLocation = new Location(tempPoint.x, tempPoint.y);
			}
		}
		
		//Getters and Setters		
		public function get id():Number 
		{
			return _id;
		}
		public function set id(nb:Number):void 
		{
			_id = nb;
		}
		
		public function get newFeature():Boolean 
		{
			return _newFeature;
		}
		
		public function set newFeature(newFeature:Boolean):void 
		{
			if(newFeature == true) 
			{
				lastPoint = null;
			}
			_newFeature = newFeature;
		}
		
		public function get lastPoint():Point 
		{
			return _lastPoint;
		}
		public function set lastPoint(value:Point):void 
		{
			_lastPoint = value;
		}
		
		public function get drawContainer():Sprite
		{
			return _drawContainer;
		}
		
		public function get startLocation():Location
		{
			return _startLocation;
		}
		public function set startLocation(value:Location):void
		{
			_startLocation = value;
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
		
		public function get lineString():LineString
		{
			return _lineString;
		}
		
		public function set lineString(value:LineString):void{
			_lineString = value;
		}
		
		public function get currentLineStringFeature():LineStringFeature
		{
			return _LineStringFeature;
		}
		public function set currentLineStringFeature(value:LineStringFeature):void
		{
			_LineStringFeature = value;
		}
	}
}