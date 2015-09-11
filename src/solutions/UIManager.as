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
	import solutions.event.AppEvent;
	import flash.events.EventDispatcher;
	import mx.collections.ArrayCollection;
	import mx.core.FlexGlobals;
	import solutions.event.AppEvent;
    
    public class UIManager extends EventDispatcher
	{
		
		private var container:SiteContainer = SiteContainer.getInstance();
		
		private var configData:ConfigData;		
		
		public function UIManager()
		{
			super();
			SiteContainer.addEventListener(AppEvent.CONFIG_LOADED, config);
		}		
		
		private function config(event:AppEvent):void
		{
			configData = event.data as ConfigData;
			for (var i:Number = 0; i < configData.configUI.length; i++)
	        {
	        	var id:String = configData.configUI[i].id;
	        	var value:String =  configData.configUI[i].value;
	        	if (id == "stylesheet")
	        	{
	        		FlexGlobals.topLevelApplication.styleManager.loadStyleDeclarations(value);
	        	}
	        }      
		}
		
	}
}