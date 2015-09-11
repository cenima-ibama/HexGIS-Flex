package widgets.componentes.exportar
{
	import org.openscales.core.layer.Layer;
	import org.openscales.geometry.basetypes.Bounds;

	public class CheckBoxItemObject extends Object
	{
		[Bindable]
		public var name:String;
		
		[Bindable]
		public var selecionado:Boolean;
		
		[Bindable]
		public var extent:Bounds;
		
		[Bindable]
		public var layerInfo:Layer;
		
		
		public function CheckBoxItemObject()
		{
			super();
		}
	}
}