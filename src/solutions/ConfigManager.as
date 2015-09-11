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
	import flash.events.EventDispatcher;
	import flash.xml.XMLDocument;
	
	import mx.collections.ArrayCollection;
	import mx.controls.Alert;
	import mx.core.FlexGlobals;
	import mx.rpc.events.FaultEvent;
	import mx.rpc.events.ResultEvent;
	import mx.rpc.http.HTTPService;
	
	import solutions.event.AppEvent;
	
	import widgets.componentes.alerta.Alerta;
	import widgets.componentes.seguranca.UserObject;
	
	/**
	 * ConfigManager is used to parse the config.xml file and store the information in ConfigData.
	 */
    [Event(name="configLoaded", type="solutions.event.AppEvent")]
	
    
	public class ConfigManager extends EventDispatcher
	{
		private var _configXml:String = "config.xml";
		
		private var _dadosUsuario:Object = null;
		
		

		public function ConfigManager()
		{
			super();
			//make sure the container is properly initialized and then
			//proceed with configuration initialization.
            //SiteContainer.addEventListener(SiteContainer.CONTAINER_INITIALIZED, init);
		}
        		
		//init - start loading the configuration file and parse.
		public function init(userData:Object=null):void
		{
			if (userData != null)
			{
				_dadosUsuario = userData;
				
				this._configXml = userData.configXml;
			}
			/*else
			{
				var obj:Object = new Object();
				obj.nome = "teste";
				obj.cpf = "00000000000";
				obj.email = "teste"; 
				obj.configXml = "config.xml";
				
				_dadosUsuario = obj;
				
				this._configXml = obj.configXml;
			}*/
				
			configLoad();
		}
			
		//config load
		private function configLoad():void
		{
			//configXml = FlexGlobals.topLevelApplication.application.login.configXml.toString();
			var configService:HTTPService = new HTTPService();

			configService.url = _configXml;
			configService.resultFormat = "e4x";
			configService.addEventListener(ResultEvent.RESULT, configResult);
			configService.addEventListener(FaultEvent.FAULT, configFault);	
			configService.send();
		}
				
		//config fault
		private function configFault(event:mx.rpc.events.FaultEvent):void
		{
			var alerta:Alerta = new Alerta();
				
			var sInfo:String = "Arquivo de configuração: " + _configXml + " possui erros ou não existe.\n\nError: ";
			sInfo += "Event Target: " + event.target + "\n\n";
			sInfo += "Event Type: " + event.type + "\n\n";
			sInfo += "Fault Code: " + event.fault.faultCode + "\n\n";
			sInfo += "Fault Info: " + event.fault.faultString;
			
			alerta.exibirErro(sInfo);
		}
		
		//config result
		private function configResult(event:ResultEvent):void
		{
			try
			{	
				//parse config.xml to create config data object
				var configData:ConfigData = new ConfigData();
				var configXML:XML = event.result as XML;
				var i:int;
				var j:int;
				var value:String;

				//user data
				var userData:UserObject = null;
				
				if (this._dadosUsuario)
				{
					userData = new UserObject()
						
					userData.nome = this._dadosUsuario.nome;
					userData.cpf = this._dadosUsuario.cpf
					userData.email = this._dadosUsuario.email;
					userData.configXml = this._dadosUsuario.configXml;
				}
				configData.userData = userData;
				
				//user interface
				var configUI:Array = [];

				value = configXML..title;
				var title:Object = 
				{
					id: "title",
					value: value
				}
				configUI.push(title);
				
				value = configXML..subtitle;
				var subtitle:Object = 
				{
					id: "subtitle",
					value: value
				}
				configUI.push(subtitle);
				
				value = configXML..logo;
				var logo:Object = 
				{
					id: "logo",
					value: value
				}
				configUI.push(logo);
				
				value = configXML..showSobre;
				var about:Object = 
					{
						id: "about",
						value: value
					}
				configUI.push(about);
				
				value = configXML..showLogin;
				var login:Object = 
					{
						id: "login",
						value: value
					}
				configUI.push(login);
				
				value = configXML..stylesheet;
				var stylesheet:Object = 
				{
					id: "stylesheet",
					value: value
				}
				configUI.push(stylesheet);
				configData.configUI = configUI;
				
				//================================================	
				//menus
				var configMenus:Array = [];
				var menuList:XMLList = configXML..menu;
				var linkList:XMLList = configXML..link;
				var widgetList:XMLList = configXML..widget;
				
				for (i = 0; i < menuList.length(); i++)
				{
					var menuId:String = menuList[i].@id;
					var menuLabel:String = menuList[i];

					if (menuList[i].@visible == "true")
					{
						var basemapItems:Array = [];
						var linkItems:Array = getMenuItems(linkList, menuId, "link");
						var widgetItems:Array = getMenuItems(widgetList, menuId, "widget");
						var menuItems:Array = [];

						menuItems = basemapItems.concat(widgetItems, linkItems);
						var menu:Object = 
						{
							id: menuId,
							label: menuLabel,
							items: menuItems
						}

						configMenus.push(menu);
					}
				}
				configData.configMenus = configMenus;

				
				//=================================================
				//widgets
				var configWidgets:Array = [];
				var wList:XMLList = configXML..widget;
				for (i = 0; i < wList.length(); i++)
				{
					var wLabel:String =wList[i].@label;
					var wIcon:String = wList[i].@icon;
					var wConfig:String = wList[i].@config;
					var wPreload:String = wList[i].@preload;
					var wUrl:String = wList[i];
					var wMenu:String = wList[i].@menu; // synos - para poder montar o menu avançado					
					var widget:Object = 
					{
						id: i,
						label: wLabel,
						icon: wIcon,
						preload: wPreload,
						config: wConfig,
						url: wUrl,
						menu:wMenu
					}

					configWidgets.push(widget);
				}
				configData.configWidgets = configWidgets;
				
				//dispatch event
				SiteContainer.dispatchEvent(new AppEvent(AppEvent.CONFIG_LOADED, false, false, configData));
			}
			catch(error:Error)
			{
				SiteContainer.dispatchEvent(new AppEvent(AppEvent.APP_ERROR, false, false, error.message));		
			}
		}
		
		//get menu items
		private function getMenuItems(xmlList:XMLList, menuId:String, itemAction:String):Array
		{
			var menuItems:Array = [];
			for (var i:int = 0; i < xmlList.length(); i++)
			{
				if (xmlList[i].@menu == menuId)
				{
					var itemLabel:String = xmlList[i].@label;

					var itemIcon:String = xmlList[i].@icon;
					var itemValue:String = xmlList[i];
					
					var menuItem:Object = 
					{
						id: i,
						label: itemLabel,
						icon: itemIcon,
						value: itemValue,
						action: itemAction
					}
					
					menuItems.push(menuItem);
				}
			}
			return menuItems;
		}
		
	}
}