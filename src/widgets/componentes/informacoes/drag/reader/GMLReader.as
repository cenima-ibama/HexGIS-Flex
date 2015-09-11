package widgets.componentes.informacoes.drag.reader
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.utils.clearInterval;
	import flash.utils.getQualifiedClassName;
	import flash.utils.getTimer;
	import flash.utils.setInterval;
	import flash.xml.XMLNode;
	
	import mx.controls.Alert;
	import mx.utils.ObjectUtil;
	
	import org.openscales.core.basetypes.maps.HashMap;
	import org.openscales.core.feature.Feature;
	import org.openscales.core.feature.LineStringFeature;
	import org.openscales.core.feature.MultiLineStringFeature;
	import org.openscales.core.feature.MultiPointFeature;
	import org.openscales.core.feature.MultiPolygonFeature;
	import org.openscales.core.feature.PointFeature;
	import org.openscales.core.feature.PolygonFeature;
	import org.openscales.core.format.Format;
	import org.openscales.core.format.gml.parser.GML2;
	import org.openscales.core.format.gml.parser.GML321;
	import org.openscales.core.format.gml.parser.GMLParser;
	import org.openscales.core.utils.Util;
	import org.openscales.geometry.Geometry;
	import org.openscales.geometry.ICollection;
	import org.openscales.geometry.LineString;
	import org.openscales.geometry.LinearRing;
	import org.openscales.geometry.MultiLineString;
	import org.openscales.geometry.MultiPoint;
	import org.openscales.geometry.MultiPolygon;
	import org.openscales.geometry.Point;
	import org.openscales.geometry.Polygon;
	import org.openscales.geometry.basetypes.Bounds;
	import org.openscales.proj4as.Proj4as;
	import org.openscales.proj4as.ProjPoint;
	import org.openscales.proj4as.ProjProjection;
	
	import widgets.componentes.alerta.Alerta;
	import widgets.componentes.informacoes.drag.reader.NewGML311;
	
	/**
	 * Read/Write GML. Supports the GML simple features profile.
	 */
	public class GMLReader extends Format
	{
		
		protected var _gmlns:String = "http://www.opengis.net/gml";
		
		protected var _gmlprefix:String = "gml";
		
		private var _extractAttributes:Boolean = true;
		
		private var _dim:Number;
		
		private var _onFeature:Function;
		
		private var _featuresids:HashMap;
		
		private var projectionxml:String = "srsName=\"http://www.opengis.net/gml/srs/epsg.xml#4326\"";
		
		private var _version:String = "2.1.1";
		
		private var _gmlParser:GMLParser = null;
		
		private var gml:Namespace = null;
		
		
		private var xmlString:String;
		private var sXML:String;
		
		private var lastInd:int    = 0;
		//fps
		private var allowedTime:Number = 10;
		private var startTime:Number = 0;
		private var savedIndex:Number = 0;
		private var sprite:Sprite = new Sprite();
		
		private var _asyncLoading:Boolean = true;
		/**
		 * GMLFormat constructor
		 *
		 * @param onFeature method called when after a feature has been parsed (signature: function onFeature(f:Feature):void)
		 * @param featuresids
		 * @param extractAttributes
		 *
		 */
		public function GMLReader(onFeature:Function, featuresids:HashMap, extractAttributes:Boolean = true) {
			this.extractAttributes = extractAttributes;
			this._onFeature=onFeature;
			this._featuresids = featuresids;
		}
		
		/**
		 * Read data
		 *
		 * @param data data to read/parse.
		 *
		 * @return features.
		 */
		override public function read(data:Object):Object
		{
			if(!this._asyncLoading || this._version!="2.1.1")
			{
				var dataXML:XML = new XML(data);
				var features:XMLList;				
			}
			
			var lonlat:Boolean = true;
			var alerta:Alerta;
			
			switch (this._version) 
			{
				case "2.1.1":
					if(!this._gmlParser || !(this._gmlParser is GML2))
					{
						this._gmlParser = new GML2();
					}
					if(!this._asyncLoading)
						features = dataXML..*::featureMember;
					//featureMember
					break;
				case "3.1.1":
					//lonlat = this.externalProjection.lonlat;
					if(!this._gmlParser || !(this._gmlParser is NewGML311))
					{
						this._gmlParser = new NewGML311();
					}
					//featureMembers
					//if(!this._asyncLoading) {
					features = dataXML..*::featureMembers;
					dataXML = features[0];
					
					if (dataXML)
						features = dataXML.children();
					//}
					break;
				case "3.2.1":
					//lonlat = this.externalProjection.lonlat;
					if(!this._gmlParser || !(this._gmlParser is GML321))
					{
						this._gmlParser = new GML321();
					}
					//members
					//if(!this._asyncLoading) {
					features = dataXML..*::member;
					//}
					break;
				default:
					return null;
			}
			
			this._gmlParser.parseExtractAttributes = this.extractAttributes;
			var retFeatures:Vector.<Feature> = null;
			if(this._asyncLoading && this._version=="2.1.1" && this._onFeature!=null)
			{
				this.xmlString = data as String;
				data = null;
				if(this.xmlString.indexOf(this._gmlParser.sFXML)!=-1)
				{
					var end:int = this.xmlString.indexOf(">",this.xmlString.indexOf(">")+1)+1;
					this.sXML = this.xmlString.slice(0,end);
					this.dim = 2;
					this.sprite.addEventListener(Event.ENTER_FRAME, this.readTimer);
				} 
				else
				{
					this.xmlString = null;
				}
			} 
			else 
			{
				retFeatures = new Vector.<Feature>();
				var feature:Feature;
				for each( dataXML in features) 
				{
					feature = this._gmlParser.parseFeature(dataXML,lonlat);
					
					if(feature) 
					{
						feature.geometry.projection = this.externalProjection;
						
						retFeatures.push(feature);
						if(this._onFeature!=null)
							this._onFeature(feature);
					}
					else
					{
						if (!alerta)
						{
							alerta = new Alerta();
							alerta.exibirErro("Erro no arquivo recebido.");
						}
					}
				}
			}
			return retFeatures;
		}
		
		/**
		 * 
		 * @param event
		 * 
		 */
		private function readTimer(event:Event):void {
			startTime = getTimer();
			if(this.xmlString==null) {
				this.sprite.removeEventListener(Event.ENTER_FRAME,this.readTimer);
				return;
			}
			this.lastInd = this.xmlString.indexOf(this._gmlParser.sFXML,this.lastInd);
			if(this.lastInd==-1) {
				this.sprite.removeEventListener(Event.ENTER_FRAME,this.readTimer);
				return;
			}
			var xmlNode:XML;
			var feature:Feature;
			var end:int;		
			
			
			while(this.lastInd!=-1) {
				if (getTimer() - startTime > allowedTime){
					return;
				}
				
				end = this.xmlString.indexOf(this._gmlParser.eFXML,this.lastInd);
				if(end<0)
					break;
				xmlNode = new XML( this.sXML + this.xmlString.substr(this.lastInd,end-this.lastInd) + this._gmlParser.eXML )
				this.lastInd = this.xmlString.indexOf(this._gmlParser.sFXML,this.lastInd+1);
				switch (this._version) {
					case "2.1.1":
						if(this._featuresids.containsKey((xmlNode..@fid) as String))
							continue;
						break;
					default:
						continue;
				}
				
				feature = this._gmlParser.parseFeature(xmlNode);
				if (feature) {
					this._onFeature(feature);
				}
			}
			
			if(this.lastInd==-1) {
				this.sprite.removeEventListener(Event.ENTER_FRAME,this.readTimer);
				this.xmlString = null;
				this.sXML = null;
				return;
			}
		}
		
		//Getters and Setters
		
		public function get extractAttributes():Boolean {
			return this._extractAttributes;
		}
		
		public function set extractAttributes(value:Boolean):void {
			this._extractAttributes = value;
		}
		
		public function get dim():Number {
			return this._dim;
		}
		
		public function set dim(value:Number):void {
			this._dim = value;
		}
		
		/**
		 * Indicates the GML version
		 */
		public function get version():String {
			return this._version;
		}
		/**
		 * @Private
		 */
		public function set version(value:String):void {
			this._version = value;
		}
		
		public function get asyncLoading():Boolean
		{
			return _asyncLoading;
		}
		
		public function set asyncLoading(value:Boolean):void
		{
			_asyncLoading = value;
		}
	}
}

