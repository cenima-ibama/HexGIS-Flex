package widgets.componentes.informacoes.drag.handler
{
	
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	
	import mx.containers.Box;
	import mx.controls.Alert;
	import mx.managers.PopUpManager;
	
	import org.openscales.core.Map;
	import org.openscales.core.events.MapEvent;
	import org.openscales.core.events.ZoomBoxEvent;
	import org.openscales.core.handler.Handler;
	import org.openscales.core.handler.mouse.ClickHandler;
	import org.openscales.core.handler.mouse.DragHandler;
	import org.openscales.geometry.basetypes.Bounds;
	import org.openscales.geometry.basetypes.Location;
	import org.openscales.geometry.basetypes.Pixel;
	import org.openscales.proj4as.Proj4as;
	import org.openscales.proj4as.ProjProjection;
	
	import solutions.SiteContainer;
	
	import widgets.componentes.informacoes.drag.event.AtualizaListaEvent;
	import widgets.componentes.informacoes.drag.event.DragActivatedEvent;
	import widgets.componentes.informacoes.drag.event.DrawnBoxEvent;
	import widgets.componentes.zoomBox.BlurScreen;
	
	/**
	 * This handler allows user to zoom the map by drawing a rectangle with the mouse
	 * 
	 * The handler has to mode: 
	 * <ul>
	 * 	<li>Shift key need to be pressed and hold in order to draw the rectangle</li>
	 * 	<li>No keys are required</li>
	 * </ul>
	 */ 
	public class  DrawBoxHandler extends Handler
	{
		
		private var _dragging:Boolean = false;
		
		private var _startCoordinates:Location = null;
		
		private var _firstPixel:Pixel;
		
		private var _lastPixel:Pixel;

		private var _boxStrokeColor1:uint = 0xfdb323
		
		private var _boxStrokeColor2:uint = 0xfdb323;
		
		private var _boxFillColor:uint = 0xfdb323;
		
		private var _outFillColor:uint = 0x000000;
		//private var _outFillColor:uint = 0x0042ff;
		
		private var _outAlpha:Number = 0.5;
				
		private var _boxStrokeAlpha:Number = 0.5;
		
		private var _boxFillAlpha:Number = 0.5;
		
		private var _drawing:Boolean = false;
		//private var _dragged:Boolean = false;
		
		private var _drawContainer:Sprite = new Sprite();	
		private var bgContainerLeft:Sprite = new Sprite();
		private var bgContainerRight:Sprite = new Sprite();
		private var bgContainerBottom:Sprite = new Sprite();
		private var bgContainerTop:Sprite = new Sprite();
				
		private var _drawnBox:Bounds;
		
		private var blurScreen:BlurScreen = new BlurScreen();
		
		private static var _instance:DrawBoxHandler;
		public var _nInstances:int = 0;
		
		
		/**
		 * Constructor
		 * 
		 * @param shiftMode Boolean specifying whether to active shift mode or not
		 * @param map The Map that will be concerned by event handling
		 * @param active Boolean defining if the handler is active or not (default=true)
		 */ 
		public function DrawBoxHandler(map:Map=null, active:Boolean=false):void
		{
			super(map, active);
		}
		
		public static function getInstance():DrawBoxHandler
		{
			if (_instance == null)
			{
				_instance = new DrawBoxHandler();
			}
			
			return _instance;
		}

		/**
		 * @inheritDoc
		 */ 
		override protected function registerListeners():void
		{
			if (this.map)
			{
				if (this.map.stage)
				{
					this.registerMouseUp();
				}
				this.map.addEventListener(MouseEvent.MOUSE_DOWN, startBox);
				this.map.addEventListener(MapEvent.DRAG_START, dragStart);
				this.map.addEventListener(MapEvent.DRAG_END, dragEnd);
				this.map.addEventListener(AtualizaListaEvent.LISTA_ATUALIZADA, resetScreen);
			}
		}
		
		override public function set active(value:Boolean):void 
		{
			if (value)
			{
				_nInstances++;
			}
			else
			{
				if (_nInstances > 0) _nInstances--;
			}
						
			if ((!this.active) && (value))
			{
				SiteContainer.dispatchEvent(new DragActivatedEvent(DragActivatedEvent.INFO_DRAG_ATIVADO));
				this.changeScreen();
				super.active = true;
			}
			else if ((this.active) && (!value)) 
			{
				if (_nInstances == 0)
				{
					this.cleanScreen();
					super.active = false;
				}
			}
		}

		/**
		 * @private
		 */
		private function registerMouseUp():void
		{
			this.map.stage.addEventListener(MouseEvent.MOUSE_UP,endBox);
		}
		
		/**
		 * @inheritDoc
		 */ 
		override protected function unregisterListeners():void
		{
			if (this.map)
			{
				if(this.map.stage)
				{
					this.map.stage.removeEventListener(MouseEvent.MOUSE_UP, endBox);
					this.map.stage.removeEventListener(MouseEvent.MOUSE_MOVE, expandArea);
				}
				this.map.removeEventListener(MouseEvent.MOUSE_DOWN, startBox);
				this.map.removeEventListener(MapEvent.DRAG_START, dragStart);
				this.map.removeEventListener(MapEvent.DRAG_END, dragEnd);
				this.map.removeEventListener(AtualizaListaEvent.LISTA_ATUALIZADA, resetScreen);
								
				this.cleanScreen();
			}
		}
		
		/**
		 * Map setter
		 */ 
		override public function set map(value:Map):void
		{
			if(value)
			{
				super.map = value;
				map.addChild(bgContainerLeft);
				map.addChild(bgContainerRight);
				map.addChild(bgContainerBottom);
				map.addChild(bgContainerTop);
				map.addChild(_drawContainer);
			}
		}
		
		
		private function resetScreen(event:AtualizaListaEvent=null):void
		{
			this.cleanScreen();
			this.changeScreen();
		}
		
		private function changeScreen():void 
		{
			bgContainerTop.graphics.beginFill(_outFillColor,_outAlpha);
			bgContainerTop.graphics.drawRect(0, 0, map.width,  map.height);
			bgContainerTop.graphics.endFill();
			
		}
		
		private function cleanScreen():void 
		{
			_drawContainer.graphics.clear();
			bgContainerTop.graphics.clear();
			bgContainerLeft.graphics.clear();
			bgContainerRight.graphics.clear();
			bgContainerBottom.graphics.clear();
		}
				
		/**
		 * @private
		 * 
		 * Method called on MOUSE_DOWN event
		 *  It create a selection recantgle and add MOUSE_MOVE event handling to the map
		 */ 
		private function startBox(e:MouseEvent):void 
		{
			if ((!this.active) || !this.map.mouseNavigationEnabled)
				return;
			
			blurScreen = BlurScreen(PopUpManager.createPopUp(this.map, BlurScreen, true));
			
			this.registerMouseUp();
			this.map.stage.addEventListener(MouseEvent.MOUSE_MOVE,expandArea);
			this._drawing = true;
			
			//this.resetScreen();
			
			/*_drawContainer.graphics.beginFill(_boxFillColor,0.5);
			_drawContainer.graphics.drawRect(map.mouseX,map.mouseY,1,1);
			_drawContainer.graphics.endFill();*/
						
			this._startCoordinates = this.map.getLocationFromMapPx(new Pixel(map.mouseX, map.mouseY));
		}
		
		/**
		 * @private 
		 * Method called on MOUSE_MOVE event. It redraws the selection relcantgle
		 */ 
		private function expandArea(e:MouseEvent):void
		{	
			//dragged = true;
			if (! this.map.hitTestPoint(e.stageX, e.stageY))
			{
				this.endBox(e);
			}
			else
			{
				var ll:Pixel = map.getMapPxFromLocation(_startCoordinates);
				
				if ((map.mouseX > ll.x) && (map.mouseY > ll.y)) 
				{
					bgContainerTop.graphics.clear();
					bgContainerTop.graphics.lineStyle(0,_outFillColor,0);
					bgContainerTop.graphics.beginFill(_outFillColor,_outAlpha);
					bgContainerTop.graphics.drawRect(0, 0, map.width, ll.y);
					bgContainerTop.graphics.endFill();
					
					bgContainerLeft.graphics.clear();
					bgContainerLeft.graphics.lineStyle(0,_outFillColor,0);
					bgContainerLeft.graphics.beginFill(_outFillColor,_outAlpha);
					bgContainerLeft.graphics.drawRect(0, ll.y, ll.x, map.mouseY - ll.y);
					bgContainerLeft.graphics.endFill();
					
					bgContainerRight.graphics.clear();
					bgContainerRight.graphics.lineStyle(0,_outFillColor,0);
					bgContainerRight.graphics.beginFill(_outFillColor,_outAlpha);
					bgContainerRight.graphics.drawRect(map.mouseX, ll.y, map.width - map.mouseX, map.mouseY - ll.y);
					bgContainerRight.graphics.endFill();
					
					bgContainerBottom.graphics.clear();
					bgContainerBottom.graphics.lineStyle(0,_outFillColor,0);
					bgContainerBottom.graphics.beginFill(_outFillColor,_outAlpha);
					bgContainerBottom.graphics.drawRect(0, map.mouseY, map.width, map.height - map.mouseY);
					bgContainerBottom.graphics.endFill();
				}
				else if ((map.mouseX < ll.x) && (map.mouseY > ll.y)) 
				{
					bgContainerTop.graphics.clear();
					bgContainerTop.graphics.lineStyle(0,_outFillColor,0);
					bgContainerTop.graphics.beginFill(_outFillColor,_outAlpha);
					bgContainerTop.graphics.drawRect(0, 0, map.width, ll.y);
					bgContainerTop.graphics.endFill();
					
					bgContainerLeft.graphics.clear();
					bgContainerLeft.graphics.lineStyle(0,_outFillColor,0);
					bgContainerLeft.graphics.beginFill(_outFillColor,_outAlpha);
					bgContainerLeft.graphics.drawRect(0, ll.y, map.mouseX, map.mouseY - ll.y);
					bgContainerLeft.graphics.endFill();
					
					bgContainerRight.graphics.clear();
					bgContainerRight.graphics.lineStyle(0,_outFillColor,0);
					bgContainerRight.graphics.beginFill(_outFillColor,_outAlpha);
					bgContainerRight.graphics.drawRect(ll.x, ll.y, map.width - ll.x, map.mouseY - ll.y);
					bgContainerRight.graphics.endFill();
					
					bgContainerBottom.graphics.clear();
					bgContainerBottom.graphics.lineStyle(0,_outFillColor,0);
					bgContainerBottom.graphics.beginFill(_outFillColor,_outAlpha);
					bgContainerBottom.graphics.drawRect(0, map.mouseY, map.width, map.height - map.mouseY);
					bgContainerBottom.graphics.endFill();
					
				}
				else if ((map.mouseX > ll.x) && (map.mouseY < ll.y))
				{
					bgContainerTop.graphics.clear();
					bgContainerTop.graphics.lineStyle(0,_outFillColor,0);
					bgContainerTop.graphics.beginFill(_outFillColor,_outAlpha);
					bgContainerTop.graphics.drawRect(0, 0, map.width, map.mouseY);
					bgContainerTop.graphics.endFill();
					
					bgContainerLeft.graphics.clear();
					bgContainerLeft.graphics.lineStyle(0,_outFillColor,0);
					bgContainerLeft.graphics.beginFill(_outFillColor,_outAlpha);
					bgContainerLeft.graphics.drawRect(0, map.mouseY, ll.x, ll.y - map.mouseY);
					bgContainerLeft.graphics.endFill();
					
					bgContainerRight.graphics.clear();
					bgContainerRight.graphics.lineStyle(0,_outFillColor,0);
					bgContainerRight.graphics.beginFill(_outFillColor,_outAlpha);
					bgContainerRight.graphics.drawRect(map.mouseX, map.mouseY, map.width - map.mouseX, ll.y - map.mouseY);
					bgContainerRight.graphics.endFill();
					
					bgContainerBottom.graphics.clear();
					bgContainerBottom.graphics.lineStyle(0,_outFillColor,0);
					bgContainerBottom.graphics.beginFill(_outFillColor,_outAlpha);
					bgContainerBottom.graphics.drawRect(0, ll.y, map.width, map.height - ll.y);
					bgContainerBottom.graphics.endFill();
					
				}
				else if ((map.mouseX < ll.x) && (map.mouseY < ll.y)) 
				{
					bgContainerTop.graphics.clear();
					bgContainerTop.graphics.lineStyle(0,_outFillColor,0);
					bgContainerTop.graphics.beginFill(_outFillColor,_outAlpha);
					bgContainerTop.graphics.drawRect(0, 0, map.width, map.mouseY);
					bgContainerTop.graphics.endFill();
					
					bgContainerLeft.graphics.clear();
					bgContainerLeft.graphics.lineStyle(0,_outFillColor,0);
					bgContainerLeft.graphics.beginFill(_outFillColor,_outAlpha);
					bgContainerLeft.graphics.drawRect(0, map.mouseY, map.mouseX, ll.y - map.mouseY);
					bgContainerLeft.graphics.endFill();
					
					bgContainerRight.graphics.clear();
					bgContainerRight.graphics.lineStyle(0,_outFillColor,0);
					bgContainerRight.graphics.beginFill(_outFillColor,_outAlpha);
					bgContainerRight.graphics.drawRect(ll.x, map.mouseY, map.width - map.mouseY, ll.y - map.mouseY);
					bgContainerRight.graphics.endFill();
					
					bgContainerBottom.graphics.clear();
					bgContainerBottom.graphics.lineStyle(0,_outFillColor,0);
					bgContainerBottom.graphics.beginFill(_outFillColor,_outAlpha);
					bgContainerBottom.graphics.drawRect(0, ll.y, map.width, map.height - ll.y);
					bgContainerBottom.graphics.endFill();
				}
				
				_drawContainer.graphics.clear();
				_drawContainer.graphics.lineStyle(3,_boxStrokeColor2, 0.5);
				_drawContainer.graphics.beginFill(_boxFillColor,0);
				_drawContainer.graphics.drawRect(ll.x,ll.y,map.mouseX - ll.x,map.mouseY - ll.y);
				_drawContainer.graphics.endFill();
			}
		}
		
		/**
		 * @private
		 * Method called on MOUSE_UP event. 
		 * It calculates the bounds that matches the selection rectangle. 
		 */ 
		private function endBox(e:MouseEvent):void
		{
			drawnBox = null;
			
			if (this._drawing)
			{
				this.map.stage.removeEventListener(MouseEvent.MOUSE_MOVE,expandArea);
				this._drawing = false;
				
				bgContainerTop.graphics.clear();
				bgContainerLeft.graphics.clear();
				bgContainerRight.graphics.clear();
				bgContainerBottom.graphics.clear();	
				
				//_drawContainer.graphics.clear();
				if(!e)
					return;
				
				var endCoordinates:Location = this.map.getLocationFromMapPx(new Pixel(map.mouseX, map.mouseY));
				
				if(_startCoordinates != null && this.map.hitTestPoint(e.stageX, e.stageY)) 
				{
					if(!_startCoordinates.equals(endCoordinates))
					{
						/*if (this.dragged) 
						{*/
							drawnBox = new Bounds(Math.min(_startCoordinates.x,endCoordinates.x),
								Math.min(endCoordinates.y,_startCoordinates.y),
								Math.max(_startCoordinates.x,endCoordinates.x),
								Math.max(endCoordinates.y,_startCoordinates.y),
								this.map.projection);
														
							/*drawnBox = new Bounds(
								Math.min(_startCoordinates.lon,endCoordinates.lon),
								Math.min(endCoordinates.lat,_startCoordinates.lat),
								Math.max(_startCoordinates.lon,endCoordinates.lon),
								Math.max(endCoordinates.lat,_startCoordinates.lat),
								endCoordinates.projection);*/

							_firstPixel = this.map.getMapPxFromLocation(new Location(drawnBox.left, drawnBox.top));
							_lastPixel = this.map.getMapPxFromLocation(new Location(drawnBox.right, drawnBox.bottom));
							
							_drawContainer.graphics.clear();
							_drawContainer.graphics.lineStyle(3, _boxStrokeColor1, _boxStrokeAlpha);
							_drawContainer.graphics.beginFill(_boxFillColor, 0.5);
							_drawContainer.graphics.drawRect(_firstPixel.x,_firstPixel.y,( _lastPixel.x - _firstPixel.x), (_lastPixel.y - _firstPixel.y));
							_drawContainer.graphics.endFill();
					
							drawnBox = drawnBox.reprojectTo(new ProjProjection("EPSG:4326"));
							
							//Mudando ordem das coordenadas para a wfs request getfeature
							//drawnBox = new Bounds(drawnBox.bottom, drawnBox.left, drawnBox.top, drawnBox.right, drawnBox.projection);
							
							/*this.dragged = false;
						}*/
					}
					/*else 
					{
						_drawContainer.graphics.clear();
					}*/
				}
				this._startCoordinates = null;
				SiteContainer.dispatchEvent(new DrawnBoxEvent(DrawnBoxEvent.DRAWN, drawnBox, _drawContainer));
				this.map.stage.focus = this.map; // Giving focus back to the map
				blurScreen.closeWindow();
			}
		}
		
		/**
		 * @private
		 * Callback of the MapEvent.DRAG_START event to set the dragging boolean;
		 */
		private function dragStart(event:MapEvent):void
		{
			this._dragging = true;
		}
		
		/**
		 * @private
		 * Callback of the MapEvent.DRAG_END event to set the dragging boolean;
		 */
		private function dragEnd(event:MapEvent):void
		{
			this._dragging = false;
		}
		
		
		/*private function get dragged():Boolean{
			return this._dragged;
		}
		private function set dragged(value:Boolean):void{
			this._dragged = value;
		}
		*/
		
		public function get drawnBox():Bounds
		{
			return _drawnBox;
		}
		
		
		public function set drawnBox(value:Bounds):void
		{
			_drawnBox = value;
		}
		
		/**
		 * Color of the rectangle
		 * @default 0xFF0000
		 */
		public function get boxFillColor():uint
		{
			return _boxFillColor;
		}
		
		/**
		 * @private
		 */
		public function set boxFillColor(value:uint):void
		{
			_boxFillColor = value;
		}
		
	}
}