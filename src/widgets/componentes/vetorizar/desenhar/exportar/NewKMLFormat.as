package widgets.componentes.vetorizar.desenhar.exportar
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.display.Sprite;
	import flash.events.Event;
	
	import mx.controls.Alert;
	
	import org.openscales.core.basetypes.maps.HashMap;
	import org.openscales.core.feature.CustomMarker;
	import org.openscales.core.feature.Feature;
	import org.openscales.core.feature.LabelFeature;
	import org.openscales.core.feature.LineStringFeature;
	import org.openscales.core.feature.MultiLineStringFeature;
	import org.openscales.core.feature.MultiPointFeature;
	import org.openscales.core.feature.MultiPolygonFeature;
	import org.openscales.core.feature.PointFeature;
	import org.openscales.core.feature.PolygonFeature;
	import org.openscales.core.format.Format;
	import org.openscales.core.layer.Layer;
	import org.openscales.core.layer.VectorLayer;
	import org.openscales.core.request.DataRequest;
	import org.openscales.core.style.Rule;
	import org.openscales.core.style.Style;
	import org.openscales.core.style.fill.Fill;
	import org.openscales.core.style.fill.SolidFill;
	import org.openscales.core.style.marker.Marker;
	import org.openscales.core.style.marker.WellKnownMarker;
	import org.openscales.core.style.stroke.Stroke;
	import org.openscales.core.style.symbolizer.LineSymbolizer;
	import org.openscales.core.style.symbolizer.PointSymbolizer;
	import org.openscales.core.style.symbolizer.PolygonSymbolizer;
	import org.openscales.core.style.symbolizer.Symbolizer;
	import org.openscales.core.utils.Trace;
	import org.openscales.geometry.Geometry;
	import org.openscales.geometry.LabelPoint;
	import org.openscales.geometry.LineString;
	import org.openscales.geometry.LinearRing;
	import org.openscales.geometry.MultiLineString;
	import org.openscales.geometry.MultiPoint;
	import org.openscales.geometry.MultiPolygon;
	import org.openscales.geometry.Point;
	import org.openscales.geometry.Polygon;
	import org.openscales.geometry.basetypes.Location;
	
	import widgets.componentes.ibama.feature.IbamaLineStringFeature;
	import widgets.componentes.ibama.feature.IbamaPointFeature;
	import widgets.componentes.ibama.feature.IbamaPolygonFeature;
	
	/**
	 * Read KML 2.0 and 2.2 file format.
	 */
	
	public class NewKMLFormat extends Format
	{
		[Embed(source="/assets/images/popups/marker-blue.png")]
		private var _defaultImage:Class;
		
		private namespace opengis="http://www.opengis.net/kml/2.2";
		private namespace google="http://earth.google.com/kml/2.0";
		private var _proxy:String;
		private var _externalImages:Object = {};
		private var _images:Object = {};
		
		// features
		private var iconsfeatures:Vector.<Feature> = new Vector.<Feature>();
		private var linesfeatures:Vector.<Feature> = new Vector.<Feature>();
		private var labelfeatures:Vector.<Feature> = new Vector.<Feature>();
		private var polygonsfeatures:Vector.<Feature> = new Vector.<Feature>();
		// styles
		private var lineStyles:Object = new Object();
		private var pointStyles:Object = new Object();
		private var polygonStyles:Object = new Object();
		
		private var _userDefinedStyle:Style = null;
		
		//items to exclude from extendedData
		private var _excludeFromExtendedData:Array = new Array("id", "name", "description", "popupContentHTML", "label");
		
		public function NewKMLFormat() 
		{
		}
		
		/**
		 * Read data
		 *
		 * @param data data to read/parse
		 * @return array of features (polygons, lines and points)
		 * @call loadStyles (only if the user does not set a style)
		 * @call loadPlacemarks (to extract the geometries)
		 */
		override public function read(data:Object):Object 
		{
			var dataXML:XML = data as XML;
			
			use namespace google;
			use namespace opengis;
			
			if(!userDefinedStyle)
			{
				var styles:XMLList = dataXML..Style;
				loadStyles(styles.copy());
			}
			
			var placemarks:XMLList = dataXML..Placemark;
			loadPlacemarks(placemarks);
			
			var _features:Vector.<Feature> = polygonsfeatures.concat(linesfeatures, iconsfeatures, labelfeatures);
			return _features;
		}
		
		
		/**
		 * return the RGB color of a kml:color
		 */
		private function KMLColorsToRGB(data:String):Number 
		{
			var color:String = data.substr(6,2);
			color = color+data.substr(4,2);
			color = color+data.substr(2,2);
			return parseInt(color,16);
		}
		
		/**
		 * Return the alpha part of a kml:color
		 */
		private function KMLColorsToAlpha(data:String):Number 
		{
			return parseInt(data.substr(0,2),16)/255;
		}
		
		private function updateImages(e:Event):void
		{
			var _url:String = e.target.loader.name;
			var _imgs:Array = _images[_url];
			_images[_url] = null;
			var _bm:Bitmap = Bitmap(_externalImages[_url].loader.content); 
			
			if (_bm != null)
			{
				var _bmd:BitmapData = _bm.bitmapData;
				for each(var _img:Sprite in _imgs)
				{
					var _image:Bitmap = new Bitmap(_bmd.clone());
					//_image.x = -_image.width/2;
					//_image.y = -_image.height;
					_img.addChild(_image);
				}
			}
		}
		
		private function updateImagesError(e:Event):void 
		{
			var _url:String = e.target.loader.name;
			var _imgs:Array = _images[_url];
			_images[_url] = null;
			_externalImages[_url] = null;
			
			for each(var _img:Sprite in _imgs)
			{
				var _marker:Bitmap = new _defaultImage();
				_marker.y = -_marker.height;
				_marker.x = -_marker.width/2;
				_img.addChild(_marker);
			}
		}
		
		/**
		 * load styles
		 * This function is called only if the user does not set the userDefinedStyle attribute
		 * @calls KMLColorsToRGB
		 * @calls KMLColorsToAlpha
		 */
		private function loadStyles(styles:XMLList):void
		{	
			use namespace google;
			use namespace opengis;
			
			var styleMap:HashMap = null;
			for each(var style:XML in styles) 
			{
				var id:String = "";
				if(style.@id=="")
				{
					continue;
				}
				
				id = "#"+style.@id.toString();
				
				styleMap = getStyle(style);
				
				if(styleMap.containsKey("IconStyle"))
				{
					pointStyles[id] = styleMap.getValue("IconStyle");
					pointStyles[id].name = id;
				}
				
				if(styleMap.containsKey("LineStyle")) 
				{
					lineStyles[id] = styleMap.getValue("LineStyle");
					lineStyles[id].name = id;
				}
				
				if(styleMap.containsKey("PolyStyle"))
				{
					polygonStyles[id] = styleMap.getValue("PolyStyle");
					polygonStyles[id].name = id;
				}
				
			}
		}
		
		public function getStyle(style:XML):HashMap 
		{
			var _styles:HashMap = new HashMap();
			if(style == null)
				return _styles;
			
			var _style:Style = null;
			var styleList:XMLList = style.children();
			var numberOfStyles:uint = styleList.length();
			var i:uint;
			
			for(i = 0; i < numberOfStyles; i++)
			{
				if(styleList[i].localName() == "IconStyle") 
				{
					var iconStyle:XMLList = styleList[i]..*::Icon;
					var href:XMLList = null;
					if(iconStyle.length() > 0)
					{
						href = iconStyle[0]..*::href;		
					}
					var obj:Object = new Object();
					obj["icon"] = null
					if(href) 
					{
						try {
							var _url:String = href[0].toString();
							var _req:DataRequest;
							_req = new DataRequest(_url, updateImages, updateImagesError);
							_req.proxy = this._proxy;
							//_req.security = this._security; // FixMe: should the security be managed here ?
							_req.send();
							_externalImages[_url] = _req;
							obj["icon"] = _url;
							_images[_url] = new Array();
						} catch(e:Error) {
							obj["icon"] = null;
						}
					}
					
					var colorStyle:XMLList = styleList[i]..*::color;
					if(colorStyle.length() > 0) 
					{
						obj["color"] = KMLColorsToRGB(colorStyle[0].toString());
						obj["alpha"] = KMLColorsToAlpha(colorStyle[0].toString());
					}
					
					var scaleStyle:XMLList = styleList[i]..*::scale;
					if(scaleStyle.length() > 0)
						obj["scale"] = Number(scaleStyle[0].toString());
					
					var headingStyle:XMLList = styleList[i]..*::heading;
					if(headingStyle.length() > 0) //0 to 360°
						obj["rotation"] = Number(headingStyle[0].toString());
					// TODO implement offset support + rotation effect
					
					_styles.put("IconStyle",obj);
				}
				
				if(styleList[i].localName() == "LineStyle") 
				{
					var Lcolor:Number = 0x96A621;
					var Lalpha:Number = 1;
					var Lwidth:Number = 1;
					
					var lineColor:XMLList = styleList[i]..*::color;
					if(lineColor.length() > 0) 
					{
						Lcolor = KMLColorsToRGB(lineColor[0].toString());
						Lalpha = KMLColorsToAlpha(lineColor[0].toString());
					}
					
					var lineWidth:XMLList = styleList[i]..*::width;
					if(lineWidth.length() > 0) 
					{
						Lwidth = parseInt(lineWidth[0].toString());
					}
					var Lrule:Rule = new Rule();
					Lrule.symbolizers.push(new LineSymbolizer(new Stroke(Lcolor, Lwidth, Lalpha)));
					Lrule.symbolizers.push(new LineSymbolizer(new Stroke(Lcolor, Lwidth, Lalpha)));
					_style = new Style();
					_style.rules.push(Lrule);
					_styles.put("LineStyle",_style);
				}
				
				if(styleList[i].localName() == "PolyStyle") 
				{
					var Pcolor:Number = 0x96A621;
					var Palpha:Number = 1;
					var Pfill:SolidFill = new SolidFill();;
					Pfill.color = Pcolor;
					Pfill.opacity = Palpha;
					var Prule:Rule;
					var Pstroke:Stroke = new Stroke();
					Pstroke.width = 1;
					Pstroke.color = Pcolor;
					
					var polyColor:XMLList = styleList[i]..*::color;
					if(polyColor.length() > 0) 
					{
						//the style of the polygon itself
						Pcolor = KMLColorsToRGB(polyColor[0].toString());
						Palpha = KMLColorsToAlpha(polyColor[0].toString());
						Pfill = new SolidFill();
						Pfill.color = Pcolor;
						Pfill.opacity = Palpha;
						Pstroke.color = Pcolor;
					}
					
					var Pps1:PolygonSymbolizer;
					var Pps2:PolygonSymbolizer;
					
					var polyFill:XMLList = styleList[i]..*::fill;
					//if the polygon shouldn't be filled
					if(polyFill.length() && polyFill[0].toString() == "0") {
						Pfill = null;
					}
					
					var polyOutline:XMLList = styleList[i]..*::outline;
					//the style of the outline (the contour of the polygon)
					if(polyOutline.length() == 0 || polyOutline[0].toString() == "1") 
					{
						//change the color of the polygon outline
						var outlineStroke:Stroke = new Stroke();
						outlineStroke.color = Lcolor;
						outlineStroke.width = Lwidth;
						Pps2 = new PolygonSymbolizer(null, outlineStroke);
					}
					else
					{
						Pps2 = new PolygonSymbolizer(null, Pstroke);
					}
					
					Pps1 = new PolygonSymbolizer(Pfill, Pstroke);
					Prule = new Rule();
					Prule.symbolizers.push(Pps1);
					Prule.symbolizers.push(Pps2);
					_style = new Style();
					_style.rules.push(Prule);
					_styles.put("PolyStyle",_style);
				}	
			}
			return _styles;
		}
		
		/**
		 * Load placemarks
		 * @param a list of placemarks
		 * @call loadLineString
		 * @call loadPolygon
		 */
		private function loadPlacemarks(placemarks:XMLList):void 
		{
			use namespace google;
			use namespace opengis;
			
			for each(var placemark:XML in placemarks) 
			{
				var coordinates:Array;
				var point:Point;
				var htmlContent:String = "";
				var attributes:Object = new Object();
				var hmLocalStyle:HashMap = new HashMap();
				var localStyles:XMLList = placemark..*::Style;
				var attributeName:String = "";
				
				//there can be a Style defined inside the Placemark element
				//in this case, there is no styleUrl element and the Style element doesn't have an ID
				if(localStyles.length()== 1) 
				{
					hmLocalStyle = this.getStyle(localStyles[0]);
				}
				
				if(placemark.name != undefined) 
				{
					attributes["name"] = placemark.name.text();
					htmlContent = htmlContent + "<b>" + placemark.name.text() + "</b><br />";   
				}
				
				if(placemark.description != undefined) 
				{
					attributes["description"] = placemark.description.text();
					htmlContent = htmlContent + placemark.description.text() + "<br />";
				}
				
				if(placemark.id != undefined) 
				{
					attributes["id"] = placemark.id.text();
					htmlContent = htmlContent + placemark.description.text() + "<br />";
				}
				
				for each(var extendedData:XML in placemark.ExtendedData.Data) 
				{	
					if(extendedData.displayName.text() != undefined)
					{
						attributeName = extendedData.displayName.text();
						if(excludeFromExtendedData.indexOf(attributeName) < 0)
						{
							attributes[attributeName] = extendedData.value.text();
						}
					} 
					else
					{
						attributeName = extendedData.@name;
						if(excludeFromExtendedData.indexOf(attributeName) < 0) 
						{
							attributes[attributeName] = extendedData.value.text();
						}
					}
					
					htmlContent = htmlContent + "<b>" + attributeName + "</b> : " + extendedData.value.text() + "<br />";
				}
				
				for each(var simpleExtendedData:XML in placemark.ExtendedData.SchemaData.SimpleData) 
				{	
					attributeName = simpleExtendedData.@name;
					if(excludeFromExtendedData.indexOf(attributeName) < 0)
					{
						attributes[attributeName] = simpleExtendedData.text();
					}
					
					htmlContent = htmlContent + "<b>" + attributeName + "</b> : " + simpleExtendedData.text() + "<br />";
				}
				attributes["popupContentHTML"] = htmlContent;	
				var _id:String;
				
				if (placemark.LineString != undefined) // LineStrings
				{
					var _Lstyle:Style = null;
					if (userDefinedStyle)
					{
						_Lstyle = userDefinedStyle;	
					}
					else
					{
						_Lstyle = Style.getDefaultLineStyle();
					}
					
					if(hmLocalStyle.containsKey("LineStyle")) 
					{
						_Lstyle = hmLocalStyle.getValue("LineStyle");
					}
					else if (placemark.styleUrl != undefined)
					{
						_id = placemark.styleUrl.text();
						if(lineStyles[_id] != undefined)
							_Lstyle = lineStyles[_id];
					}
					
					linesfeatures.push(new LineStringFeature(loadLineString(placemark),attributes,_Lstyle));
				}
				else if (placemark.Polygon != undefined) //Polygons
				{
					var _Pstyle:Style = null;
					
					if(userDefinedStyle)
					{
						_Pstyle = userDefinedStyle;
					}
					else 
					{
						_Pstyle = Style.getDefaultSurfaceStyle();
						if (hmLocalStyle.containsKey("PolyStyle")) 
						{
							_Pstyle = hmLocalStyle.getValue("PolyStyle");
						}
						else if (placemark.styleUrl != undefined)
						{
							_id = placemark.styleUrl.text();
							if(polygonStyles[_id] != undefined)
								_Pstyle = polygonStyles[_id];
						}
					}
					
					polygonsfeatures.push(new PolygonFeature(loadPolygon(placemark),attributes,_Pstyle));
				}
				else if (placemark.MultiGeometry != undefined) //MultiGeometry  
				{
					var numberOfGeom:uint;
					var i:uint;
					var components:Vector.<Geometry>;
					var geomStyle:Style = null; 
					
					var multiG:XML = placemark..*::MultiGeometry[0];
					var lines:XMLList = multiG..*::LineString;
					var polygons:XMLList = multiG..*::Polygon;
					var points:XMLList = multiG..*::Point;
					
					//multiLineString
					if(lines.length() > 0)
					{
						numberOfGeom = lines.length();
						components = new Vector.<Geometry>;
						for(i = 0; i < numberOfGeom; i++)
						{
							var LineCont:XML = new XML("<container></container>");
							LineCont.appendChild(lines[i]);
							components.push(loadLineString(LineCont));	
						}
						if(userDefinedStyle)
						{
							geomStyle = userDefinedStyle;	
						}
						else 
						{
							geomStyle = Style.getDefaultLineStyle();
							if (hmLocalStyle.containsKey("LineStyle")) 
							{
								geomStyle = hmLocalStyle.getValue("LineStyle");
							}
							else if (placemark.styleUrl != undefined)
							{
								_id = placemark.styleUrl.text();
								if (lineStyles[_id] != undefined)
								{
									geomStyle = lineStyles[_id];
								}
							}
						}
						linesfeatures.push(new MultiLineStringFeature(new MultiLineString(components), attributes,geomStyle));
					}
					
					//multiPolygon
					if (polygons.length() > 0)	
					{
						numberOfGeom = polygons.length();
						components = new Vector.<Geometry>;
						for(i = 0; i < numberOfGeom; i++)
						{
							var PolyCont:XML = new XML("<container></container>");
							PolyCont.appendChild(polygons[i]);
							components.push(loadPolygon(PolyCont));	
						}
						if(userDefinedStyle)
						{
							geomStyle = userDefinedStyle;	
						} 
						else 
						{
							geomStyle = Style.getDefaultSurfaceStyle();
							if(hmLocalStyle.containsKey("PolyStyle")) {
								geomStyle = hmLocalStyle.getValue("PolyStyle");
							}
							else if(placemark.styleUrl != undefined)
							{
								_id = placemark.styleUrl.text();
								if(lineStyles[_id] != undefined)
									geomStyle = lineStyles[_id];
							}
						}
						
						polygonsfeatures.push(new MultiPolygonFeature(new MultiPolygon(components),
							attributes,geomStyle));
					}
					//multiPoint
					//only one icon can be referenced in an IconStyle so icons are not supported for multipoints
					if (points.length() > 0)
					{
						var pointCoords:Vector.<Number> = new Vector.<Number>;
						numberOfGeom = points.length();
						
						var coordStr:String;
						for (i = 0; i < numberOfGeom; i++)							
						{
							coordStr = (points[i]..*::coordinates as Object).toString();
							
							coordinates =  coordStr.split(",");
							pointCoords.push(Number(coordinates[0]));
							pointCoords.push(Number(coordinates[1]));
						}
						
						var multiPoint:MultiPoint = new MultiPoint(pointCoords);
						
						if (userDefinedStyle)
						{
							iconsfeatures.push(new MultiPointFeature(multiPoint,attributes,userDefinedStyle));
						}
						else if (hmLocalStyle.containsKey("PointStyle")) 
						{
							//iconsfeatures.push(getPointFeature(point,hmLocalStyle.getValue("PointStyle"),attributes));
							iconsfeatures.push(new MultiPointFeature(multiPoint,attributes,hmLocalStyle.getValue("PointStyle")));
						}
						else if (placemark.styleUrl != undefined) 
						{
							_id = placemark.styleUrl.text();
							
							if (pointStyles[_id]!=undefined) 
							{
								//iconsfeatures.push(getPointFeature(point,pointStyles[_id],attributes));
								iconsfeatures.push(new MultiPointFeature(multiPoint,attributes,pointStyles[_id]));
							}
							else 
							{
								iconsfeatures.push(new MultiPointFeature(multiPoint, attributes, Style.getDefaultPointStyle()));
							}
						}
						else
						{
							iconsfeatures.push(new MultiPointFeature(multiPoint, attributes, Style.getDefaultPointStyle()));
						}
					}
				}
				else if (placemark.Point != undefined)
				{
					coordinates = placemark.Point.coordinates.text().split(",");
					
					//Maybe it is a label
					var isLabel:Boolean = false;
					var textLabel:String = "";
					for each(var extData:XML in placemark.ExtendedData.Data) 
					{	
						if(extData.@name == "label") {
							isLabel = true
							textLabel = extData.value.text();
						}
					}
					
					if (isLabel)
					{
						var l:LabelPoint = new LabelPoint(textLabel,coordinates[0], coordinates[1]);
						labelfeatures.push(new LabelFeature(l,attributes));
					} 
					else
					{
						point = new Point(coordinates[0], coordinates[1]);
						
						if ((this.internalProjection != null) && (this.externalProjection != null))
						{
							point.projection = this.externalProjection;
							point.transform(this.internalProjection);
						}
						if(userDefinedStyle) {
							iconsfeatures.push(new PointFeature(point, attributes, userDefinedStyle));
						} 
						else if(placemark.styleUrl != undefined || hmLocalStyle.containsKey("PointStyle")) 
						{
							var objStyle:Object = null;
							if(hmLocalStyle.containsKey("PointStyle")) 
							{
								objStyle = hmLocalStyle.getValue("PointStyle");
							} 
							else 
							{
								_id = placemark.styleUrl.text();
								if(pointStyles[_id]!=undefined)
									objStyle = pointStyles[_id];
							}
							
							if(objStyle) 
							{ // style
								iconsfeatures.push(getPointFeature(point,objStyle,attributes));
							}
							else // no matching style
								iconsfeatures.push(new PointFeature(point, attributes, Style.getDefaultPointStyle()));
						}
						else // no style
							iconsfeatures.push(new PointFeature(point, attributes, Style.getDefaultPointStyle()));
					}
				}
			}
		}
		
		private function getPointFeature(point:Point, objStyle:Object, attributes:Object):Feature {
			if(!objStyle)
				return null;
			var loc:Location;
			if(objStyle["icon"]!=null) 
			{ // style with icon
				var _icon:String = objStyle["icon"];
				var customMarker:CustomMarker;
				if(_images[_icon]!=null) 
				{ // image not loaded so we will wait for it
					var _img:Sprite = new Sprite();
					_images[_icon].push(_img);
					loc = new Location(point.x,point.y);
					customMarker = CustomMarker.createDisplayObjectMarker(_img,loc,attributes,0,0);
				}
				else if(_externalImages[_icon]!=null) 
				{ // image already loaded, we copy the loader content
					var Image:Bitmap = new Bitmap(new Bitmap(_externalImages[_icon].loader.content).bitmapData.clone());
					Image.y = -Image.height;
					Image.x = -Image.width/2;
					customMarker = CustomMarker.createDisplayObjectMarker(Image,new Location(point.x,point.y),attributes,0,0);
				}
				else 
				{ // image failed to load
					var _marker:Bitmap = new _defaultImage();
					_marker.y = -_marker.height;
					_marker.x = -_marker.width/2;
					customMarker = CustomMarker.createDisplayObjectMarker(_marker,new Location(point.x,point.y),attributes,0,0);
				}
				return customMarker;
			}
			else 
			{ // style without icon
				if(userDefinedStyle)
					return new PointFeature(point, attributes,userDefinedStyle);
				else
					return new PointFeature(point, attributes, 
						this.loadPointStyleWithoutIcon(objStyle));
			}
		}
		
		
		/**
		 * Parse point styles without icon
		 */ 
		
		private function loadPointStyleWithoutIcon(style:Object):Style
		{
			var pointStyle:Style;
			pointStyle = Style.getDefaultPointStyle();
			
			if(style["color"] != undefined)
			{
				var _fill:SolidFill = new SolidFill(style["color"], style["alpha"]);
				var _stroke:Stroke = new Stroke(style["color"], style["alpha"]);
				var _mark:WellKnownMarker = new WellKnownMarker(WellKnownMarker.WKN_SQUARE, _fill, _stroke);//the color of its stroke is the kml color
				var _symbolizer:PointSymbolizer = new PointSymbolizer();
				_symbolizer.graphic = _mark;
				var _rule:Rule = new Rule();
				_rule.symbolizers.push(_symbolizer);
				pointStyle = new Style();
				pointStyle.rules.push(_rule);
			}
			return pointStyle;
		}
		
		/**
		 * Parse LineStrings
		 */ 
		
		private function loadLineString(placemark:XML):LineString
		{
			var coordinates:Array;
			var point:Point;
			
			var lineNode:XML= placemark..*::LineString[0];
			XML.ignoreWhitespace = true;
			var lineData:String = lineNode..*::coordinates[0].toString();
			
			lineData = lineData.split("\n").join("");
			lineData = lineData.split("\t").join("");
			
			lineData = lineData.replace(/^\s*(.*?)\s*$/g, "$1");
			coordinates = lineData.split(" ");
			
			var points:Vector.<Number> = new Vector.<Number>();
			var coords:String;
			var coordsAr:Array
			
			for each (coords in coordinates)
			{
				coordsAr = coords.split(",");
				
				if (coordsAr.length < 2)
				{
					continue;
				}
				point = new Point(coordsAr[0].toString(), coordsAr[1].toString());
				
				if ((this.internalProjection != null) && (this.externalProjection != null))
				{
					point.projection = this.externalProjection;
					point.transform(this.internalProjection);
				}
				
				points.push(point.x);
				points.push(point.y);
			}
			
			var line:LineString = new LineString(points);	
			return line;
		}
		
		/**
		 * Parse Polygons
		 * @call loadPolygonData to parse the coordinates
		 */ 
		private function loadPolygon(placemark:XML):Polygon
		{
			var polygon:XML = placemark..*::Polygon[0];
			
			//exterior ring
			var outerBoundary:XML = polygon..*::outerBoundaryIs[0];
			var ring:XML = outerBoundary..*::LinearRing[0];
			
			var lines:Vector.<Geometry> = new Vector.<Geometry>(1);
			lines[0] = this.loadPolygonData(ring..*::coordinates.toString());
			
			//interior ring
			var innerBoundary:XML = polygon..*::innerBoundaryIs[0];
			if(innerBoundary) 
			{
				ring = innerBoundary..*::LinearRing[0] as XML;
				try 
				{
					lines.push(this.loadPolygonData((ring..*::coordinates as Object).toString()));
				}
				catch(e:Error) 
				{
				}
			}
			
			return new Polygon(lines);
		}
		
		/**
		 * Parse polygon coordinates
		 */ 
		private function loadPolygonData(_Pdata:String):LinearRing
		{
			_Pdata = _Pdata.split("\n").join("");
			_Pdata = _Pdata.replace(/^\s*(.*?)\s*$/g, "$1");
			var coordinates:Array = _Pdata.split(" ");
			var Ppoints:Vector.<Number> = new Vector.<Number>();
			var Pcoords:String;
			var _Pcoords:Array;
			var point:Point;
			
			for each(Pcoords in coordinates) 
			{
				_Pcoords = Pcoords.split(",");
				
				if (_Pcoords.length < 2)
				{
					continue;
				}
				
				point = new Point(_Pcoords[0].toString(), _Pcoords[1].toString());
				
				if ((this.internalProjection) != null && (this.externalProjection != null))
				{
					point.projection = this.externalProjection;
					point.transform(this.internalProjection);
				}
				
				Ppoints.push(point.x);
				Ppoints.push(point.y);
			}
			
			return new LinearRing(Ppoints);
		}
		
		/**
		 * Write data
		 *
		 * @param features the features to build into a KML file
		 * @return the KML file (xml format)
		 * @call buildStyleNode
		 * @call buildPlacemarkNode
		 * the supported features are pointFeatures, lineFeatures and polygonFeatures
		 */
		
		override public function write(features:Object):Object
		{
			//todo write multigeometries
			var i:uint;
			var kmlns:Namespace = new Namespace("kml","http://www.opengis.net/kml/2.2");
			var kmlFile:XML = new XML("<kml></kml>");
			kmlFile.addNamespace(kmlns);
			
			var doc:XML = new XML("<Document></Document>"); 
			kmlFile.appendChild(doc);
			
			var listOfFeatures:Vector.<Feature> = features as Vector.<Feature>;
			var numberOfFeat:uint = listOfFeatures.length;
			//build the style nodes first
			for(i = 0; i < numberOfFeat; i++)
			{
				if(listOfFeatures[i].style)
				{
					doc.appendChild(buildStyleNode(listOfFeatures[i],i));
				}
			}
			//build the placemarks
			for (i = 0; i < numberOfFeat; i++)
			{
				doc.appendChild(buildPlacemarkNode(listOfFeatures[i],i));
			}
			
			return kmlFile; 
		}
		
		/**
		 * @return a kml placemark
		 * @call buildPolygonNode
		 * @call buildCoordsAsString 
		 */
		private function buildPlacemarkNode(feature:org.openscales.core.feature.Feature,i:uint):XML
		{		
			var lineNode:XML;
			var pointNode:XML;
			var extendedData:XML = null;
			
			var placemark:XML = new XML("<Placemark></Placemark>");
			var att:Object = feature.attributes;
			
			placemark.appendChild(new XML("<id>" + feature.name + "</id>"));
			if (att.hasOwnProperty("name") && att["name"] != "") {
				placemark.appendChild(new XML("<name>" + att["name"] + "</name>"));
			}
			else {
				//since we build the styles first, the feature will have an id for sure
				placemark.appendChild(new XML("<name>" + feature.name + "</name>"));
			}
			
			placemark.appendChild(new XML("<styleUrl>#" + feature.name + "</styleUrl>"));
			
			if (att.hasOwnProperty("description"))
				placemark.appendChild(new XML("<description><![CDATA[" + att["description"] + "]]></description>"));
			
			var coords:String;
			if(feature is LineStringFeature)
			{
				lineNode = new XML("<LineString></LineString>");
				var line:LineString = (feature as LineStringFeature).lineString;
				coords = this.buildCoordsAsStringL(line.getcomponentsClone());
				if(coords.length != 0)
					lineNode.appendChild(new XML("<coordinates>" + coords + "</coordinates>"));
				placemark.appendChild(lineNode);
			}
			else if(feature is PolygonFeature)
			{
				var poly:Polygon = (feature as PolygonFeature).polygon;
				placemark.appendChild(this.buildPolygonNode(poly));
			}
			else if(feature is PointFeature)
			{
				pointNode = new XML("<Point></Point>");
				var point:Point = (feature as PointFeature).point;
				pointNode.appendChild(new XML("<coordinates>" + point.x + "," + point.y + "</coordinates>"));
				placemark.appendChild(pointNode);
			}
			else if(feature is LabelFeature)
			{
				pointNode = new XML("<Point></Point>");
				var label:LabelPoint = (feature as LabelFeature).labelPoint;
				pointNode.appendChild(new XML("<coordinates>" + label.x + "," + label.y + "</coordinates>"));
				placemark.appendChild(pointNode);
			}
			else if(feature is MultiPointFeature || feature is MultiLineStringFeature || feature is MultiPolygonFeature)
			{
				var multiGNode:XML = new XML("<MultiGeometry></MultiGeometry>");
				if(feature is MultiPointFeature)
				{
					var points:Vector.<Point> = (feature as MultiPointFeature).points.toVertices();
					var numberOfPoints:uint = points.length;
					for(i = 0; i < numberOfPoints; i++)
					{
						pointNode =	new XML("<Point></Point>");
						pointNode.appendChild(new XML("<coordinates>" + point.x + "," + point.y + "</coordinates>"));
						multiGNode.appendChild(pointNode);
						
					}
				}
				else if (feature is MultiLineStringFeature)
				{
					var lines:Vector.<Geometry> = (feature as MultiLineStringFeature).lineStrings.getcomponentsClone();
					var numberOfLines:uint = lines.length;
					for(i = 0; i < numberOfLines; i++)
					{
						var Line:LineString = lines[i] as LineString;
						coords = this.buildCoordsAsStringL(Line.getcomponentsClone());
						lineNode =	new XML("<LineString></LineString>");
						lineNode.appendChild(new XML("<coordinates>" + coords + "</coordinates>"));
						multiGNode.appendChild(lineNode);
						
					}	
				}
				else//multiPolygon
				{
					
				}
				placemark.appendChild(multiGNode);
				
				
			}
			
			//Donnees attributaires
			var data:XML;
			var displayName:XML;
			var value:XML;
			
			var i:uint;
			var j:uint;
			
			var key:String;

			if ((feature is IbamaPointFeature) ||
				(feature is IbamaLineStringFeature) ||
				(feature is IbamaPolygonFeature))
			{
				extendedData =	new XML("<ExtendedData></ExtendedData>");
				
				for (key in feature.attributes)
				{
					data = new XML("<Data name=\"attribute" + i + "\"></Data>");
					displayName = new XML("<displayName>" + key + "</displayName>");
					value = new XML("<value>" + String(feature.attributes[key]) + "</value>");
					data.appendChild(displayName);
					data.appendChild(value);
					extendedData.appendChild(data);
				}
			}
			else if(feature.layer || feature is LabelFeature)
			{
				var auxVect:VectorLayer = feature.layer;
				j = auxVect.attributesId.length;
				
				
				if ((j > 0) || (feature is LabelFeature)) 
				{
					extendedData =	new XML("<ExtendedData></ExtendedData>");
					
					//if feature is a Label, register the value
					if (feature is LabelFeature)
					{	
						var l:LabelPoint = (feature as LabelFeature).labelPoint;
						data = new XML("<Data name=\"label\"></Data>");
						value = new XML("<value>" + l.label.text + "</value>");
						data.appendChild(value);
						extendedData.appendChild(data);
						
						data = new XML("<Data name=\"rotationZ\"></Data>");
						value = new XML("<value>" + l.label.rotationZ + "</value>");
						data.appendChild(value);
						extendedData.appendChild(data);
					}
					
					for(i = 0 ;i<j;++i) 
					{
						key = feature.layer.attributesId[i];
						
						//everything except name and description
						if(excludeFromExtendedData.indexOf(key) < 0)
						{
							data = new XML("<Data name=\"attribute" + i + "\"></Data>");
							displayName = new XML("<displayName>" + key + "</displayName>");
							value = new XML("<value>" + att[key] + "</value>");
							data.appendChild(displayName);
							data.appendChild(value);
							extendedData.appendChild(data);
						}
					}
				}
			}
			
			if (extendedData != null)
			{
				placemark.appendChild(extendedData);
			}
			
			return placemark;
		}
		
		/**
		 * @return a polygon node
		 * the first ring is the outerBoundary; the others, if they exist, are innerBoundaries
		 */ 
		
		public function buildPolygonNode(poly:Polygon):XML
		{
			var coords:String;
			var polyNode:XML = new XML("<Polygon></Polygon>");
			var outerBoundary:XML = new XML("<outerBoundaryIs></outerBoundaryIs>");
			var extRingNode:XML = new XML("<LinearRing></LinearRing>");
			outerBoundary.appendChild(extRingNode);
			polyNode.appendChild(outerBoundary);
			
			var ringList:Vector.<Geometry> = poly.getcomponentsClone();
			var extRing:LinearRing = ringList[0] as LinearRing;
			coords = this.buildCoordsAsStringP(extRing.getcomponentsClone());
			if(coords.length != 0)
				extRingNode.appendChild(new XML("<coordinates>" + coords + "</coordinates>"));
			
			if(ringList.length > 1)
			{
				var l:uint = ringList.length;
				var i:uint;
				for(i = 1; i < l; i++)
				{
					var intRing:LinearRing = ringList[i] as LinearRing;
					var innerBoundary:XML = new XML("<innerBoundaryIs></innerBoundaryIs>");
					var intRingNode:XML = new XML("<LinearRing></LinearRing>");
					innerBoundary.appendChild(intRingNode);
					polyNode.appendChild(innerBoundary);
					
					coords = this.buildCoordsAsStringP(intRing.getcomponentsClone());
					if(coords.length != 0)
						extRingNode.appendChild(new XML("<coordinates>" + coords + "</coordinates>"));
				}
			}
			return polyNode;
		}
		
		/**
		 * @param the vector of coordinates of the geometry
		 * @return the coordinates as a string
		 * in kml coordinates are tuples consisting of longitude, latitude and altitude (optional)
		 * the geometries must be in 2D; the altitude is not supported    	
		 */
		
		public function buildCoordsAsStringP(coords:Vector.<Number>):String
		{
			var i:uint;
			var stringCoords:String = "";
			var numberOfPoints:uint = coords.length;
			for(i = 0; i < numberOfPoints; i += 2){
				stringCoords += String(coords[i])+",";
				stringCoords += String(coords[i+1]);
				if( i != (numberOfPoints -2))
					stringCoords += " ";
			}
			stringCoords += " ";
			stringCoords += String(coords[0])+",";
			stringCoords += String(coords[1]);
			return stringCoords;
		}
		
		
		/**
		 * @param the vector of coordinates of the geometry
		 * @return the coordinates as a string
		 * in kml coordinates are tuples consisting of longitude, latitude and altitude (optional)
		 * the geometries must be in 2D; the altitude is not supported    	
		 */
		
		public function buildCoordsAsStringL(coords:Vector.<Number>):String
		{
			var i:uint;
			var stringCoords:String = "";
			var numberOfPoints:uint = coords.length;
			for(i = 0; i < numberOfPoints; i += 2){
				stringCoords += String(coords[i])+",";
				stringCoords += String(coords[i+1]);
				if( i != (numberOfPoints -2))
					stringCoords += " ";
			}
			return stringCoords;
		}
		
		
		
		/**
		 * @param the feature and its index in the list of features to build (useful for the style ID)
		 * @return the xml style node
		 */ 
		
		private function buildStyleNode(feature:Feature,i:uint):XML
		{
			var color:uint;
			var opacity:Number;
			var width:Number;
			var stroke:Stroke;
			var rules:Vector.<Rule> = feature.style.rules;
			var symbolizers:Vector.<Symbolizer>;
			
			if(rules.length > 0)
			{
				//Alert.show("rules.length: "+rules);
				symbolizers = rules[0].symbolizers;
			}
			//global style; can contain multiple Style types (Poly, Line, Icon)
			var placemarkStyle:XML = new XML("<Style></Style>");
			
			//this way, the feature and its style will have the same ID
			placemarkStyle.@id = "feature"+i.toString();
			feature.name = "feature"+i.toString();
			
			var styleNode:XML = null;
			if(feature is LineStringFeature || feature is MultiLineStringFeature)
			{
				//for lines, we will not store the outline style (the contour of the line)				
				var lineF:LineStringFeature = feature as LineStringFeature;
				styleNode = new XML("<LineStyle></LineStyle>");
				
				if (symbolizers.length > 0)
				{
					var lSym:LineSymbolizer = symbolizers[0] as LineSymbolizer;
					
					stroke = lSym.stroke;
					color = stroke.color;
					opacity = stroke.opacity;
					width = stroke.width;
					styleNode.appendChild(this.buildColorNode(color,opacity));
					styleNode.colorMode = "normal";
					styleNode.width = width;
					placemarkStyle.appendChild(styleNode);
				}
			}
			else if(feature is LabelFeature)
			{	
				styleNode = new XML("<LabelStyle></LabelStyle>");
				styleNode.color = "000000";
				styleNode.colorMode = "normal";
				styleNode.scale = "1";
				placemarkStyle.appendChild(styleNode);
			}
			else if(feature is PolygonFeature || feature is MultiPolygonFeature)
			{
				//for polygons, we can store both the polygon style and the outline 
				var polyF:PolygonFeature = feature as PolygonFeature;
				styleNode = new XML("<PolyStyle></PolyStyle>");
				
				if(symbolizers.length > 1)
				{
					//the second symbolizer is the outline style (fill - null and color of the outline)
					styleNode.outline = "1";
					var styleNode2:XML = new XML("<LineStyle></LineStyle>");
					var polySym2:PolygonSymbolizer = symbolizers[1] as PolygonSymbolizer;
					var stroke2:Stroke = polySym2.stroke;
					color = stroke2.color;
					opacity = stroke2.opacity;
					styleNode2.appendChild(this.buildColorNode(color,opacity));
					styleNode2.width = stroke2.width;
					placemarkStyle.appendChild(styleNode2);	
				}		
				
				if(symbolizers.length > 0)
				{
					//the first symbolizer is the polygon style (fill and color)
					var polySym:PolygonSymbolizer = symbolizers[0] as PolygonSymbolizer;
					var fill:Fill = polySym.fill;
					stroke = polySym.stroke;
					color = stroke.color;
					if(fill is SolidFill)
					{
						styleNode.fill = "1";
						opacity = (fill as SolidFill).opacity;	
						color = (fill as SolidFill).color as uint;
					}
						
					else
					{
						styleNode.fill = "0";
						opacity = 0;
					}
					styleNode.appendChild(this.buildColorNode(color,opacity));
					styleNode.colorMode = "normal";	
					placemarkStyle.appendChild(styleNode);		
				}			
			}
			else if(feature is PointFeature || feature is MultiPointFeature)
				//the style with icon is not implemented meaning the .kmz format is not supported	
			{
				var pointFeat:PointFeature = feature as PointFeature;
				styleNode = new XML("<IconStyle></IconStyle>");
				if(symbolizers.length > 0)
				{
					var pointSym:PointSymbolizer = symbolizers[0] as PointSymbolizer;
					var graphic:Marker = pointSym.graphic;
					if(graphic is WellKnownMarker)
					{//we can build the color node
						var wkm:WellKnownMarker = graphic as WellKnownMarker;
						var solidFill:SolidFill = wkm.fill;
						styleNode.appendChild(this.buildColorNode(solidFill.color as uint, solidFill.opacity));
						styleNode.colorMode = "normal";
					}
				}
				placemarkStyle.appendChild(styleNode);	
			}
			
			return placemarkStyle;
		}
		
		
		/**
		 * Build kml color tag
		 */ 
		private function buildColorNode(color:uint,opacity:Number):XML
		{
			var i:uint;
			var spareStringColor:String = "";
			var colorNode:XML = new XML("<color></color>");	
			var stringColor:String = color.toString(16);
			
			for (i = 0; i < (6 - stringColor.length); i++)
			{
				spareStringColor += "0";				
			}
			
			spareStringColor += stringColor;
			
			if(stringColor.length < 6)
				stringColor = spareStringColor;
			
			//in OpenScales, the feature opacity is between 0 and 1 (1 means 255 in KML)
			var KMLcolor:String = (opacity*255).toString(16) + stringColor.substr(4,2)
				+ stringColor.substr(2,2)+stringColor.substr(0,2);
			colorNode.appendChild(KMLcolor);
			return colorNode;
		} 
		
		/**
		 * Getters and Setters
		 */ 
		public function get proxy():String
		{
			return _proxy;
		}
		
		public function get excludeFromExtendedData():Array
		{
			return _excludeFromExtendedData;
		}
		
		public function set proxy(value:String):void
		{
			_proxy = value;
		}
		
		
		public function get userDefinedStyle():Style
		{
			return _userDefinedStyle;
		}
		
		public function set userDefinedStyle(value:Style):void
		{
			_userDefinedStyle = value;
		}
	}
}

