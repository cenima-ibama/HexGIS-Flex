package widgets.componentes.informacoes.drag.reader
{
	import mx.controls.Alert;
	
	import org.openscales.core.feature.Feature;
	import org.openscales.core.feature.LineStringFeature;
	import org.openscales.core.feature.MultiLineStringFeature;
	import org.openscales.core.feature.MultiPointFeature;
	import org.openscales.core.feature.MultiPolygonFeature;
	import org.openscales.core.feature.PointFeature;
	import org.openscales.core.feature.PolygonFeature;
	import org.openscales.core.format.gml.parser.GMLParser;
	import org.openscales.core.utils.Trace;
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
	import org.openscales.proj4as.ProjProjection;
	
	public class NewGML311 extends GMLParser
	{
		
		public function NewGML311()
		{
		}
		
		override public function get gml():Namespace {
			return new Namespace("gml","http://www.opengis.net/gml");	
		}
		
		override public function parseFeature(data:XML, lonLat:Boolean=true):Feature {
			use namespace gml;
			var proj:ProjProjection = ProjProjection.getProjProjection("EPSG:4326");
			var geom:ICollection = null;
			var p:Vector.<Number> = new Vector.<Number>();
			
			var feature:Feature = null;
			var srsCode:String = "EPSG:4326";
			
			var i:int;
			var j:int;
			//multiSurface
			if (data..*::MultiSurface.length() > 0) {
				var multisurface:XML = data..*::MultiSurface[0];
				srsCode = multisurface.@srsName;
				proj = ProjProjection.getProjProjection(srsCode);
				geom = new MultiPolygon();
				(geom as MultiPolygon).projection = proj;
				var surfaces:XMLList = multisurface..*::Polygon;
				j = surfaces.length();
				for (i = 0; i < j; i++) {
					var surface:Polygon = this.parsePolygonNode(surfaces[i], proj, lonLat);
					if(surface)
						geom.addComponent(surface);
				}
				feature = new MultiPolygonFeature(geom as MultiPolygon);
			}
				
				//MultiPolygon
			else if (data..*::MultiPolygon.length() > 0) {
				var multipolygon:XML = data..*::MultiPolygon[0];
				
				srsCode = multipolygon.@srsName;
				proj = ProjProjection.getProjProjection(srsCode);
				geom = new MultiPolygon();
				(geom as MultiPolygon).projection = proj;
				var polygons:XMLList = multipolygon..*::Polygon;
				j = polygons.length();
				for (i = 0; i < j; i++) {
					var polygon:Polygon = this.parsePolygonNode(polygons[i], proj, lonLat);
					if(polygon)
						geom.addComponent(polygon);
				}
				feature = new MultiPolygonFeature(geom as MultiPolygon);
			}
				//multilinestring
			else if (data..*::MultiLineString.length() > 0) {
				var multilinestring:XML = data..*::MultiLineString[0];
				
				srsCode = multilinestring.@srsName;
				proj = ProjProjection.getProjProjection(srsCode);
				geom = new MultiLineString();
				(geom as MultiLineString).projection = proj;
				var lineStrings:XMLList = multilinestring..*::LineString;
				j = lineStrings.length();
				
				for (i = 0; i < j; ++i) {
					p = this.parseCoords(lineStrings[i], lonLat);
					if(p){
						var lineString:LineString = new LineString(p);
						if(lineString)
							geom.addComponent(lineString);
					}
				}
				feature = new MultiLineStringFeature(geom as MultiLineString);
			}
				// multiCurve
			else if (data..*::MultiCurve.length() > 0) {
				var multicurve:XML = data..*::MultiCurve[0];
				
				srsCode = multicurve.@srsName;
				proj = ProjProjection.getProjProjection(srsCode);
				geom = new MultiLineString();
				(geom as MultiLineString).projection = proj;
				var curves:XMLList = multicurve..*::LineString;
				j = curves.length();
				
				for (i = 0; i < j; ++i) {
					p = this.parseCoords(curves[i], lonLat);
					if(p){
						var curve:LineString = new LineString(p);
						if(curve)
							geom.addComponent(curve);
					}
				}
				feature = new MultiLineStringFeature(geom as MultiLineString);
			}
				//MultiPoint
			else if (data..*::MultiPoint.length() > 0) {
				var multiPoint:XML = data..*::MultiPoint[0];
				
				srsCode = multiPoint.@srsName;
				proj = ProjProjection.getProjProjection(srsCode);
				geom = new MultiPoint();
				(geom as MultiPoint).projection = proj;
				
				var points:XMLList = multiPoint..*::Point;
				j = points.length();
				p = this.parseCoords(points[i], lonLat);
				if (p)
					geom.addPoints(p);
				feature = new MultiPointFeature(geom as MultiPoint);
			}
				//Polygon
			else if (data..*::Polygon.length() > 0) {
				var polygon2:XML = data..*::Polygon[0];
				
				srsCode = polygon2.@srsName;
				proj = ProjProjection.getProjProjection(srsCode);
				geom = this.parsePolygonNode(polygon2,proj, lonLat);
				if(geom)
					feature = new PolygonFeature(geom as Polygon);
			}
				//Linestring
			else if (data..*::LineString.length() > 0) {
				var lineString2:XML = data..*::LineString[0];
				
				p = this.parseCoords(lineString2, lonLat);
				if (p) {
					
					srsCode = lineString2.@srsName;
					proj = ProjProjection.getProjProjection(srsCode);
					geom = new LineString(p);
					(geom as LineString).projection = proj;
					feature = new LineStringFeature(geom as LineString);
				}
			}
				//point
			else if (data..*::Point.length() > 0) {
				var point:XML = data..*::Point[0];
				var pointObject:Point; 
				
				
				
				p = this.parseCoords(point, lonLat);
				if (p && p.length==2) {
					pointObject = new Point(p[0],p[1]);
					srsCode = point.@srsName;
					proj = ProjProjection.getProjProjection(srsCode);
					pointObject.projection = proj;
					feature = new PointFeature(pointObject);
				}
			}else{
				//Trace.warn("GMLFormat.parseFeature: unrecognized geometry);"); 
				feature = new Feature(new Geometry());
				//return null; 
			}
			
			if (feature) {
				var attrs:XMLList = data.attributes();
				for each(var attr:XML in attrs) {
					if(attr.localName()=="id") {
						feature.name = attr.toString();
						break;
					}
				}
				//feature.name = data..@id;
				
				if (this.parseExtractAttributes) {
					feature.attributes = this.parseAttributes(data);
				}    
				//todo see if the feature is locked or can be modified
				feature.isEditable = true;
				return feature;
				
			} else {
				return null;
			}
		}
		
		
		/**
		 * Parse attributes
		 *
		 * @param node A XML feature node.
		 *
		 * @return An attributes object.
		 */
		private function parseAttributes(xmlNode:XML):Object {
			var nodes:XMLList = xmlNode.children();
			var attributes:Object = {};
			var j:int = nodes.length();
			var i:int;
			for(i = 0; i < j; ++i) {
				var name:String = nodes[i].localName();
				var value:Object = nodes[i].valueOf();
				if(name == null || name=="posList"){
					continue;    
				}
				
				// Check for a leaf node
				if((nodes[i].children().length() == 1)
					&& !(nodes[i].children().children()[0] is XML)) {
					attributes[name] = value.children()[0].toXMLString();
				}
				Util.extend(attributes, this.parseAttributes(nodes[i]));
			}   
			return attributes;
		}
		
		/**
		 * Given a GML node representing a polygon geometry
		 *
		 * @param node
		 *
		 * @return A polygon geometry.
		 */
		private function parsePolygonNode(polygonNode:Object, proj:ProjProjection, lonlat:Boolean):Polygon {
			var exterior:XMLList = polygonNode..*::exterior;
			if(exterior.length()!=1)
				return null;
			var poslist:XMLList = exterior[0]..*::LinearRing;
			// Optimize by specifying the array size
			if(poslist.length()!=1)
				return null;
			
			var rings:Vector.<Geometry> = new Vector.<Geometry>();
			rings[0] = new LinearRing(this.parseCoords(poslist[0], lonlat));
			rings[0].projection = proj;
			
			var interior:XMLList = polygonNode..*::interior;
			if(interior.length()==1) {
				poslist = interior[0]..*::LinearRing;
				if(poslist.length()==1)
					rings[1] = new LinearRing(this.parseCoords(poslist[0], lonlat));
				rings[1].projection = proj;
			}
			
			return new Polygon(rings);
		}
	}
}