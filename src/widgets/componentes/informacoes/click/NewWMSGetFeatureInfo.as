package widgets.componentes.informacoes.click
{
	import flash.events.Event;
	import flash.geom.Point;
	import flash.net.URLLoader;
	
	import mx.controls.Alert;
	
	import org.openscales.core.Map;
	import org.openscales.core.basetypes.maps.HashMap;
	import org.openscales.core.events.GetFeatureInfoEvent;
	import org.openscales.core.feature.Feature;
	import org.openscales.core.format.gml.GMLFormat;
	import org.openscales.core.format.gml.parser.GMLParser;
	import org.openscales.core.handler.Handler;
	import org.openscales.core.handler.mouse.ClickHandler;
	import org.openscales.core.layer.Layer;
	import org.openscales.core.layer.ogc.WMS;
	import org.openscales.core.request.XMLRequest;
	import org.openscales.geometry.basetypes.Location;
	import org.openscales.geometry.basetypes.Pixel;
	import org.osmf.utils.Version;
	
	import solutions.SiteContainer;
	
	import widgets.componentes.informacoes.click.event.ClickActivatedEvent;
	
	/** 
	 * @eventType org.openscales.core.events.GetFeatureInfoEvent.GET_FEATURE_INFO_DATA
	 */ 
	[Event(name="openscales.getfeatureinfodata", type="org.openscales.core.events.GetFeatureInfoEvent")]
	
	/**
	 * Handler allowing to get information about a WMS feature when we click on it.
	 */
	public class NewWMSGetFeatureInfo extends Handler
	{
		
		private var _clickHandler:ClickHandler;
		
		private var _request:XMLRequest;
		
		private var _maxFeatures:Number;
		private var _drillDown:Boolean=false;
		private var _infoFormat:String="application/vnd.ogc.gml";
		private var _layers:String=null;
		
		public function NewWMSGetFeatureInfo(target:Map=null, active:Boolean = false)
		{
			super(target,active);
		}
		
		/**
		 * This function generate all the post treatments that lead to the generatation 
		 * of the getfeatureinfo request
		 * 
		 * @param pix Position of the cursor when the user clicked
		 */
		public function prepareRequest(pix:Pixel):Vector.<String>
		{
			var request:Vector.<String> = new Vector.<String>();
			
			var layerVecTmp:Vector.<WMS> = null;
			var vecTmp:Vector.<WMS> = null;
			var tmp:WMS = null;
			var mapLayers:Vector.<Layer>= null;
			var mapLayersLength:Number = 0;
			var hm:HashMap = null;
			var i:Number = 0;
			var j:Number = 0;
			var keys:Array;
			var keysLength:Number;
			
			var vecStrTmp:Vector.<String> = null;
			
			//if layers are specified, then the request is send only for the layers in the list
			if(this._layers != null)
			{
				mapLayers= this.map.layers;
				mapLayersLength = mapLayers.length;
				hm = new HashMap();
				
				for (i=0; i<mapLayersLength; ++i){
					if (mapLayers[i].visible){ //the request is made for the first visible wms layer
						if(mapLayers[i] is WMS){
							tmp = (mapLayers[i] as WMS);
							if(_layers.indexOf(tmp.identifier) != -1){
								//put the found layer in a vector to generate the request
								layerVecTmp = new Vector.<WMS>();
								layerVecTmp.push(tmp);
								
								if(hm.getValue(tmp.version) == undefined){
									hm.put(tmp.version, layerVecTmp);
								}else{
									vecTmp = hm.getValue(tmp.version);
									vecTmp.push(tmp);
									hm.put(tmp.version, vecTmp);
								}
							}
						}
					}
				}
				
				//build the request
				keys = hm.getKeys();
				keysLength = keys.length;				
				
				for(i=0;i<keysLength;++i){
					vecStrTmp = this.buildRequest(pix,keys[i],hm.getValue(keys[i]));
					for (j=0;j<vecStrTmp.length;++j){
						request.push(vecStrTmp[j]);
					}
				}
				
			}
			else
			{
				//no list, then check if we have to request all visible layers
				if(this._drillDown)
				{
					mapLayers= this.map.layers;
					mapLayersLength = mapLayers.length;
					hm = new HashMap();
					
					for (i=0; i<mapLayersLength; ++i)
					{
						if (mapLayers[i].visible){ //the request is made for the first visible wms layer
							if(mapLayers[i] is WMS){
								tmp = (mapLayers[i] as WMS);
								//put the found layer in a vector to generate the request
								layerVecTmp = new Vector.<WMS>();
								layerVecTmp.push(tmp);
								
								if(hm.getValue(tmp.version) == undefined){
									hm.put(tmp.version, layerVecTmp);
								}else{
									vecTmp = hm.getValue(tmp.version);
									vecTmp.push(tmp);
									hm.put(tmp.version, vecTmp);
								}
							}
						}
					}
					
					//build the request
					keys = hm.getKeys();
					keysLength = keys.length;				

					for(i=0;i<keysLength;++i)
					{
						vecStrTmp = this.buildRequest(pix,keys[i],hm.getValue(keys[i]));
						for (j=0;j<vecStrTmp.length;++j){
							//Alert.show(vecStrTmp[j]);
							request.push(vecStrTmp[j]);
						}
					}					
				}
				else //only the first layer
				{
					mapLayers= this.map.layers;
					mapLayersLength = mapLayers.length;
					i= mapLayersLength - 1 ;
					var found:Boolean = false;
					while(i >= 0 && !found){
						if (mapLayers[i].visible){ //the request is made for the top visible wms layer
							if(mapLayers[i] is WMS){
								//put the found layer in a vector to generate the request
								layerVecTmp = new Vector.<WMS>();
								layerVecTmp.push(mapLayers[i] as WMS);
								
								//build the request
								request.push(this.buildRequest(pix,(mapLayers[i] as WMS).version,layerVecTmp));
								found=true;
							}
						}
						i--;
					}
				}
			}
			
			return request;
		}
		
		
		/**
		 * Checks if a String is contained into a Vector of strings
		 * 
		 * @param vec Source vector of strings
		 * @param val String to find in the vector
		 */
		private function contains(vec:Vector.<String>, val:String):Number
		{
			var found:Number=-1;
			
			var length:Number = vec.length;
			var i:Number=0;
			var strTmp:String="";
			
			while (i<length && found==-1){
				strTmp=vec[i];
				if(strTmp.indexOf(val) !=-1){
					found=i;
				}
				i++;
			}
			
			return found;
		}
		
		/**
		 * Generate the getfeatureInfo request which is going to be sent to the server
		 * 
		 * @param pix Position of the mouse cursor when the user clicked
		 * @param version Version of WMS
		 * @param layerVec Vector of WMS which has to be integrated into the request
		 */
		private function buildRequest(pix:Pixel,version:String, layerVec:Vector.<WMS>):Vector.<String>
		{
			var requestList:Vector.<String> = new Vector.<String>();

			var request:String="";
			
			//mandatory query layers parameter
			var length:Number = layerVec.length;			
			
			for(var i:Number=0;i<length;++i)
			{
				var idContained:Number = this.contains(requestList,layerVec[i].url);
				if(idContained != -1){ //the request string has already been initialised

					//requestList[idContained] = requestList[idContained] + "," + layerVec[i].layers;
					var arrayReq:Array = requestList[idContained].split("QUERY_LAYERS=");
					
					arrayReq[0]= arrayReq[0]+ "QUERY_LAYERS=" + layerVec[i].layers+",";
					arrayReq[1]= arrayReq[1]+ "," + layerVec[i].layers;
					
					requestList[idContained] = arrayReq[0] + arrayReq[1];
				} 
				else{
					request = "";
					request = layerVec[i].url+"?";
					
					//mandatory version parameter
					request += "VERSION=" + version + "&";
					
					//mandatory requestion parameter
					request += "REQUEST=GetFeatureInfo&";
					
					//mandatory map request part parameter
					//some parameter of the map should be know -> bbox / width / height / projection
					if(version == "1.3.0"){
						request += "CRS=" + this.map.projection.srsCode + "&";
					}
					else{
						request += "SRS=" + this.map.projection.srsCode + "&";
					}
					
					request += "WIDTH=" + this.map.width + "&";
					request += "HEIGHT=" + this.map.height + "&";
					
					request += "BBOX=" + this.map.extent.toString() + "&";			
					
					//info format is mandatory for 1.1.1 not for 1.3.0
					if(this._infoFormat != null || version == "1.3.0")
					{
						request += "INFO_FORMAT=" + this._infoFormat+"&";
					}
					
					//mandatory feature count parameter
					if(!isNaN(this.maxFeatures))
					{
						request += "FEATURE_COUNT=" + this._maxFeatures + "&";
					}
					//pix = pix.add(-map.x,-map.y);
					
					if(version == "1.3.0"){
						//mandatory i pixel coordinate
						request += "I=" + pix.x + "&"; 
						
						//mandatory j pixel coordinate
						request += "J=" + pix.y + "&";
					}
					else
					{
						//mandatory i pixel coordinate
						request += "X=" + pix.x + "&"; 
						
						//mandatory j pixel coordinate
						request += "Y=" + pix.y + "&";
					}
					
					//mandatory query layers parameter
					request += "QUERY_LAYERS=" + layerVec[i].layers+ "&";
					request += "LAYERS=" + layerVec[i].layers;
					requestList.push(request);
				}
			}
			
			return requestList;
		}
		
		/**
		 * Set the existing map to the handler
		 */
		override public function set map(value:Map):void 
		{
			if (value)
			{
				super.map = value;
				_clickHandler = new ClickHandler(value, false);
			}
		}
		
		override protected function registerListeners():void 
		{
			_clickHandler.active = true;
			_clickHandler.click = this.getInfoForClick;
			
			SiteContainer.dispatchEvent(new ClickActivatedEvent(ClickActivatedEvent.INFO_CLICK_ATIVADO));
		}
		

		override protected function unregisterListeners():void 
		{
			_clickHandler.active = false;
		}
		
		
		/**
		 * 
		 * Method called to send the request getfeatureinfo
		 * 
		 * @param p Position of the mouse cursor when the user clicked
		 * 
		 */
		private function getInfoForClick(p:Pixel):void 
		{
			//build the request string
			var req:Vector.<String> = this.prepareRequest(p);
			var reqLength:Number = req.length;
			for (var i:Number=0; i<reqLength; ++i){
				// request data
				if(_request) {
					_request.destroy();
				}
				_request = new XMLRequest(req[i], this.handleResponse);
				_request.proxy = map.proxy;
				_request.send();
			}
		}
		
		/**
		 * Read the incoming response from the server
		 * 
		 */
		private function handleResponse(event:Event):void 
		{
			var loader:URLLoader = event.target as URLLoader;
			var gmlformat:GMLFormat = new GMLFormat(null,new HashMap());
			
			gmlformat.version = "2.1.1";
			gmlformat.asyncLoading = false;
			var data:Object = loader.data as Object;
			var ret:Object = gmlformat.read(data);
//			function dispatchIfoEvent():void
//			{
				//var feature:Vector.<Feature> = (ret as Vector.<Feature>);
				//this.map.dispatchEvent(new GetFeatureInfoEvent(GetFeatureInfoEvent.GET_FEATURE_INFO_DATA, ret));
				SiteContainer.dispatchEvent(new GetFeatureInfoEvent(GetFeatureInfoEvent.GET_FEATURE_INFO_DATA, ret));
//			}
		}
		
		
		/**
		 * Value of the feature_count parameter of the getfeatureinfo request
		 */
		public function set maxFeatures(maxFeatures:Number):void 
		{
			this._maxFeatures = maxFeatures;
		}
		/**
		 * @private
		 */
		public function get maxFeatures():Number{
			return this._maxFeatures
		}
		
		/**
		 * Indicates if the getFeatureInfo request should imply only the first visible wms layer or not
		 */
		public function get drillDown():Boolean
		{
			return _drillDown;
		}
		/**
		 * @private
		 */
		public function set drillDown(value:Boolean):void
		{
			_drillDown = value;
		}
		
		/**
		 * get the value of the Info_format paramater of the getFeatureInfo request 
		 */
		public function get infoFormat():String
		{
			return _infoFormat;
		}
		/**
		 * @private
		 */
		public function set infoFormat(value:String):void
		{
			_infoFormat = value;
		}
		
		/**
		 * get the value of the Query_layers paramater of the getFeatureInfo request 
		 */
		public function get layers():String
		{
			return _layers;
		}
		/**
		 * @private
		 */
		public function set layers(value:String):void
		{
			_layers = value;
		}	
	}
}