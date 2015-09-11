package widgets.componentes.ibama.feature
{
	import flash.display.DisplayObject;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	import mx.controls.Alert;
	import mx.core.FlexGlobals;
	import mx.core.IFlexDisplayObject;
	import mx.events.ModuleEvent;
	import mx.managers.PopUpManager;
	import mx.modules.IModuleInfo;
	import mx.modules.ModuleManager;
	
	import org.openscales.core.events.FeatureEvent;
	import org.openscales.core.events.LayerEvent;
	import org.openscales.core.feature.Feature;
	import org.openscales.core.feature.LineStringFeature;
	import org.openscales.core.layer.Layer;
	import org.openscales.core.style.Style;
	import org.openscales.geometry.Geometry;
	import org.openscales.geometry.LineString;
	import org.openscales.geometry.LinearRing;
	import org.openscales.geometry.Polygon;
	import org.openscales.geometry.basetypes.Bounds;
	import org.openscales.geometry.basetypes.Location;
	import org.openscales.geometry.basetypes.Pixel;
	import org.openscales.proj4as.ProjProjection;
	
	import solutions.CloseWindowBase;
	
	import widgets.componentes.ibama.event.EditingDisabledEvent;
	
	
	public class IbamaLineStringFeature extends LineStringFeature
	{
		[Bindable] private var _login_user:String;
		[Bindable] private var _comprimento:Number;
		[Bindable] private var _editing:Boolean;
		[Bindable] private var _isLogged:Boolean;
		private var panel:IModuleInfo;	
		private var _timer:Timer;
		private var _first:Boolean = true;
		
		
		public function IbamaLineStringFeature(geom:LineString = null, data:Object = null, style:Style = null, isEditable:Boolean = false)
		{
			super(geom, data, style);
		}
		
		override public function get attributes():Object
		{
			if (this._first)
			{
				this.attributes = new Object();
			}
			
			return super.attributes;
		}
		override public function set attributes(value:Object):void 
		{	
			if (this._first)
			{
				var attr:Object = new Object();
				
				attr.fid = 0;
				attr.id = 0;
				attr.cpf = "";
				attr.operacao = "";
				attr.data = "";
				attr.id_agente = "";
				attr.condicao = 1;
				attr.num_tei = 0;
				attr.serie_tei = "";
				attr.num_ai = 0;
				attr.serie_ai = "";
				attr.id_des = 0;
				attr.imovel = "";
				attr.tipo = 0;
				//attr.foto = "";
				attr.obs = "";
				attr.comprimento = 0.0;
				
				super.attributes = attr;
				
				/*for (var key:String in this.attributes)
				{
					Alert.show(key);
				}*/
				
				this._first = false;
			}
			
			if (value.hasOwnProperty("fid"))
			{
				this.attributes.fid = value.fid;
				
				this.attributes.id = value.fid;
			}
			
			if (value.hasOwnProperty("id"))
			{
				this.attributes.id = value.id;
				this.attributes.fid = value.id;
			}
			
			if (value.hasOwnProperty("cpf"))
			{
				this.attributes.cpf = value.cpf;
			}
			
			if (value.hasOwnProperty("operacao"))
			{
				this.attributes.operacao = value.operacao;
			}
			
			if (value.hasOwnProperty("data"))
			{
				this.attributes.data = value.data; //tratar formatos de data
			}
			
			if (value.hasOwnProperty("id_agente"))
			{
				this.attributes.id_agente = value.id_agente;
			}
			
			if (value.hasOwnProperty("condicao"))
			{
				this.attributes.condicao = value.condicao;
			}
			
			if (value.hasOwnProperty("num_tei"))
			{
				this.attributes.num_tei = value.num_tei;
			}
			
			if (value.hasOwnProperty("serie_tei"))
			{
				this.attributes.serie_tei = value.serie_tei;
			}
			
			if (value.hasOwnProperty("num_ai"))
			{
				this.attributes.num_ai = value.num_ai;
			}
								
			if (value.hasOwnProperty("serie_ai"))
			{
				this.attributes.serie_ai = value.serie_ai;
			}
			
			if (value.hasOwnProperty("id_des"))
			{
				this.attributes.id_des = value.id_des;
			}
			
			if (value.hasOwnProperty("imovel"))
			{
				this.attributes.imovel = value.imovel;
			}
			
			if (value.hasOwnProperty("tipo"))
			{
				this.attributes.tipo = value.tipo;
			}
			
			if (value.hasOwnProperty("obs"))
			{
				this.attributes.obs = value.obs;
			}
		}
		
		override public function registerListeners():void 
		{
			if ((this.layer) && (this.layer.map))
			{
				this.layer.map.addEventListener(FeatureEvent.FEATURE_EDITED_END, onFeatureEdited);
			}

			if (this.lineString.componentsLength > 1)
			{
				this.comprimento = Math.abs((this.geometry as LineString).length); //metros
			}
			else
			{
				if ((this.layer) && (this.layer.map))
				{
					this.layer.map.addEventListener(FeatureEvent.FEATURE_DRAWING_END, setComprimento);
				}
			}
			
			super.registerListeners();
		}
		
		override public function unregisterListeners():void 
		{
			if ((this.layer) && (this.layer.map))
			{
				this.layer.map.removeEventListener(FeatureEvent.FEATURE_EDITED_END, onFeatureEdited);
				this.layer.map.removeEventListener(FeatureEvent.FEATURE_DRAWING_END, setComprimento);
			}
			
			super.unregisterListeners();
		}
		
		private function onFeatureEdited(event:FeatureEvent):void
		{		
			setComprimento(event);
		}
		
		private function setComprimento(e:FeatureEvent):void
		{
			var pol_bounds:Location;
			
			if (e.feature == this)
			{
				this.layer.map.removeEventListener(FeatureEvent.FEATURE_DRAWING_END, setComprimento);

				this.comprimento = Math.abs((this.geometry as LineString).length); //metros
			}
		}
		
		private function onMouseOverFeat(event:MouseEvent):void 
		{
			if (_timer == null)
			{
				_timer = new Timer(750);
				_timer.addEventListener(TimerEvent.TIMER, openPanel);
			}
			_timer.start();
		}
		
		private function onMouseOutFeat(event:MouseEvent):void 
		{
			if (_timer) _timer.stop();
		}
		
		private function openPanel(event:TimerEvent):void 
		{
			if ((this._editing) && (panel == null) && (this.layer.features.indexOf(this) > -1))
			{
				var url:String = "widgets/componentes/ibama/feature/LineStringFeaturePanel.swf";
				
				panel = ModuleManager.getModule(url);
				panel.addEventListener(ModuleEvent.READY, featPanelReadyHandler);           
				panel.load();
			}
		}
		
		public function resetaPopup():void
		{
			panel = null;
		}
		
		private function featPanelReadyHandler(event:ModuleEvent):void
		{
			var panel:IModuleInfo = event.module;
			var widget:CloseWindowBase = panel.factory.create() as CloseWindowBase;			
			var centerpx:Pixel =  this.layer.map.getMapPxFromLocation(this.geometry.bounds.center);
						
			if ((centerpx.x + widget.width + 10) <  FlexGlobals.topLevelApplication.width)
			{
				widget.x = centerpx.x;
			}
			else
			{
				widget.x = centerpx.x - widget.width;
			}
			
			if ((centerpx.y - widget.height - 10) <  0)
			{
				widget.y = centerpx.y;
			}
			else
			{
				widget.y = centerpx.y - widget.height;
			}
			
			if ((this.attributes.hasOwnProperty("fid")) && (this.attributes.fid > 0))
			{
				widget.setTitle("Linha "+this.attributes.fid);
			}
			else
			{
				widget.setTitle("Nova linha");
			}
			
			widget.setFeature(this);
			widget.setMap(this.layer.map);

			PopUpManager.addPopUp(widget as IFlexDisplayObject, FlexGlobals.topLevelApplication as DisplayObject);
			//PopUpManager.centerPopUp(widget as IFlexDisplayObject);
		}
		
		override public function clone():Feature
		{
			var geometryClone:Geometry = this.geometry.clone();
			var style:Style = null;
			
			if (this.style)
			{
				style  = this.style.clone();
			}
			
			var lineStringFeatureClone:IbamaLineStringFeature = new IbamaLineStringFeature(geometryClone as LineString, null, style, this.isEditable);
			lineStringFeatureClone.attributes = this.attributes;
			lineStringFeatureClone._originGeometry = this._originGeometry;
			lineStringFeatureClone.layer = this.layer;

			return lineStringFeatureClone;
		}
		
		[Bindable] 
		public function get comprimento():Number
		{
			return this._comprimento;
		}
		public function set comprimento(value:Number):void
		{
			if (this.attributes == null)
			{
				this.attributes = new Object();
			}
			this.attributes.comprimento = value;
			
			this._comprimento = value;
		}
		
		[Bindable] 
		public function get login_user():String
		{
			return this._login_user;
		}
		public function set login_user(value:String):void
		{
			this._login_user = value;
						
			if (value != null)
			{
				if (this.attributes == null)
				{
					this.attributes = new Object();
				}
				this.attributes.cpf = value; //cpf
												
				this.addEventListener(MouseEvent.MOUSE_OVER, onMouseOverFeat);
				this.addEventListener(MouseEvent.MOUSE_OUT, onMouseOutFeat);
			}
		}
		
		public function get editing():Boolean
		{
			return this._editing;
		}
		
		public function set editing(value:Boolean):void
		{
			this._editing = value;
			
			if (!_editing)
			{
				this.layer.map.dispatchEvent(new EditingDisabledEvent(EditingDisabledEvent.ATTRIBUTES_EDITING_DISABLED, this));
			}
		}
		
		public function set logged(value:Boolean):void
		{
			this._isLogged = value;
		}
		public function get logged():Boolean
		{
			return this._isLogged;
		}
		
		
	}
}