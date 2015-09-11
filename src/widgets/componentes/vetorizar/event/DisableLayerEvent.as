package widgets.componentes.vetorizar.event
{	
	import org.openscales.core.events.OpenScalesEvent;
	
	import org.openscales.core.layer.Layer;

	public class DisableLayerEvent extends OpenScalesEvent
	{
		public static const DESABILITAR_CAMADA:String = "desabilitarcamada";
		
		private var _layer:Layer;
		
		public function DisableLayerEvent(type:String, l:Layer, bubbles:Boolean = false, cancelable:Boolean = false)
		{
			this._layer = l;
			super(type, bubbles, cancelable);
		}
		
		public function get layer ():Layer
		{
			return this._layer;
		}
		
		public function set layer (value:Layer):void
		{
			this._layer = value;
		}
	}
}