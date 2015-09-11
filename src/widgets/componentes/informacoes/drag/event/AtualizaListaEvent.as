package widgets.componentes.informacoes.drag.event
{
	import org.openscales.core.events.OpenScalesEvent;

	public class AtualizaListaEvent extends OpenScalesEvent
	{
		
		public static const LISTA_ATUALIZADA:String="openscales.listaatualizada";

		public function AtualizaListaEvent(type:String, bubbles:Boolean = false, cancelable:Boolean = false)
		{
			super(type, bubbles, cancelable);
		}
	}
}
