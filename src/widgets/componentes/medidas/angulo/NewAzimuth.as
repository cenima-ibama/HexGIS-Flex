package widgets.componentes.medidas.angulo
{
	import flash.events.MouseEvent;
	
	import org.openscales.core.Map;
	import org.openscales.core.basetypes.maps.HashMap;
	import org.openscales.core.events.MapEvent;
	import org.openscales.core.events.MeasureEvent;
	import org.openscales.core.handler.IHandler;
	import org.openscales.core.handler.feature.draw.DrawPathHandler;
	import org.openscales.core.handler.feature.draw.DrawSegmentHandler;
	import org.openscales.core.handler.mouse.ClickHandler;
	import org.openscales.core.handler.mouse.DragHandler;
	import org.openscales.core.handler.mouse.MouseHandler;
	import org.openscales.core.layer.VectorLayer;
	import org.openscales.core.utils.Util;
	import org.openscales.geometry.Geometry;
	import org.openscales.geometry.LineString;
	import org.openscales.geometry.MultiPoint;
	import org.openscales.geometry.Point;
	import org.openscales.geometry.basetypes.Location;
	import org.openscales.geometry.basetypes.Pixel;
	import org.openscales.geometry.basetypes.Unit;
	import org.openscales.proj4as.ProjProjection;
	import org.openscales.core.measure.IMeasure;

	
	public class NewAzimuth extends DrawSegmentHandler implements IMeasure
	{
		
		private var _displaySystem:String = Unit.DEGREE;
		
		private var _result:String = "";
		private var _lastUnit:String = null;
		
		private var _accuracies:HashMap;
		
		/**
		 * Constructor
		 */
		public function NewAzimuth(map:Map=null)
		{
			super(map);
			var layer:VectorLayer = new VectorLayer("MeasureLayer");
			layer.editable = true;
			layer.displayInLayerManager = false;
			this.drawLayer = layer;
			
			this._accuracies = new HashMap();
			this._accuracies.put(Unit.DEGREE,2);
			this._accuracies.put(Unit.RADIAN,4);
			this._accuracies.put(Unit.SEXAGESIMAL,2);
			this._accuracies.put(Unit.MILE,3);
			this._accuracies.put(Unit.FOOT,2);
			this._accuracies.put(Unit.INCH,1);
			this._accuracies.put(Unit.KILOMETER,3);
			this._accuracies.put(Unit.METER,0);
		}
		
		override public function set active(value:Boolean):void {
			if(value == this.active)
				return;
			
			super.active = value;
			if(this.map) {
				if(value) {
					this.drawLayer.projection = map.projection;
					this.drawLayer.minResolution = this.map.minResolution;
					this.drawLayer.maxResolution = this.map.maxResolution;
					this.map.addLayer(this.drawLayer);
				} else {
					this.drawFinalPath();
					this.clearFeature();
					this.map.removeLayer(this.drawLayer);
				}
			}
		}
		private function clearFeature():void {
			if(newFeature && _currentLineStringFeature){
				this.drawLayer.removeFeature(_currentLineStringFeature);
				_currentLineStringFeature.destroy();
				_currentLineStringFeature = null;
			}
		}
		override protected function drawLine(event:MapEvent=null):void {
			this.clearFeature();
			super.drawLine(event);
			var mEvent:MeasureEvent = null;
			if(_currentLineStringFeature && (_currentLineStringFeature.geometry as MultiPoint).components.length>1) {
				//dispatcher event de calcul
				mEvent = new MeasureEvent(MeasureEvent.MEASURE_AVAILABLE,this);//,null,null);
				
			} else {
				mEvent = new MeasureEvent(MeasureEvent.MEASURE_UNAVAILABLE,this);//,null,null);
			}
			_result = "";
			_lastUnit = null;
			this.map.dispatchEvent(mEvent);
		}
		
		
		
		public function getMeasure():String {
			
			this._result = "N/A";
			
			if(_currentLineStringFeature && (_currentLineStringFeature.geometry as MultiPoint).components.length>1) {
				
				
				var p0:Point = (_currentLineStringFeature.geometry as LineString).getPointAt(0);
				var p1:Point = (_currentLineStringFeature.geometry as LineString).getPointAt(1);
				
				
				
				if(p0 && p1){
					
					if (!ProjProjection.isEquivalentProjection(this.map.projection,ProjProjection.getProjProjection(Geometry.DEFAULT_SRS_CODE)))
					{
						p0.projection = this.map.projection;
						p0.transform(Geometry.DEFAULT_SRS_CODE);
						p1.projection = this.map.projection;
						p1.transform(Geometry.DEFAULT_SRS_CODE);
					}
					var p0Rad:Point = new Point(Util.degtoRad(p0.x),Util.degtoRad(p0.y));
					var p1Rad:Point = new Point(Util.degtoRad(p1.x),Util.degtoRad(p1.y));
					
					var azimuth:Number= Math.atan2(Math.sin(p1Rad.x - p0Rad.x) * Math.cos(p1Rad.y), Math.cos(p0Rad.y) * Math.sin(p1Rad.y) - Math.sin(p0Rad.y) * Math.cos(p1Rad.y) * Math.cos(p1Rad.x - p0Rad.x));
					if (azimuth<0) {
						azimuth+= 6.283185307179586477;
					}
				}
				
				
				switch(_displaySystem.toLowerCase()) {
					case Unit.RADIAN:
						_result= this.trunc(azimuth,this._accuracies.getValue(Unit.RADIAN));
						_lastUnit="";
						break;
					case Unit.SEXAGESIMAL:
						var acc:Number=this._accuracies.getValue(Unit.SEXAGESIMAL);
						if(!acc){
							acc=2;
						}
						_result= Util.degToDMS(Util.radtoDeg(azimuth),null,acc);
						_lastUnit="";
						break;
					case Unit.DEGREE:
						_result= this.trunc(Util.radtoDeg(azimuth),this._accuracies.getValue(Unit.DEGREE));
						_lastUnit="°";
						break;
					default:
						_result= this.trunc(Util.radtoDeg(azimuth),this._accuracies.getValue(Unit.DEGREE));
						_lastUnit="°";
						break;
				}
				
			} else {
				_lastUnit = null;
			}
			
			if(_result.indexOf("NaN") == -1){
				return _result;
			}
			else{
				_lastUnit = "";
				_result="N/A";
				return "N/A";
			}
		}
		
		private function trunc(val:Number,unit:Number):String{
			if(!unit){
				unit=2;
			}
			return Util.truncate(val,unit);
		}
		
		public function getUnits():String {
			if(!_lastUnit)
				this.getMeasure();
			return _lastUnit;
		}
		
		public function get displaySystem():String
		{
			return _displaySystem;
		}
		
		public function set displaySystem(value:String):void
		{
			_displaySystem = value;
		}
		
		public function get accuracies():HashMap
		{
			return _accuracies;
		}
		
		public function set accuracies(value:HashMap):void
		{
			_accuracies = value;
		}
		
		
	}
}