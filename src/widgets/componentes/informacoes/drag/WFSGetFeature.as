package widgets.componentes.informacoes.drag
{
	//import com.webmapsolutions.controller.Controller;
	
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.geom.Point;
	import flash.net.URLLoader;
	import flash.utils.Timer;
	
	import mx.charts.chartClasses.BoundedValue;
	import mx.controls.Alert;
	import mx.core.FlexGlobals;
	import mx.events.FlexEvent;
	import mx.managers.PopUpManager;
	import mx.utils.ObjectUtil;
	
	import org.openscales.core.Map;
	import org.openscales.core.basetypes.maps.HashMap;
	import org.openscales.core.events.GetFeatureInfoEvent;
	import org.openscales.core.events.LayerEvent;
	import org.openscales.core.events.ZoomBoxEvent;
	import org.openscales.core.feature.Feature;
	import org.openscales.core.format.gml.GMLFormat;
	import org.openscales.core.format.gml.parser.GMLParser;
	import org.openscales.core.handler.Handler;
	import org.openscales.core.handler.mouse.ClickHandler;
	import org.openscales.core.layer.Layer;
	import org.openscales.core.layer.ogc.WMS;
	import org.openscales.core.request.XMLRequest;
	import org.openscales.geometry.basetypes.Bounds;
	import org.openscales.geometry.basetypes.Location;
	import org.openscales.geometry.basetypes.Pixel;
	import org.openscales.proj4as.ProjProjection;
	import org.osmf.events.TimeEvent;
	import org.osmf.utils.Version;
	
	import solutions.SiteContainer;
	
	import widgets.AboutWindowWidget;
	import widgets.componentes.informacoes.drag.event.*;
	import widgets.componentes.informacoes.drag.event.DrawnBoxEvent;
	import widgets.componentes.informacoes.drag.handler.DrawBoxHandler;
	import widgets.componentes.informacoes.drag.reader.GMLReader;
	import widgets.componentes.wmsAuthKey.WMSAuthKey;
	
	/** 
	 * @eventType org.openscales.core.events.GetFeatureInfoEvent.GET_FEATURE_INFO_DATA
	 */ 
	/*	[Event(name="openscales.getfeatureinfodata", type="org.openscales.core.events.GetFeatureInfoEvent")]
	*/	
	/**
	 * Handler allowing to get information about a WMS feature when we click on it.
	 */
	public class WFSGetFeature
	{		
		//private static var _instance:WFSGetFeature = null;
		
		//private static var _drawBoxHandler:DrawBoxHandler = new DrawBoxHandler();
		private static var _drawBoxHandler:DrawBoxHandler = DrawBoxHandler.getInstance();
		private var boundingBox:Bounds;
		private var _request:XMLRequest;
		private var _layerName:String = null;
		private var _center:Pixel = null;
		private var selecionarCamadaVisivel:Boolean = false;
		
		private var _layersNames:Array;
		
		private var _propertyName:String = null;
		private var _filter:String = null;
		private var _cqlFilter:String = null;
		
		[Bindable]
		private var _map:Map;
		
		[Bindable]
		private var _active:Boolean = false;
		
		private static var _instance:WFSGetFeature;
		private static var _nInstances:int = 0;
		
		
		public function WFSGetFeature(target:Map=null, value:Boolean = false)
		{
			map = target;
			active = value;
			
			_drawBoxHandler.map = map;
		}
		
		/*public static function getInstance(target:Map=null, value:Boolean = false):WFSGetFeature
		{
			if (_instance == null)
			{
				_instance = new WFSGetFeature(target, value);
				
				_drawBoxHandler.map = target;
				_drawBoxHandler.active = value;
			}
			
			return _instance;
		}*/
		
		protected function registerListeners():void
		{
			if (this.map)
			{
				SiteContainer.addEventListener(DrawnBoxEvent.DRAWN, getBBox);
				/*SiteContainer.addEventListener(SelectedLayerEvent.SELECTED_LAYER, getLayer);
				SiteContainer.addEventListener(LayerEvent.LAYER_ADDED, atualizaLista);
				SiteContainer.addEventListener(LayerEvent.LAYER_REMOVED, atualizaLista);
				SiteContainer.addEventListener(LayerEvent.LAYER_VISIBLE_CHANGED, atualizaLista);*/
			}
		}
		
		protected function unregisterListeners():void
		{
			if (this.map) 
			{
				SiteContainer.removeEventListener(DrawnBoxEvent.DRAWN, getBBox);
				/*SiteContainer.removeEventListener(SelectedLayerEvent.SELECTED_LAYER, getLayer);
				SiteContainer.removeEventListener(LayerEvent.LAYER_ADDED, atualizaLista);
				SiteContainer.removeEventListener(LayerEvent.LAYER_REMOVED, atualizaLista);
				SiteContainer.removeEventListener(LayerEvent.LAYER_VISIBLE_CHANGED, atualizaLista);*/
			}
		}
		
		public function get map():Map
		{
			return _map;
		}
		/**
		 * Set the existing map to the handler
		 */
		public function set map(target:Map):void 
		{	
			if (target) 
			{
				_map = target;
				_drawBoxHandler.map = target;
			}
		}
		
		public function get active():Boolean 
		{
			return _active;
		}
		
		public function set active(value:Boolean):void
		{
			if (value)
			{
				_nInstances++;
			}
			else
			{
				if (_nInstances > 0) _nInstances--;
			}
			
			if (value && (!this.active)) 
			{
				//_controller.activateTool("wfsGetFeature", true);
				_drawBoxHandler.active = true;
				
				registerListeners();
				
				_active = value;
			}
			else if ((!value) && (this.active)) 
			{
				//_controller.activateTool("wfsGetFeature", false);
								
				if (_nInstances == 0)
				{
					_drawBoxHandler.active = false;
					
					/*if (selecionarCamadaVisivel) {
					selecionarCamada.closeWindow();
					
					selecionarCamadaVisivel = false;
					}*/
					//layerName = null;
					boundingBox = null;
					
					unregisterListeners();
					
					_active = value;
				}
				
			}
			/*_active = value;*/
		}
		
		/*private function atualizaLista(event:FlexEvent=null):void {
		
		if (event != null) {
		boundingBox = null;
		SiteContainer.dispatchEvent(new AtualizaListaEvent(AtualizaListaEvent.LISTA_ATUALIZADA));
		}
		
		//var listaAux:Array= listaCamadas();
		//selecionarCamada.setCamadas(listaAux);
		//this.layerName = listaAux[0];
		}*/
		
		
		private function getLayer(event:SelectedLayerEvent):void 
		{
			this._layerName = event.camada;
		}
		
		[Bindable]
		public function get layerName():String 
		{
			return this._layerName;
		}
		public function set layerName(name:String):void 
		{
			this._layersNames = null;
			
			this._layerName = name;
			
			if (boundingBox != null) 
			{
				var bounds:Bounds = boundingBox.reprojectTo(this.map.projection);
				this._center = this.map.getMapPxFromLocation(new Location(bounds.center.x, bounds.center.y));
				
				if (this._layerName != null) 
				{
					var req:String = this.prepareRequest(boundingBox, _layerName);
					
					if(_request) 
					{
						_request.destroy();
					}
					_request = new XMLRequest(req, this.handleResponse);
					_request.proxy = map.proxy;
					_request.send();
					
					//this.cursorManager.setBusyCursor(); 
				}
			}
		}
		
		[Bindable]
		public function get layersNames():Array
		{
			return this._layersNames;
		}
		public function set layersNames(layers:Array):void 
		{			
			this.layerName = null;
			
			this._layersNames = layers;
						
			if (boundingBox != null) 
			{				
				var bounds:Bounds = boundingBox.reprojectTo(this.map.projection);
				
				this._center = this.map.getMapPxFromLocation(new Location(bounds.center.x, bounds.center.y));
				
				if ((this._layersNames != null) && (this._layersNames.length > 0))
				{
					var req:String = this.buildRequest(boundingBox, _layersNames);
					
					//var req:String = this.prepareRequest(boundingBox, layer);
					if(_request) 
					{
						_request.destroy();
					}

					_request = new XMLRequest(req, this.handleResponse);
					_request.proxy = map.proxy;
					_request.send();
					
					//this.cursorManager.setBusyCursor(); 
				}
			}
			else
			{
			}
		}
		
		/**
		 * 
		 * Method called to send the wfs request getfeature
		 * 
		 * @param boundingBox bbox of the drawn area
		 * 
		 */
		private function getBBox(event:DrawnBoxEvent):void 
		{
			var bounds:Bounds
			var req:String
			
			boundingBox = event.bounds;
			
			if ((boundingBox != null) && (this._layerName != null))
			{
				bounds = boundingBox.reprojectTo(this.map.projection);
				this._center = this.map.getMapPxFromLocation(new Location(bounds.center.x, bounds.center.y));
				
				req = this.prepareRequest(boundingBox, _layerName);

				if(_request) 
				{
					_request.destroy();
				}
				
				_request = new XMLRequest(req, this.handleResponse);
				_request.proxy = map.proxy;
				_request.send();
			}
			else if ((boundingBox != null) && (this._layersNames != null))
			{			
				bounds = boundingBox.reprojectTo(this.map.projection);
				
				this._center = this.map.getMapPxFromLocation(new Location(bounds.center.x, bounds.center.y));
				
				if ((this._layersNames != null) && (this._layersNames.length > 0))
				{
					req = this.buildRequest(boundingBox, _layersNames);

					if(_request) 
					{
						_request.destroy();
					}
					
					_request = new XMLRequest(req, this.handleResponse);
					_request.proxy = map.proxy;
					_request.send();
				}
			}
		}
		
		/**
		 * This function generate all the post treatments that lead to the generatation 
		 * of the getfeature request
		 * 
		 * @param bbox bounds of the drawn area
		 */
		public function prepareRequest(bbox:Bounds, layerName:String):String
		{
			var request:String = null;
			
			var mapLayer:Layer = map.getLayerByIdentifier(layerName);
			
			if ((mapLayer) && (mapLayer is WMS))
			{
				request = this.buildRequest(bbox, [(mapLayer as WMS)]);
			}
			
			return request;
		}
		
		/**
		 * Generate the getfeatureInfo request which is going to be sent to the server
		 * 
		 * @param pix Position of the mouse cursor when the user clicked
		 * @param version Version of WMS
		 * @param layerVec Vector of WMS which has to be integrated into the request
		 */
		private function buildRequest(bbox:Bounds, layers:Array):String
		{	
			//bbox = bbox.reprojectTo(layer.projection);
			var i:int;
			var layersNames:String;
			
			layersNames = (layers[0] as WMS).layers;
			
			for (i = 1; i < layers.length; i++)
			{
				layersNames += "," + (layers[i] as WMS).layers;
			}
			
			var request:String = "";
			
			//mandatory query layers parameter
			request = layers[0].url+"?";
			
			//mandatory service parameter
			request += "SERVICE=WFS&";
			
			//mandatory version parameter
			request += "VERSION=1.0.0&";
			
			//mandatory requestion parameter
			request += "REQUEST=GetFeature&";
			
			//mandatory query layers parameter
			request += "TYPENAME=" + layersNames  + "&";
			
			request += "outputFormat=text/xml; subtype=gml/3.1.1&";
			
			//parametro opcional
			if(this.propertyName != null)
			{
				request += "PROPERTYNAME=" + this.propertyName +"&";
			}
			
			//parametro opcional
			if(this.filter != null)
			{
				request += "FILTER=" + this.filter+"&";
			}
			
			//parametro opcional
			if(this.cqlFilter != null)
			{
				request += "CQL_FILTER=" + this.cqlFilter +"&";
			}
			//mandatory bbox parameter (minY, minX, maxY, maxX)
			request += "BBOX=" + bbox.left.toString() +","+ bbox.bottom.toString() +","+ bbox.right.toString() +","+ bbox.top.toString() + "&";						
			
			//mandatory map request part parameter
			if(layers[0].version == "1.3.0")
			{
				request += "CRS=" + bbox.projection.srsCode;
			}
			else
			{
				request += "SRS=" + bbox.projection.srsCode;
			}
			
			/*if (layers[0] is WMSAuthKey)
			{
				request += "&authkey=88203dcc-2ae8-48ff-99f5-d9eab0f43e7e";
			}*/
			
			//Alert.show(request);
			return request;
		}
		
		
		/**
		 * Read the incoming response from the server
		 * 
		 */
		private function handleResponse(event:Event):void 
		{
			var loader:URLLoader = event.target as URLLoader;
			var gmlReader:GMLReader = new GMLReader(null,new HashMap());
			
			gmlReader.version = "3.1.1";
			//gmlformat.asyncLoading = false;
			var ret:Object;

			//Alert.show(ObjectUtil.toString(loader.data));
			ret = gmlReader.read(loader.data);
			//Alert.show(ret.toString());
			if (ret)
			{
				SiteContainer.dispatchEvent(new GetFeatureEvent(GetFeatureEvent.GET_FEATURE_DATA, ret, this._layerName, this._center));
			}
			
			//var feature:Vector.<Feature> = (ret as Vector.<Feature>);
		}
		
		public function get propertyName():String
		{
			return this._propertyName;
		}
		public function set propertyName(value:String):void 
		{
			this._propertyName = value;
		}
		
		public function get filter():String 
		{
			return this._filter;
		}
		public function set filter(value:String):void 
		{
			this._filter = value;
		}
		
		public function get cqlFilter():String 
		{
			return this._cqlFilter;
		}
		public function set cqlFilter(value:String):void 
		{
			this._cqlFilter = value;
		}
		
	}
}