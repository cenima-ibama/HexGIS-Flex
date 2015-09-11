package widgets.componentes.vetorizar.event
{
	import flash.events.Event;
	
	import org.openscales.core.layer.Layer;

	public class EnableLayerEvent extends Event
	{
		
		public static const HABILITAR_CAMADA:String = "habilitarcamada";
		
		private var _layer:Layer;
		
		public function EnableLayerEvent(type:String, l:Layer, bubbles:Boolean = false, cancelable:Boolean = false)
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