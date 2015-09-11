package widgets.componentes.medidas.distancia
{
	import flash.events.MouseEvent;
	import flash.ui.Mouse;
	
	import mx.controls.Alert;
	
	import org.openscales.core.Map;
	import org.openscales.core.basetypes.maps.HashMap;
	import org.openscales.core.events.MapEvent;
	import org.openscales.core.events.MeasureEvent;
	import org.openscales.core.handler.IHandler;
	import org.openscales.core.handler.feature.draw.DrawPathHandler;
	import org.openscales.core.handler.mouse.ClickHandler;
	import org.openscales.core.handler.mouse.DragHandler;
	import org.openscales.core.handler.mouse.MouseHandler;
	import org.openscales.core.layer.VectorLayer;
	import org.openscales.core.measure.IMeasure;
	import org.openscales.core.utils.Util;
	import org.openscales.geometry.LineString;
	import org.openscales.geometry.MultiPoint;
	import org.openscales.geometry.basetypes.Pixel;
	import org.openscales.geometry.basetypes.Unit;
	import org.openscales.proj4as.ProjProjection;
	
	
	public class NewDistance extends DrawPathHandler implements IMeasure
	{
		private var _accuracies:HashMap = null;
		private var _displaySystem:String = "metric";
		private var _result:String = "";
		private var _lastUnit:String = null;
		
		/**
		 * Constructor
		 */
		public function NewDistance(map:Map=null)
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
		
		override public function set active(value:Boolean):void
		{
			if (value == this.active)
				return;
			super.active = value;
			
			if (this.map)
			{
				if(value)
				{
					this.drawLayer.projection = map.projection;
					this.drawLayer.minResolution = this.map.minResolution;
					this.drawLayer.maxResolution = this.map.maxResolution;
					this.map.addLayer(this.drawLayer);
				}
				else
				{
					this.drawFinalPath();
					this.clearFeature();
					this.map.removeLayer(this.drawLayer);
				}
			}
		}
		private function clearFeature():void
		{
			if (newFeature && _currentLineStringFeature)
			{
				this.drawLayer.removeFeature(_currentLineStringFeature);
				_currentLineStringFeature.destroy();
				_currentLineStringFeature = null;
			}
		}
		override protected function drawLine(event:MapEvent=null):void 
		{
			this.clearFeature();
			super.drawLine(event);
			var mEvent:MeasureEvent = null;
			
			if (_currentLineStringFeature && (_currentLineStringFeature.geometry as MultiPoint).components.length>1)
			{
				//dispatcher event de calcul
				mEvent = new MeasureEvent(MeasureEvent.MEASURE_AVAILABLE,this);
				
			} 
			else 
			{
				mEvent = new MeasureEvent(MeasureEvent.MEASURE_UNAVAILABLE,this);
			}
			_result = "";
			_lastUnit = null;
			this.map.dispatchEvent(mEvent);
		}
		
		public function getMeasure():String 
		{
			var tmpDist:Number = 0;
			
			if (_currentLineStringFeature && (_currentLineStringFeature.geometry as MultiPoint).components.length>1) 
			{
				tmpDist = (_currentLineStringFeature.geometry as LineString).length;

				this._accuracies.put(Unit.DEGREE,2);
				this._accuracies.put("gon",2);
				this._accuracies.put(Unit.MILE,3);
				this._accuracies.put(Unit.FOOT,2);
				this._accuracies.put(Unit.INCH,1);
				
				tmpDist *= Unit.getInchesPerUnit(ProjProjection.getProjProjection(drawLayer.projection).projParams.units);

				switch (_displaySystem.toLowerCase()) 
				{
					case Unit.METER:
						tmpDist/=Unit.getInchesPerUnit(Unit.METER);
						_result= this.trunc(tmpDist,_accuracies.getValue(Unit.METER));
						_lastUnit = Unit.METER;
						break;
					
					case Unit.KILOMETER:
						tmpDist/=Unit.getInchesPerUnit(Unit.KILOMETER);
						_result= this.trunc(tmpDist,_accuracies.getValue(Unit.KILOMETER));
						_lastUnit = Unit.KILOMETER;
						break;
					
					case "metric":			
						tmpDist/=Unit.getInchesPerUnit(Unit.METER);
						_result= Util.truncate(tmpDist,_accuracies.getValue(Unit.METER));
						_result= this.trunc(tmpDist,_accuracies.getValue(Unit.METER));
						_lastUnit = Unit.METER;
						
						if (tmpDist>1000)
						{
							tmpDist/=1000;
							_lastUnit = Unit.KILOMETER;
							_result= Util.truncate(tmpDist,_accuracies.getValue(Unit.KILOMETER));
						}
						break;
					
					case Unit.DEGREE:
						tmpDist/=Unit.getInchesPerUnit(Unit.DEGREE);
						_lastUnit = Unit.DEGREE;
						_result= this.trunc(tmpDist,_accuracies.getValue(Unit.DEGREE));
						break;
					
					case Unit.SEXAGESIMAL:
						tmpDist/=Unit.getInchesPerUnit(Unit.DEGREE);
						_lastUnit = "";
						var acc:Number=this._accuracies.getValue(Unit.SEXAGESIMAL);
						if (!acc)
						{
							acc=2;
						}
						_result= Util.degToDMS(tmpDist,null,acc);
						break;
					
					case Unit.FOOT:
						tmpDist/=Unit.getInchesPerUnit(Unit.FOOT);
						_lastUnit = Unit.FOOT;
						_result= this.trunc(tmpDist,_accuracies.getValue("ft"));
						break;
					
					case Unit.INCH:
						tmpDist/=Unit.getInchesPerUnit(Unit.INCH);
						_lastUnit = Unit.INCH;
						_result= this.trunc(tmpDist,_accuracies.getValue(Unit.INCH));
						break;
					
					case Unit.MILE:
						tmpDist/=Unit.getInchesPerUnit(Unit.MILE);
						_lastUnit = Unit.MILE;
						_result= this.trunc(tmpDist,_accuracies.getValue(Unit.MILE));
						break;
					
					case "english":
						tmpDist/=Unit.getInchesPerUnit(Unit.FOOT);
						_lastUnit = Unit.FOOT;
						_result= this.trunc(tmpDist,_accuracies.getValue(Unit.FOOT));
						
						if (tmpDist<1) 
						{
							tmpDist*=12;
							_lastUnit = Unit.INCH;
							_result= this.trunc(tmpDist,_accuracies.getValue(Unit.INCH));
						}
						if (tmpDist>5280) 
						{
							tmpDist/=5280;
							_lastUnit = Unit.MILE;
							_result= this.trunc(tmpDist,_accuracies.getValue(Unit.MILE));
						}
						break;
					
					default:
						_lastUnit = null;
						_result="0";
						break;
				}
			}
			else 
			{
				tmpDist = NaN;
				_result ="NaN";
				_lastUnit = null;
			}
			
			return _result;
		}
		
		private function trunc(val:Number,unit:Number):String
		{
			if(!unit)
			{
				unit=2;
			}
			
			return Util.truncate(val,unit);
		}
		
		public function getUnits():String
		{
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