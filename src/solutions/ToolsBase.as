package solutions 
{
	import widgets.componentes.printpreview.utils.Controller;
	import widgets.componentes.printpreview.utils.ModelLocator;
	import widgets.componentes.printpreview.utils.IdentifyTool;
	
	import mx.containers.TitleWindow;
	import mx.controls.Image;
	import mx.core.Application;
	import mx.core.UIComponent;
	import mx.events.CloseEvent;
	import mx.events.MoveEvent;
	import mx.managers.PopUpManager;
	
	import org.openscales.core.layer.ogc.WFS;
	
	import flash.geom.Rectangle;
	import flash.events.MouseEvent;
			
	public class ToolsBase extends WidgetTemplate 
	{
		[Bindable] protected var _model:ModelLocator=ModelLocator.getInstance();
		[Bindable] private var _controller:Controller = Controller.getInstance();
		
		//Title Bar buttons
        [Embed("assets/images/popups/print/maximize.png")]
        private var maximize:Class;
        [Embed("assets/images/popups/print/minimize.png")]
         private var minimize:Class; 
         private var maximizeBtn:Image; 
         protected var panelHeight:Number; 
         protected var isMinimised:Boolean;
         	
		public function ToolsBase()
		{
			this.alpha = 0.9;
	 		//this.showCloseButton = true; 
	 		//this.addEventListener(CloseEvent.CLOSE, closeWindow);
	 		this.styleName = "myPopUp";
		}
		
		/**
		 * Handle Pop up Drag
		**/	 
        protected function window_moveHandler(event:MoveEvent):void
        {
            var window:UIComponent = event.currentTarget as UIComponent;
            var application:UIComponent = Application.application as UIComponent;
            var bounds:Rectangle = new Rectangle(0, 0, application.width, application.height);
            var windowBounds:Rectangle = window.getBounds(application);
			var x:Number;
            var y:Number;
            if (windowBounds.left <= bounds.left)
                x = bounds.left;
            else if (windowBounds.right >= bounds.right)
                x = bounds.right - window.width;
            else
                x = window.x;
            if (windowBounds.top <= bounds.top)
                y = bounds.top;
            else if (windowBounds.bottom >= bounds.bottom)
                y = bounds.bottom - window.height;
            else
                y = window.y;
            window.move(x, y);                
        }
		/**
		 * End Pop up Drag
		**/	           			
        /*private function handleUp(e:Event):void{
            this.stopDrag();
        }			
		/**
		 * Close Pop Up
		**/			
		/*protected function closeWindow(event:Event):void
		{				
         	close(this);
         	_model.selectedtool = "Pan";
		}*/

		public function close(target:*):void
		{
           isMinimised = false;
           var testarray:Array = _model.popupholder.getChildren();
           //If the item is minimised remove it from the vbox
           for each (var item:* in testarray)
  		   {
  				if(item == target)
  				{
 					_controller.removeMinimisedItem(this);
            		isMinimised = true 					
  					break;
  				}
  			}
  		//If the itemised is in main pane and full size
  		//simply close it  
           if(!isMinimised)
           {
           		PopUpManager.removePopUp(target);  
           		//Reset model 
            	_controller.updateView("");	
            	_controller.setOpenTool(null);	
           }
			//Remove this pop up tool
            _controller.unloadArrayPopUp(this);	
            _controller.unloadPopUpNameArray(this.id);	
		}		
		
         /**
         * Handlers for click and mouseovers
         **/
         private function onMaximizeClick ( event:MouseEvent ):void {
           	
           //Minimize panel
           	if(this.height == panelHeight)
           	{
           		minimizePanel(this);
           		maximizeBtn.source = maximize;
           		maximizeBtn.toolTip = "Maximize Window";
           	}
           	//Maximize panel
           	else
           	{
           		maximizePanel();
           		maximizeBtn.source = minimize;
           	}
         }   

 		/**
		 * Process maximise panel
		 **/
		private function maximizePanel():void
		{
			if(this.id != "layers")
			{
				_controller.minimisedAllPopUps();
				//Update active tool
				_controller.updateView(this.id)				
			}
					
			//Restore height
			this.height = panelHeight;
			//Restore the pop up in main window
			_controller.restorePopUp(this);
			isMinimised = false;
			
			if(this is IdentifyTool)
			{
				_model.selectfeature.active = true;
				
				for each(var layer:* in _model.map.layers)
				{
					if(layer is WFS)
					{
						if(!layer.visible)
						{
							layer.visible = true;
						}
					}
				}
			}
		}
		/**
		 * Process minimise panel
		 **/						
		public function minimizePanel(tool:*):void
		{
 			tool.height = 30;
			//Minimise and move to tools Vbox
			_model.popupholder.addChild(tool);
			isMinimised = true;
			_model.openTool = null; 
			
			if(this is IdentifyTool)
			{
				_model.selectfeature.active = false;
				
				for each(var layer:* in _model.map.layers)
				{
					if(layer is WFS)
					{
						layer.visible = false;
					}
				}
			}
		}
		
		/**
		 * Add drag pop up capabilities and minimise button to header
		**/			
		override protected function createChildren():void
		{
        	super.createChildren();
        	
            maximizeBtn = new Image();
            maximizeBtn.source = minimize;
 			maximizeBtn.buttonMode = true;
            maximizeBtn.useHandCursor = true;
            maximizeBtn.mouseChildren = false;        
            maximizeBtn.width = 15;
            maximizeBtn.height = 15;
            maximizeBtn.toolTip = "Minimize Window";
            maximizeBtn.addEventListener( MouseEvent.CLICK, onMaximizeClick );
            //this.titleBar.addChild( maximizeBtn );
                    	
        	//super.titleBar.addEventListener(MouseEvent.MOUSE_UP,handleUp);
        	this.addEventListener(MoveEvent.MOVE, window_moveHandler);
   		}
   					         		
		/**
		 * Minimise/Maximise button
		 **/
		/*override protected function layoutChrome(unscaledWidth:Number, unscaledHeight:Number):void  {
            super.layoutChrome(unscaledWidth, unscaledHeight);
             
             maximizeBtn.move(this.width-43,2);
         }*/  
	}
}