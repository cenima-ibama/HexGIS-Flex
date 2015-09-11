package widgets.componentes.vetorizar.desenhar
{
	import org.openscales.core.feature.Feature;

	public class FeatureModificadoObj extends Object
	{
		private var _antigo:Feature;
		
		private var _novo:Feature;
		
		
		public function FeatureModificadoObj()
		{
			super();
		}
		
		public function get antigo():Feature
		{
			return this._antigo;
		}
		public function set antigo(value:Feature):void
		{
			this._antigo = value;
		}
		
		public function get novo():Feature
		{
			return this._novo;
		}
		public function set novo(value:Feature):void
		{
			this._novo = value;
		}
	}
}