package widgets.componentes.printpreview.utils
{

	import widgets.componentes.printpreview.utils.ModelLocator;
	import widgets.componentes.printpreview.utils.*;
	
	import mx.core.Application;
	import solutions.ToolsBase;
	
	public class Controller
	{
		/**
		 * Controller constructor 
		 * 
		 */		
		public function Controller()
		{
			_model.popupArray = new Array();
			_model.popupNameArray = new Array();
		}
		
		private static var _instance:Controller = null;
		private var _model:ModelLocator = ModelLocator.getInstance();
		
		/**
		 * Get instance of Controller 
		 * @return 
		 * 
		 */		
		public static function getInstance():Controller
		{
			if(_instance==null)
			{
				_instance=new Controller();
			}
			return _instance;
		}

				
		/**
		 * Load Pop Up 
		 * @param _type 
		 */			
 		public function loadPopUp(_type:*, target:String):void
		{
			minimisedAllPopUps();			
			//Instantiate new pop up 
			var tool:ToolsBase = new _type();
            Application.application.loadPopUp(tool, _type, target);	
            //Store pop up in array
            if(!(tool is LayersTool))
			{
            	_model.popupArray.push(tool);
   			}	
		} 

		/**
		 * Minimise Pop Ups
		 * @param _type 
		 */			
 		public function minimisedAllPopUps():void
		{
			//Minimise all open windows
			for each(var item:* in _model.popupArray)
			{
				if(_model.openTool != null)
				{
					if(!(_model.openTool is LayersTool))
					{
						item.minimizePanel(_model.openTool);
					}
				}
			}					
		}
		
		/**
		 * Restore Pop Up 
		 * @param _type 
		 */			
 		public function restorePopUp(_popup:*):void
		{
			Application.application.restorePopUp(_popup)
		} 	
		
		/**
		 * Load Pop Up 
		 * @param _type 
		 */			
 		public function setOpenTool(_popup:*):void
		{
			_model.openTool = _popup;
		} 		
		
		/**
		 * Updates the model when the navigation changes 
		 */
		public function updateView(view:String):void
		{
			if(view != "layers")
			{
				_model.selectedView = view;	
			}			
		}
		/**
		 * Store the name of each open pop up 
		 **/
		public function updatePopupNameArray(target:String):void
		{
			_model.popupNameArray.push(target);
		}
		
		/**
		 * Remove popup from array
		 **/
		public function unloadArrayPopUp(tool:*):void
		{
			_model.popupArray.splice(_model.popupArray.indexOf(tool), 1);
		}
		/**
		 * Remove popup name from array
		 **/		
		public function unloadPopUpNameArray(target:String):void
		{
			_model.popupNameArray.splice(_model.popupNameArray.indexOf(target), 1);
		}
		/**
		 * Remove minimised item from VBox
		 **/ 
		public function removeMinimisedItem(tool:*):void
		{
			_model.popupholder.removeChild(tool);
		}		
	}
}
