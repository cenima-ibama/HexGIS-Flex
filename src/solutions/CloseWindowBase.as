package solutions
{	
	import flash.utils.ByteArray;
	
	import mx.collections.ArrayCollection;
	import mx.controls.Alert;
	import mx.modules.IModule;
	
	import org.openscales.core.Map;
	import org.openscales.core.feature.Feature;
	import org.openscales.core.layer.Layer;
	import org.vanrijkom.dbf.DbfHeader;
	
	[Frame(factoryClass="mx.core.FlexModuleFactory")]

	public class CloseWindowBase extends CloseWindowTemplate
	{
		[Bindable] public var _feature:Feature;
		
		[Bindable] public var _layer:Layer;
		
		[Bindable] public var _map:Map;
		
		[Bindable] public var _attrList:ArrayCollection;
		
		[Bindable] public var _shapesArray:Array;
		
		[Bindable] public var _dbfHeader:DbfHeader;
		
		[Bindable] public var _dbfByteArray:ByteArray;
		
		
		public function CloseWindowBase()
		{
			super();
		}
		
		public function setFeature(value:Feature):void
		{			
			_feature = value;
		}
		
		public function setLayer(value:Layer):void
		{			
			_layer = value;
		}
		
		public function setAttrList(value:ArrayCollection):void
		{			
			_attrList = value;
		}
		
		public function setShapesArray(value:Array):void
		{			
			_shapesArray = value;
		}
		
		public function setDBFHeader(value:DbfHeader):void
		{			
			_dbfHeader = value;
		}
		
		public function setDBFByteArray(value:ByteArray):void
		{			
			_dbfByteArray = value;
		}
		
		public function setMap(value:Map):void
		{						
			_map = value;
		}
	}
}