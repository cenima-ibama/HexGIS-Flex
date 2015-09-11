package widgets.componentes.gerenciador.renderer
{
	//import componentes.camadas.NewLayerManager;
	import widgets.LayerManagerWidget;
	
	import spark.components.IItemRenderer;
	
	public interface NewILayerManagerItemRenderer extends IItemRenderer
	{
		
		function set rendererOptions(value:Object):void;
		
		//function set layerManager(value:NewLayerManager):void;
		function set layerManager(value:LayerManagerWidget):void;
	}
}