package widgets.componentes.vetorizar.desenhar.handler
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import org.openscales.core.Map;
	import org.openscales.core.events.FeatureEvent;
	import org.openscales.core.events.MapEvent;
	import org.openscales.core.feature.State;
	import org.openscales.core.handler.feature.draw.AbstractDrawHandler;
	import org.openscales.core.handler.mouse.ClickHandler;
	import org.openscales.core.layer.VectorLayer;
	import org.openscales.core.style.Style;
	import org.openscales.geometry.Geometry;
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
	public class NewDrawShapeHandler extends AbstractDrawHandler
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
		protected var _currentIbamaLineStringFeature:IbamaLineStringFeature = null;
		
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
		private var _startPoint:Pixel=new Pixel();
		
		/**
		 * 
		 */
		private var _style:Style = Style.getDefaultLineStyle();
		
		/**
		 * Handler which manage the doubleClick, to finalize the lineString
		 */
		private var _dblClickHandler:ClickHandler = new ClickHandler();
		
		/**
		 * boolean that says if we are currently drawing
		 */
		private var _drawing:Boolean = false;
		
		[Bindable]
		private var _widget:VetorizarWidget;
		
		
		/**
		 * DrawPathHandler constructor
		 *
		 * @param map
		 * @param active
		 * @param drawLayer The layer on which we'll draw
		 */
		public function NewDrawShapeHandler(map:Map=null, active:Boolean=false, drawLayer:org.openscales.core.layer.VectorLayer=null)
		{
			super(map, active, drawLayer);
		}
		
		override protected function registerListeners():void
		{
			this._dblClickHandler.active = true;
			this._dblClickHandler.doubleClick = this.mouseDblClick;
			if (this.map) 
			{
				this.map.addEventListener(MapEvent.MOUSE_CLICK, this.initShape);
				this.map.addEventListener(MapEvent.MOVE_END, this.updateZoom);
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
		 * Callback that stop the draw if draging the map.
		 */
		public function stopDrawWhilePan(event:MouseEvent):void
		{
			if (_drawing)
			{
				this.map.removeEventListener(MouseEvent.MOUSE_MOVE,drawShape);
			}
		}
		
		/**
		 * Callback that restart the draw if draging the map.
		 */
		public function activateDrawAfterPan(event:MouseEvent):void
		{
			if (_drawing)
			{
				this.map.addEventListener(MouseEvent.MOUSE_MOVE,drawShape);
			}
		}
		
		override protected function unregisterListeners():void
		{
			this._dblClickHandler.active = false;
			if (this.map) 
			{
				this.map.removeEventListener(MapEvent.MOUSE_CLICK, this.initShape);
				this.map.removeEventListener(MapEvent.MOVE_END, this.updateZoom);
				this.map.removeEventListener(MouseEvent.MOUSE_MOVE,drawShape);
				this.map.removeEventListener(MouseEvent.MOUSE_DOWN, this.stopDrawWhilePan);
				this.map.removeEventListener(MouseEvent.MOUSE_UP, this.activateDrawAfterPan);
			}
		}
		
		public function initShape(event:Event=null):void
		{
			//Init shape
			if(newFeature) 
			{
				newFeature = false;
				
				if (this.widget)
				{
					this.style = this.widget.getLineStyle();
				}
				
				drawLayer.scaleX=1;
				drawLayer.scaleY=1;
				//we determine the point where the user clicked
				var pixel:Pixel = new Pixel(this.map.mouseX,this.map.mouseY );
				var lonlat:Location = this.map.getLocationFromMapPx(pixel); //this.map.getLocationFromLayerPx(pixel);
				//manage the case where the layer projection is different from the map projection
				var point:Point = new Point(lonlat.lon,lonlat.lat);
				//initialize the temporary line
				_startPoint = this.map.getMapPxFromLocation(lonlat);
				
				_lineString = new LineString(new <Number>[point.x,point.y]);
				_lineString.projection = this.map.projection;
				lastPoint = point;
				//the current drawn IbamaLineStringFeature
				this._currentIbamaLineStringFeature = new IbamaLineStringFeature(_lineString, null, this.style, true);
				
				this._currentIbamaLineStringFeature.name = "path." + drawLayer.idPath.toString();
				drawLayer.idPath++;
				
				if (widget.configData.userData != null)
				{
					(this._currentIbamaLineStringFeature as IbamaLineStringFeature).login_user = widget.configData.userData.cpf;
				}
				
				drawLayer.addFeature(_currentIbamaLineStringFeature);
				
				_drawing = true;
				//draw the shape, update each time the mouse moves
				this.map.addEventListener(MouseEvent.MOUSE_MOVE,drawShape);	
				this.map.addEventListener(MouseEvent.MOUSE_DOWN, this.stopDrawWhilePan);
				this.map.addEventListener(MouseEvent.MOUSE_UP, this.activateDrawAfterPan);
				
			}
		}
		
		/**
		 * This function occured when a double click occured
		 * during the drawing operation
		 * @param Lastpx: The position of the double click pixel
		 * */
		public function mouseDblClick(Lastpx:Pixel=null):void 
		{
			this.endShape();
		} 
		
		public function endShape():void{
			
			//If we are actually drawing
			if(newFeature == false) {
				this.map.removeEventListener(MouseEvent.MOUSE_MOVE,drawShape);
				this.map.removeEventListener(MouseEvent.MOUSE_DOWN, this.stopDrawWhilePan);
				this.map.removeEventListener(MouseEvent.MOUSE_UP, this.activateDrawAfterPan);
				if(this._currentIbamaLineStringFeature!=null){
					this._currentIbamaLineStringFeature.style=this._style;
					_drawing = false;
					this.map.dispatchEvent(new FeatureEvent(FeatureEvent.FEATURE_DRAWING_END,this._currentIbamaLineStringFeature));
					drawLayer.redraw(true);
				}
				
				newFeature = true;
			}
		}
		
		/**
		 * Draw the shape while moving mouse
		 */
		public function drawShape(evt:Event):void{
			//we determine the point where the user clicked
			var pixel:Pixel = new Pixel(this.map.mouseX,this.map.mouseY );
			var lonlat:Location = this.map.getLocationFromMapPx(pixel); //this.map.getLocationFromLayerPx(pixel);
			//manage the case where the layer projection is different from the map projection
			var point:Point = new Point(lonlat.lon,lonlat.lat);
			
			if(!point.equals(lastPoint)){
				_lineString.addPoint(point.x,point.y);
				this._currentIbamaLineStringFeature.geometry = _lineString;
				drawLayer.redraw(true);
				lastPoint = point;
			}
		}
		
		/**
		 * @inherited
		 */
		override public function set map(value:Map):void{
			super.map = value;
			this._dblClickHandler.map = value;
			if(map != null){
				map.addChild(_drawContainer);
			}
		}
		
		protected function updateZoom(evt:MapEvent):void{
			
			if(evt.zoomChanged) {
				//we update the pixel of the last point which has changed
				var tempPoint:Point = _lineString.getLastPoint();
				_startPoint = this.map.getMapPxFromLocation(new Location(tempPoint.x, tempPoint.y));
			}
		}
		
		//Getters and Setters		
		public function get id():Number {
			return _id;
		}
		public function set id(nb:Number):void {
			_id = nb;
		}
		
		public function get newFeature():Boolean {
			return _newFeature;
		}
		
		public function set newFeature(newFeature:Boolean):void {
			if(newFeature == true) {
				lastPoint = null;
			}
			_newFeature = newFeature;
		}
		
		public function get lastPoint():Point {
			return _lastPoint;
		}
		public function set lastPoint(value:Point):void {
			_lastPoint = value;
		}
		
		public function get drawContainer():Sprite{
			return _drawContainer;
		}
		
		public function get startPoint():Pixel{
			return _startPoint;
		}
		public function set startPoint(pix:Pixel):void{
			_startPoint = pix;
		}
		
		/**
		 * The style of the path
		 */
		public function get style():Style{
			
			return this._style;
		}
		public function set style(value:Style):void{
			
			this._style = value;
		}
		public function get lineString():LineString{
			return _lineString;
		}
		public function set lineString(value:LineString):void{
			_lineString = value;
		}
		
		public function get currentIbamaLineStringFeature():IbamaLineStringFeature{
			return _currentIbamaLineStringFeature;
		}
		public function set currentIbamaLineStringFeature(value:IbamaLineStringFeature):void{
			_currentIbamaLineStringFeature = value;
		}
	}
}