package widgets.componentes.graficos.handler
{
	import widgets.componentes.printpreview.utils.Controller;
	import com.webmapsolutions.model.ModelLocator;
	
	import widgets.componentes.graficos.ChartManager;
	import componentes.informacoes.click.handler.InfoClickHandler;
	import widgets.componentes.informacoes.drag.WFSGetFeature;
	import widgets.componentes.informacoes.drag.event.GetFeatureEvent;
	
	import mx.controls.Alert;
	import mx.managers.PopUpManager;
	
	import org.openscales.core.Map;
	import org.openscales.core.feature.Feature;
	import org.openscales.core.handler.Handler;
	import org.openscales.geometry.basetypes.Pixel;
	
	public class GraficoDragHandler extends Handler
	{
		[Bindable]
		private var _controller:Controller = Controller.getInstance();
		[Bindable]
		private var _model:ModelLocator = ModelLocator.getInstance();
		[Bindable]
		private var wfsGetFeature:WFSGetFeature = WFSGetFeature.getInstance();
		[Bindable]
		private var _ultimosDados:Object = null;
		[Bindable]
		private var _ultimoCentro:Pixel = null;
		[Bindable]
		private var _ultimaCamada:String = null;
		
		private var gerenciaGraficos:ChartManager;

		private var _modo:String;

		public function GraficoDragHandler(map:Map=null, active:Boolean=false)
		{
			super.map = map;
			super.active = active;
		}

		override protected function registerListeners():void{
			if (this.map) {
				this.map.addEventListener(GetFeatureEvent.GET_FEATURE_DATA, handleData);
			}
		}

		override protected function unregisterListeners():void{
			if (this.map) {
				this.map.removeEventListener(GetFeatureEvent.GET_FEATURE_DATA,handleData);
			}
		}
		
		override public function set map(value:Map):void {
			super.map = value;
			
			if ((this.map != null) && (wfsGetFeature.map == null)) {
				wfsGetFeature.map = this.map;
			}
		}
		
		override public function get active():Boolean 
		{
			return super.active;
		}
		
		override public function set active(value:Boolean):void
		{
			if ((value) && (!this.active)) 
			{
				_controller.activateTool("chart", true);
				
				if (!wfsGetFeature.active)
				{
					wfsGetFeature.active = true;
				}
			}
			else if ((!value) && (this.active)) 
			{
				_controller.activateTool("chart", false);
				if ((wfsGetFeature.active) && (!_model.infoActive))
				{
					wfsGetFeature.active = false;
				}
			}
			super.active = value;
		}
		
		public function set modo(mode:String):void {
			this._modo = mode;
			
			if (this._ultimosDados != null)
			{
				geraGraf();
			}
		}
		
		private function handleData(event:GetFeatureEvent):void{
			if ((event.data != 0) || (event.data != null))
			{				
				this._ultimosDados = event.data;
				this._ultimoCentro = event.center;
				this._ultimaCamada = event.layerName;
				
				if (this._modo != null)
				{
					geraGraf();
				}
								/*if (event.layerName != null)
				{
					infoPanel.titulo = "Informações:  " + event.layerName + "        ";
				}*/
			}
		}
		
		private function geraGraf():void{
			var aux:Object = new Object();
			aux.dados = this._ultimosDados;
			aux.modo = this._modo;
			aux.camada = this._ultimaCamada;
			
			gerenciaGraficos = ChartManager(PopUpManager.createPopUp(_model.map, ChartManager, false));
			gerenciaGraficos.dados = aux;
			
			if (this._ultimoCentro)
			{
				gerenciaGraficos.x = this._ultimoCentro.x;
				gerenciaGraficos.y = this._ultimoCentro.y;
			}
			else
			{
				gerenciaGraficos.x = _model.map.width/2 - 500;
				gerenciaGraficos.y = _model.map.height/2 - 250;
			}
		}
	}
}