package widgets.componentes.gerenciador.renderer
{
	import org.openscales.core.layer.Layer;
	
	import widgets.LayerManagerWidget;

	public class LayerRendererObject extends Object
	{
		private var _layer:Layer;
		
		private var _layerManager:LayerManagerWidget;
		
		private var _rendererOptions:Object;
		
		
		public function LayerRendererObject()
		{
			super();
		}
		
		public function get layer():Layer
		{
			return this._layer;
		}
		
		public function set layer(value:Layer):void
		{
			this._layer = value;
		}
		
		public function get layerManager():LayerManagerWidget
		{
			return this._layerManager;
		}
		
		public function set layerManager(value:LayerManagerWidget):void
		{
			this._layerManager = value;
		}
		
		public function get rendererOptions():Object
		{
			return this._rendererOptions;
		}
		
		public function set rendererOptions(value:Object):void
		{
			this._rendererOptions = value;
		}
	}
}