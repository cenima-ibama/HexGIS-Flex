package widgets.componentes.graficos
{
	import spark.components.RadioButtonGroup;

	public class RadioButtonItemObject extends Object
	{
		[Bindable]
		public var label:String;
		
		[Bindable]
		public var group:RadioButtonGroup;
		
		public function RadioButtonItemObject()
		{
			super();
		}
	}
}