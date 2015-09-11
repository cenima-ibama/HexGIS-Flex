package widgets.componentes.mapa
{
	import org.openscales.fx.FxMap;

	public class FxHexMap extends FxMap
	{
		public function FxHexMap()
		{
			super();				
			this._map = new HexMap();
		}
	}
}