package widgets.componentes.graficos
{	
	public class ListItemValueObject extends Object {
		
		[Bindable]
		public var label:String;
		
		[Bindable]
		public var isSelected:Boolean;
		
		public function ListItemValueObject() {
			super();
		}
	}
}