////////////////////////////////////////////////////////////////////////////////
//
// Copyright © 2008 ESRI
//
// All rights reserved under the copyright laws of the United States.
// You may freely redistribute and use this software, with or
// without modification, provided you include the original copyright
// and use restrictions.  See use restrictions in the file:
// <install location>/FlexViewer/License.txt
//
////////////////////////////////////////////////////////////////////////////////

package solutions
{
	import mx.collections.ArrayCollection;
	
	import widgets.componentes.seguranca.UserObject;

	/**
	 * ConfigData class is used to store configuration information from the config.xml file.
	 */
	public class ConfigData
	{
		
		public var configUI:Array;
		
		public var configMenus:Array;
		
		//public var configMap:Array;
		
		//public var configBasemaps:Array;
		
		//public var configExtents:Array;
		
		public var configWidgets:Array;
		
		//public var configData:Array;
		
		public var userData:UserObject;
		
		//public var proxy:String;
				
		//public var appUrl:String // synos
		
		public function ConfigData()
		{
            configUI = [];
            configMenus = [];
           // configMap = [];
            //configBasemaps = [];
            //configExtents = [];
            configWidgets = [];
            //appUrl = '';
			//proxy='';
		}

	}
}