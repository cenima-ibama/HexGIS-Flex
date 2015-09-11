package widgets.componentes.printpreview.utils
{
	import mx.containers.VBox;
	
	import org.openscales.core.Map;
	import org.openscales.core.basetypes.LonLat;
	import org.openscales.core.feature.Feature;
	import org.openscales.fx.handler.FxHandler;
	import org.openscales.fx.handler.feature.FxSelectFeaturesHandler;
	import solutions.ToolsBase;
	
	/**
	 * 
	 * @author msheehan
	 * 
	 */	
	[Bindable]
	public class ModelLocator
	{
		private static var _instance:ModelLocator=null;
		//map
		public var map:Map;
		public var mapclone:Object;
		public var initialmapcentre:LonLat;
		public var initialZoom:Number;
		//header
		public var logo:String;
		public var title:String;
		public var subtitle:String;
		public var selectedtool:String = "Pan";
		public var headercolourtop:String;
		public var headercolourbottom:String;
		//legend
		public var mapLegend:VBox;
		//zoom
		public var maxzoomlevel:Number;
		//basic tools
		public var fullextent:Boolean;
		public var layers:Boolean;
		public var overview:Boolean;
		public var draw:Boolean;
		public var print:Boolean;
		public var addresssearch:Boolean;
		public var identify:Boolean;
		public var help:Boolean;
		//search tools
		public var searchtools:Boolean;
		public var address:Boolean;
		public var clearSearch:Function;
		//advanced tools
		public var advancedtools:Boolean;	
		//Pop ups
		public var selectedView:String;	
		public var openTool:ToolsBase;
		public var popupArray:Array;
		public var popupNameArray:Array;
		public var popupholder:VBox;
		//Layers
		public var layersArray:Array;
		//Identify
		public var selectfeature:FxSelectFeaturesHandler;
		public var wfsArray:Array;
		public var selectedFeaturearray:Array;
		public var feature:Feature;
		public var featureLayerName:String;
		//draw
		public var draghandler:FxHandler;
		public var disablepan:Boolean;
		
		/**
		 * ModelLocator constructor 
		 * 
		 */		
		public function ModelLocator()
		{
			
		}
		/**
		 * Returns instance of Model Locator 
		 * @return 
		 * 
		 */		
		public static function getInstance():ModelLocator
		{
			if(_instance==null)
			{
				_instance=new ModelLocator();
			}
			return _instance;
		}
	}
}