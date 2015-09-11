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
	
	import flash.events.Event;
	
	import mx.collections.ArrayCollection;
	import mx.containers.Panel;
	import mx.controls.Alert;
	import mx.events.FlexEvent;
	import mx.modules.Module;
	import mx.rpc.events.FaultEvent;
	import mx.rpc.events.ResultEvent;
	import mx.rpc.http.HTTPService;
	
	import org.openscales.core.Map;
	import org.openscales.core.events.I18NEvent;
	import org.openscales.geometry.basetypes.Pixel;
	
	import spark.components.Panel;
	import solutions.event.AppEvent;

	//import spark.components.TitleWindow;

    /**
     * BaseWidget is the foundation of all widgets. All widgets need to be derived from this BaseWidget class.
     * 
     * <p><b>NOTE</b>: Once the a new widget class is created by extending this BaseWidget class, 
     * the developer is responsible for adding the new widget class to Flex Builder project properties's
     * module table. This allows the new widge be compiled into a SWF file.
     */
    [Event(name="widgetConfigLoaded", type="flash.events.Event")]
	
	[Frame(factoryClass="mx.core.FlexModuleFactory")]
    
	public class BaseWidget extends WidgetTemplate implements IBaseWidget
	{
        /**
        * Indicates the widget is minmized.
        */
        public static const STATE_MINIMIZED:String = "minimized";
        /**
        * Indicates the widget is maxmized.
        */
        public static const STATE_MAXIMIZED:String = "maximized";
		/**
		 *  Indicates the widget is opened.
		*/
		public static const STATE_OPENED:String = "opened";
        /**
        * indicate the state is closed.
        */
        public static const STATE_CLOSED:String = "closed";
        /**
        * The data structure that holds the configuration information parsed by
        * the ConfigManager from config.xml. A widget can access top level configuration
        * information through this property. The WeidgetManager will set it when the 
        * widget is initialized.
        * 
        * @see configData
        * @see ConfigManager
        */
		[Bindable]
        public var configData:ConfigData;     
        /**
        * The XML type of configuration data.
        * @see configData
        */
		[Bindable]
        public var configXML:XML;
        /**
        * It is the currect active map the container shows. The WidgetManager will set its
        * value when a widget is initialized.
        */
		[Bindable]
        public var map:Map;    
        /**
        * the default widget icon.
        */
        //public var widgetIcon:String = "com/esri/solutions/flexviewer/assets/images/icons/i_globe.png";
		[Bindable]
		public var widgetIcon:String;
		
		[Bindable]
		public var widgetManager:WidgetManager;
		
		//public var widgetData:Object;
		
		/*[Bindable]
        public var widgetTitle:String = "Widget";

        [Bindable]
        private var widgetId:Number; */
		[Bindable]
		private var widgetConfig:String;	
		
		[Bindable]
		private var widgetState:String;	
		
		
        private const WIDGET_CONFIG_LOADED:String = "widgetConfigLoaded";   
		
		/*Control*/
		protected var _active:Boolean = false;
		
		//protected var panelHeight:Number;
		
		[Bindable]
		protected var _isReduced:Boolean = false;
		
		/**
		 * Store if this control have been initialized (Event.COMPLETE has been thrown)  
		 */
		protected var _isInitialized:Boolean = false;
		
		/**
		 * BaseWidget constructor.
		 */
		public function BaseWidget()
		{
			super();
			this.addEventListener(FlexEvent.CREATION_COMPLETE, onCreationComplete); 
		}
		
		/**
		 * The Flex side of the control has been created, so activate the control if needed and if the map has been set
		 */
		protected function onCreationComplete(event:Event):void 
		{
			this._isInitialized = true;
						
			if((this.map) && (this.active == false)) 
			{  
				this.active = true;
			}
		}    
		

		public function setData(value:Object):void
		{
			//widgetData = value;
		}
		
		public function setLayerName(value:String):void
		{
		}
		
		/**
		 * Set the widget title. A widget titile can be configured in the config.xml.
		 * 
		 * @param value the title text.
		 */
		public function setWidgetManager(value:WidgetManager):void
		{
			widgetManager = value;
		}
		
		/**
		 * Set the widet ID. A widget ID is a internal generate identifier in number.
		 * 
		 * @param value the Number id.
		 */
		override public function setId(value:Number):void
		{
			super.setId(value);
		}
		/**
		 * Set the widget title. A widget titile can be configured in the config.xml.
		 * 
		 * @param value the title text.
		 */
		override public function setTitle(value:String):void
		{
			super.setTitle(value);
		}
		/**
		 * Set widget icon. A widget icon is JPL or PNG file in 40x40 size and configured
		 * in the config.xml.
		 * 
		 * @param value the icon URL.
		 */
		public function setIcon(value:String):void
		{
			widgetIcon = value;
		}
		/**
		 * Set configuration file URL. A widget can have its own configuration file. The
		 * URL is in the config.xml. The WidgetManager will pass the URL to a widget.
		 * 
		 * @param value the configuration file URL.
		 */
		public function setConfig(value:String):void
		{
			widgetConfig = value;
			this.configLoad();
		}
	    /**
	    * Pass in application level configuration data parsed from config.xml.
	    * 
	    * @param value the configuration data structure object.
	    * @see ConfigData
	    */
		public function setConfigData(value:ConfigData):void
		{
			configData = value;
		}
		/**
		 * Set the widget state.
		 * @param value the state string defined in BaseWidget.
		 */
		override public function setState(value:String):void
		{
			widgetState = value;
			super.setState(value);
		}
		/**
		 * Set a map object reference. Used by WidgetManager to pass in the current
		 * map.
		 * 
		 * @param value the map reference object.
		 */
		public function setMap(value:Map):void
		{			
			this.active = false;
						
			if(this.map == null) //if not null
			{
				map = value;
				// Activate the control 
				this.active = true;
			}
		}
		
		/**
		 * indicates if the control is currently active or not
		 */
		public function get active():Boolean 
		{
			return this._active;
		}
		
		/**
		 * @private
		 */
		public function set active(value:Boolean):void 
		{
			if(value)
				this.activate();
			else
				this.desactivate();
		}
		
		/**
		 * Define the active status to true and
		 * add listeners to the current map to really active the control.
		 */
		public function activate():void
		{
			this._active = true;
			
			if(this.map)
			{
				this.map.addEventListener(I18NEvent.LOCALE_CHANGED,onMapLanguageChange);
			}
		}
		
		/**
		 * Define the active status to false and
		 * remove listeners from the current map (if defined) to really desactive the control.
		 */
		public function desactivate():void
		{
			this._active = false;
			
			if(this.map)
			{
				this.map.removeEventListener(I18NEvent.LOCALE_CHANGED,onMapLanguageChange);
			}
		}
		
		public function set position(px:Pixel):void
		{
			if (px != null) 
			{
				this.x = px.x;
				this.y = px.y;
			}
		}
		
		public function get position():Pixel
		{
			return new Pixel(this.x, this.y);
		}
		
		/**
		 * to be overrided in sub classes
		 */
		public function onMapLanguageChange(event:I18NEvent):void 
		{
		}
		
		/**
		 * Indicates if the control display is normal or reduced
		 * @default false : normal display
		 */
		[Bindable]
		public function get isReduced():Boolean
		{
			return this._isReduced;
		}
		
		public function set isReduced(value:Boolean):void
		{
			this._isReduced = value;
		}
		
		public function toggleDisplay(event:Event = null):void
		{	
			this.isReduced = !this._isReduced;
		}
		
		/**
		 * Add information from widget to DataManager so that it can be shared between widgets
		 * 
		 * @param key the widget name
		 * @param arrayCollection the list of object in infoData structure.
		 */
		public function addSharedData(key:String, arrayCollection:ArrayCollection):void
		{
			var data:Object = 
			{
				key: key,
				collection: arrayCollection
			}
			
			SiteContainer.dispatchEvent(new AppEvent(AppEvent.DATA_ADDED, false, false, data));
			
		}
		
		/**
		 * Fetch shared data from DataManager
		 */
		public function fetchSharedData():void
		{
			SiteContainer.dispatchEvent(new AppEvent(AppEvent.DATA_FETCH));
		}
				
		/**
		 * Show information wWindow based on infoData from widget
		 */
		public function showInfoWindow(infoData:Object):void
		{
			SiteContainer.dispatchEvent(new AppEvent(AppEvent.SHOW_INFOWINDOW, false, false, infoData));
			
		}
				
		/**
		 * Set map action from widget
		 */
		public function setMapAction(action:String, status:String, callback:Function):void
		{
	        var data:Object = 
	        {
	            tool: action,
	            status: status,
	            handler: callback
	        }
		    SiteContainer.dispatchEvent(new AppEvent(AppEvent.SET_MAP_ACTION, false, false, data));	
		}
		/**
		 * Set map navigation mode, such a pan, zoomin, etc.
         * <p>The navigation methods supported are:</p>
         * <listing>
         * pan          (Navigation.PAN)
         * zoomin       (Navigation.ZOOM_IN)
         * zoomout      (Navigation.ZOOM_OUT)
         * zoomfull     (SiteContainer.NAVIGATION_ZOOM_FULL)
         * zoomprevious (SiteContainer.NAVIGATION_ZOOM_PREVIOUS)
         * zoomnext     (SiteContainer.NAVIGATION_ZOOM_NEXT)
         * </listing> 
		 */
		public function setMapNavigation(navMethod:String, status:String):void
		{
			var data:Object =
			{
				tool: navMethod,
				status: status
			}
			SiteContainer.dispatchEvent(new AppEvent(AppEvent.SET_MAP_NAVIGATION, false, false, data));
		}
		/**
		 * This will allow display a error message window.
		 */
		public function showError(errorMessage:String):void
		{
             SiteContainer.dispatchEvent(new AppEvent(AppEvent.APP_ERROR, false, false, errorMessage));
		}
		
		//config load
		private function configLoad():void
		{
			if (widgetConfig)
			{
				var configService:HTTPService = new HTTPService();
				configService.url = widgetConfig;
				configService.resultFormat = "e4x";
				configService.addEventListener(ResultEvent.RESULT, configResult);
				configService.addEventListener(FaultEvent.FAULT, configFault);	
				configService.send();
			}
		}
				
		//config fault
		private function configFault(event:mx.rpc.events.FaultEvent):void
		{
			var sInfo:String = "Error: ";
			sInfo += "Event Target: " + event.target + "\n\n";
			sInfo += "Event Type: " + event.type + "\n\n";
			sInfo += "Fault Code: " + event.fault.faultCode + "\n\n";
			sInfo += "Fault Info: " + event.fault.faultString;
			showError(sInfo);
		}
				
		//config result
		private function configResult(event:ResultEvent):void
		{
			try
			{	
				configXML = event.result as XML;
				//Alert.show(configXML.toString());
				/*if( configXML.url.toString().toLowerCase().indexOf('url') > -1)
				{
					configXML.url = configXML.url.toString().replace('{appUrl}',configData.appUrl);
				}*/
				SiteContainer.dispatchEvent(new AppEvent(AppEvent.WIDGET_CONFIG_LOADED));
			}
			catch (error:Error)
			{
				showError("A problem occured while parsing the widget configuration file. " + error.message);
			}
		}
		
		
		/**
		 * Indicates if the control display is normal or reduced
		 * @default false : normal display
		 */
		/*[Bindable]
		public function get isReduced():Boolean
		{
			return this._isReduced;
		}
		
		public function set isReduced(value:Boolean):void
		{
			this._isReduced = value;
		}
		
		public function toggleDisplay(event:Event = null):void
		{	
			this.isReduced = !this._isReduced;
		}*/
		
	}
}