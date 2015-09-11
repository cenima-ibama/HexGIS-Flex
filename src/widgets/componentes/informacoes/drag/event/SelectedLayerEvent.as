package widgets.componentes.informacoes.drag.event
{
	import org.openscales.core.events.OpenScalesEvent;

	public class SelectedLayerEvent extends OpenScalesEvent
	{
				
		private var _camada:String;
		
		public static const SELECTED_LAYER:String="openscales.selectedlayer";
		
		public function SelectedLayerEvent(type:String, layer:String, bubbles:Boolean = false, cancelable:Boolean = false)
		{
			this.camada = layer;
			super(type, bubbles, cancelable);
		}
		
		public function get camada():String {
			return this._camada;
		}
		public function set camada(layer:String):void {
			this._camada = layer;
		}
	}
}