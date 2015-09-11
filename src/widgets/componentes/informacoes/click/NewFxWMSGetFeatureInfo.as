package widgets.componentes.informacoes.click
{
	import org.openscales.fx.handler.FxHandler;
	
	/**
	 * <p>WMSGetFeatureInfo Flex wrapper.</p>
	 * <p>To use it, declare a &lt;WMSGetFeatureInfo /&gt; MXML component using xmlns="http://openscales.org"</p>
	 */
	public class NewFxWMSGetFeatureInfo extends FxHandler
	{
		
		public function NewFxWMSGetFeatureInfo()
		{
			this.handler = new NewWMSGetFeatureInfo();
			super();
		}
		
		public function set maxFeatures(maxFeatures:Number):void {
			(this.handler as NewWMSGetFeatureInfo).maxFeatures = maxFeatures;
		}
		
		public function set drillDown(drillDown:Boolean):void{
			(this.handler as NewWMSGetFeatureInfo).drillDown = drillDown;
		}
		
		public function set format(infoFormat:String):void {
			(this.handler as NewWMSGetFeatureInfo).infoFormat = infoFormat;
		}
		
		public function set layers(layers:String):void {
			(this.handler as NewWMSGetFeatureInfo).layers = layers;
		}
	}
}