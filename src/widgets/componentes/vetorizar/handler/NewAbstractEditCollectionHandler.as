package widgets.componentes.vetorizar.handler
{
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	import mx.collections.ArrayCollection;
	import mx.controls.Alert;
	
	import org.openscales.core.Map;
	import org.openscales.core.events.FeatureEvent;
	import org.openscales.core.events.LayerEvent;
	import org.openscales.core.events.MapEvent;
	import org.openscales.core.feature.Feature;
	import org.openscales.core.feature.PointFeature;
	import org.openscales.core.feature.State;
	import org.openscales.core.handler.feature.FeatureClickHandler;
	import org.openscales.core.handler.feature.draw.AbstractEditHandler;
	import org.openscales.core.layer.VectorLayer;
	import org.openscales.core.style.Style;
	import org.openscales.geometry.Geometry;
	import org.openscales.geometry.ICollection;
	import org.openscales.geometry.Point;
	import org.openscales.geometry.basetypes.Location;
	import org.openscales.geometry.basetypes.Pixel;
	
	
	/** 
	 * @eventType org.openscales.core.events.LayerEvent.LAYER_EDITION_MODE_START
	 */ 
	[Event(name="openscales.layerEditionModeStart", type="org.openscales.core.events.LayerEvent")]
	
	/**
	 * This class is a handler used for Collection(Linestring Polygon MultiPolygon etc..) modification
	 * don't use it use EditPathHandler if you want to edit a LineString or a MultiLineString
	 * or EditPolygon 
	 * */
	public class NewAbstractEditCollectionHandler extends AbstractEditHandler
	{
		/**
		 * index of the feature currently drag in the geometry collection
		 * 
		 * */
		protected var indexOfFeatureCurrentlyDrag:int=-1;
		
		/**
		 * This singleton represents the point under the mouse during the dragging operation
		 * */
		public static var _pointUnderTheMouse:PointFeature=null;
		
		/**
		 * The point that is created under the mouse in edition mode.
		 */
		private var _dummyPointOnTheMouse:Feature;
		/**
		 * This tolerance is used to manage the point on the segments
		 * */
		private var _detectionTolerance:Number=2;
		/**
		 * This tolerance is used to discern Virtual vertices from point under the mouse
		 * */
		private var _ToleranceVirtualReal:Number=10;
		/**
		 * We use a timer to manage the mouse out of a feature
		 */
		private var _timer:Timer = new Timer(500,1);
		/**
		 * To know if we displayed the virtual vertices of collection feature or not
		 **/
		private var _displayedVirtualVertices:Boolean=true;
				
		private var tmpfeature:Vector.<Vector.<Feature>>;
		
		
		/**
		 * This class is a handler used for Collection(Linestring Polygon MultiPolygon etc..) modification
		 * don't use it use EditPathHandler if you want to edit a LineString or a MultiLineString
		 * or EditPolygon 
		 * */
		public function NewAbstractEditCollectionHandler(map:Map=null, active:Boolean=false, layerToEdit:VectorLayer=null, featureClickHandler:FeatureClickHandler=null,drawContainer:Sprite=null,isUsedAlone:Boolean=true)
		{
			super(map, active, layerToEdit, featureClickHandler,drawContainer,isUsedAlone);
			this.featureClickHandler = featureClickHandler;
			this._timer.addEventListener(TimerEvent.TIMER, deletepointUnderTheMouse);
		}
		/**
		 * This function is used for Polygons edition mode starting
		 * 
		 * */
		override public function editionModeStart():Boolean
		{
			for each(var vectorFeature:Feature in this._layerToEdit.features)
			{	
				if(vectorFeature.isEditable && vectorFeature.geometry is ICollection)
				{			
					//Clone or not
					if(displayedVirtualVertices)displayVisibleVirtualVertice(vectorFeature);
				}
			}
			
			if(_isUsedAlone)
			{
				this.map.dispatchEvent(new LayerEvent(LayerEvent.LAYER_EDITION_MODE_START,this._layerToEdit));	
				this.map.addEventListener(FeatureEvent.FEATURE_MOUSEMOVE,createPointUndertheMouse);
			}		
			
			return true;
		}
		
		/**
		 * @inheritDoc 
		 * */
		override public function editionModeStop():Boolean
		{
			//if the handler is used alone we remove the listener
			if(_isUsedAlone)
			{
				this.map.removeEventListener(FeatureEvent.FEATURE_MOUSEMOVE,createPointUndertheMouse);
			}
			
			this._timer.removeEventListener(TimerEvent.TIMER, deletepointUnderTheMouse);	
			
			removeVisibleVirtualVertice();
			
			super.editionModeStop();
			
			return true;
		} 
		
		/**
		 * @inheritDoc 
		 * */
		override public function dragVerticeStart(vectorfeature:PointFeature):void
		{
			if(vectorfeature!=null)
			{
				var parentFeature:Feature=findVirtualVerticeParent(vectorfeature);
				
				if(parentFeature && parentFeature.geometry is ICollection)
				{
					//We start to drag the vector feature
					vectorfeature.startDrag();
					//We see if the feature already belongs to the edited vector feature
					indexOfFeatureCurrentlyDrag=findIndexOfFeatureCurrentlyDrag(vectorfeature);
					
					if(vectorfeature != NewAbstractEditCollectionHandler._pointUnderTheMouse)
						this._featureCurrentlyDrag=vectorfeature;
					else
						this._featureCurrentlyDrag=null;
					
					//we add the new mouseEvent move and remove the previous
					_timer.stop();
					
					this.map.mouseNavigationEnabled = false;
					this.map.panNavigationEnabled = false;
					this.map.zoomNavigationEnabled = false;
					this.map.keyboardNavigationEnabled = false;
					this.map.addEventListener(MouseEvent.MOUSE_MOVE,drawTemporaryFeature);
					
					if(_isUsedAlone)
					{
						this.map.removeEventListener(FeatureEvent.FEATURE_MOUSEMOVE,createPointUndertheMouse);
					}
				}
			}
			
		}
		
		override protected function displayVisibleVirtualVertice(featureEdited:Feature):void
		{
			//super.displayVisibleVirtualVertice(featureEdited);
			if(featureEdited!=null) {
				//We only draw the points included in the map extent
				tmpfeature =new Vector.<Vector.<Feature>>();	
				var feature:Feature;
				var i:int = _editionFeatureArray.length - 1;
				for(i;i>-1;--i){
					feature=_editionFeatureArray[i][0];
					var featureParent:Feature = super.findVirtualVerticeParent(feature  as PointFeature);
					//we also clean the virtual vertices array if the parent doesnt belongs anymore to the _layerToEdit.features array
					if(featureParent==featureEdited || this._layerToEdit.features.indexOf(featureParent)==-1){
						this._layerToEdit.removeFeature(feature);
						this._featureClickHandler.removeControledFeature(feature);
						tmpfeature.push(_editionFeatureArray[i]);
					}
				}
				//feature to delete
				if(tmpfeature.length!=0){
					//for each(feature in tmpfeature){
					i = tmpfeature.length - 1;
					var j:int;
					for(i;i>-1;--i){
						j = _editionFeatureArray.indexOf(tmpfeature[i]);
						if(j!=-1)
							_editionFeatureArray.splice(j,1);
					}
					tmpfeature= new Vector.<Vector.<Feature>>();
				}
				super.createEditionVertices(featureEdited,featureEdited.geometry as ICollection,tmpfeature);
				var v:Vector.<Feature>;
				for each(v in tmpfeature){
					this._layerToEdit.addFeature(v[0]);
					this._featureClickHandler.addControledFeature(v[0]);
					feature = v[0];
					v = new Vector.<Feature>();
					v[0]=feature;
					v[1]=featureEdited;
					this._editionFeatureArray.push(v);
					v=null;
				}
				//for garbage collector
				//tmpfeature=null;	
			}
		}
		
		public function removeVisibleVirtualVertice():void
		{
			var v:Vector.<Feature>;
			var feature:Feature;
			
			if (tmpfeature)
			{
				for each(v in tmpfeature)
				{
					this._layerToEdit.removeFeature(v[0]);
					this._featureClickHandler.removeControledFeature(v[0]);
					this._editionFeatureArray = new Vector.<Vector.<Feature>>;
				}
				v=null;
				tmpfeature=null;
			}
		}
		
		
		/**
		 * @inheritDoc 
		 * */
		override  public function dragVerticeStop(vectorfeature:PointFeature):void{
			if(vectorfeature!=null){
				//We stop the drag 
				vectorfeature.stopDrag();
				//var parentGeometry:Collection=vectorfeature.editionFeatureParentGeometry as Collection;
				var parentFeature:Feature=findVirtualVerticeParent(vectorfeature);
				if(parentFeature && parentFeature.geometry is ICollection){
					var parentGeometry:ICollection=editionFeatureParentGeometry(vectorfeature,parentFeature.geometry as ICollection);
					var componentLength:Number=parentGeometry.componentsLength;
					this._layerToEdit.removeFeature(vectorfeature);
					this._featureClickHandler.removeControledFeature(vectorfeature);
					if(parentGeometry!=null){
						var lonlat:Location=this.map.getLocationFromMapPx(new Pixel(this._layerToEdit.mouseX,this._layerToEdit.mouseY)); //this.map.getLocationFromLayerPx(new Pixel(this._layerToEdit.mouseX,this._layerToEdit.mouseY));			
						var newVertice:Point=new Point(lonlat.lon,lonlat.lat);
						//if it's a real vertice of the feature
						if(vectorfeature != NewAbstractEditCollectionHandler._pointUnderTheMouse)
							parentGeometry.replaceComponent(indexOfFeatureCurrentlyDrag,newVertice);
						else
							parentGeometry.addComponent(newVertice,indexOfFeatureCurrentlyDrag);
						if(displayedVirtualVertices)
							displayVisibleVirtualVertice(findVirtualVerticeParent(vectorfeature as PointFeature));	 
					} 	
				}
			}
			//we add the new mouseEvent move and remove the MouseEvent on the draw Temporary feature
			this._layerToEdit.removeFeature(NewAbstractEditCollectionHandler._pointUnderTheMouse);	
			if(_isUsedAlone)this.map.addEventListener(FeatureEvent.FEATURE_MOUSEMOVE,createPointUndertheMouse);
			this.map.removeEventListener(MouseEvent.MOUSE_MOVE,drawTemporaryFeature);
			this.map.mouseNavigationEnabled = true;
			this.map.panNavigationEnabled = true;
			this.map.zoomNavigationEnabled = true;
			this.map.keyboardNavigationEnabled = true;
			this._featureCurrentlyDrag=null;
			
			//We remove the point under the mouse if it was dragged
			if(NewAbstractEditCollectionHandler._pointUnderTheMouse!=null)
			{
				this._layerToEdit.removeFeature(NewAbstractEditCollectionHandler._pointUnderTheMouse);
				this._featureClickHandler.removeControledFeature(NewAbstractEditCollectionHandler._pointUnderTheMouse);
				NewAbstractEditCollectionHandler._pointUnderTheMouse=null;
			}
			
			this._drawContainer.graphics.clear();
			vectorfeature=null;
			_timer.stop();
			//vectorfeature.editionFeatureParent.draw();
			this._layerToEdit.redraw();
		}
		
		/**
		 * @inheritDoc 
		 * */
		override public function featureClick(event:FeatureEvent):void
		{
			var vectorfeature:PointFeature=event.feature as PointFeature;

			//We remove listeners and tempoorary point
			//This is a bug we redraw the layer with new vertices for the impacted feature
			//The click is considered as a bug for the moment	 	
			if(displayedVirtualVertices)
				displayVisibleVirtualVertice(findVirtualVerticeParent(vectorfeature as PointFeature));
			
			this._layerToEdit.removeFeature(NewAbstractEditCollectionHandler._pointUnderTheMouse);
			this._layerToEdit.removeFeature(vectorfeature);
			this._featureClickHandler.removeControledFeature(vectorfeature);
			vectorfeature = null;
			
			if(_isUsedAlone)
				this.map.addEventListener(FeatureEvent.FEATURE_MOUSEMOVE,createPointUndertheMouse);
			
			this.map.removeEventListener(MouseEvent.MOUSE_MOVE,drawTemporaryFeature);
			
			this._featureCurrentlyDrag=null;
			//we remove it
			if(NewAbstractEditCollectionHandler._pointUnderTheMouse!=null)
			{
				this._layerToEdit.removeFeature(NewAbstractEditCollectionHandler._pointUnderTheMouse);
				
				NewAbstractEditCollectionHandler._pointUnderTheMouse=null;
			}
			
			this._drawContainer.graphics.clear();
			
			_timer.stop();
			
			this._layerToEdit.redraw();
		}
		
		
		/**
		 * @inheritDoc 
		 * */
		override public function featureDoubleClick(event:FeatureEvent):void
		{
			var vectorfeature:PointFeature=event.feature as PointFeature;
			
			var parentFeature:Feature=findVirtualVerticeParent(vectorfeature);
			
			if(parentFeature && parentFeature.geometry is ICollection)
			{
				var parentGeometry:ICollection=editionFeatureParentGeometry(vectorfeature,parentFeature.geometry as ICollection);
				var index:int=IsRealVertice(vectorfeature,parentGeometry);
				
				if(index != -1)
				{	 		
					parentGeometry.removeComponent(parentGeometry.componentByIndex(index));
					
					//add
					if(parentGeometry.componentsLength == 1)
					{
						parentGeometry.removeComponent(parentGeometry.componentByIndex(0));
						this._layerToEdit.removeFeature(parentFeature);
					}
					
					if(displayedVirtualVertices)
						displayVisibleVirtualVertice(findVirtualVerticeParent(vectorfeature as PointFeature));
				}
				//we delete the point under the mouse 
				this._layerToEdit.removeFeature(NewAbstractEditCollectionHandler._pointUnderTheMouse);
				
				if(_isUsedAlone)
				{
					this.map.addEventListener(FeatureEvent.FEATURE_MOUSEMOVE,createPointUndertheMouse);
				}
				
				this.map.removeEventListener(MouseEvent.MOUSE_MOVE,drawTemporaryFeature);
				this._featureCurrentlyDrag=null;
				
				if(NewAbstractEditCollectionHandler._pointUnderTheMouse!=null)
				{
					this._layerToEdit.removeFeature(NewAbstractEditCollectionHandler._pointUnderTheMouse);
					NewAbstractEditCollectionHandler._pointUnderTheMouse=null;
				}
				
				this._drawContainer.graphics.clear();
				_timer.stop();
				
				this._layerToEdit.redraw();
				this.map.mouseNavigationEnabled = true;
				this.map.panNavigationEnabled = true;
				this.map.zoomNavigationEnabled = true;
				this.map.keyboardNavigationEnabled = true;
			}
		}
		
		/**
		 * This function is used to manage the mouse when the mouse is out of the feature
		 * */
		public function onFeatureOut(evt:FeatureEvent):void
		{	 	
			_timer.start();
		}
		private function deletepointUnderTheMouse(evt:TimerEvent):void
		{
			//we hide the point under the mouse
			if(NewAbstractEditCollectionHandler._pointUnderTheMouse!=null)
			{
				NewAbstractEditCollectionHandler._pointUnderTheMouse.visible=false;
				layerToEdit.removeFeature(NewAbstractEditCollectionHandler._pointUnderTheMouse);
			}
			
			_timer.stop();
		}
		
		private function filterCallbackOnPointUnderTheMouse(item:Vector.<Feature>, index:int, vector:Vector.<Vector.<Feature>>):Boolean {
			if (item[0] == this._dummyPointOnTheMouse)
			{
				return false
			}
			
			return true;
		}
		/**
		 * Create a virtual vertice under the mouse 
		 * */
		public function createPointUndertheMouse(evt:FeatureEvent):void
		{
			var vectorfeature:Feature=evt.feature as Feature;
			
			if ((vectorfeature != null) && (vectorfeature.layer == _layerToEdit) && (vectorfeature.geometry is ICollection))
			{
				_timer.stop();
				
				vectorfeature.buttonMode = false; 
				
				var px:Pixel = new Pixel(this._layerToEdit.mouseX,this._layerToEdit.mouseY);
				
				//drawing equals false if the mouse is too close from Virtual vertice
				var drawing:Boolean = true;
				
				if (this._dummyPointOnTheMouse)
				{
					_editionFeatureArray = _editionFeatureArray.filter(this.filterCallbackOnPointUnderTheMouse);
				}
				
				for(var i:int = 0; i < _editionFeatureArray.length; i++)
				{
					var feature:Feature = _editionFeatureArray[i][0] as Feature;
					
					if((feature != null) && (feature != NewAbstractEditCollectionHandler._pointUnderTheMouse) &&  (vectorfeature == _editionFeatureArray[i][1]))
					{
						var tmpPx:Pixel=this.map.getMapPxFromLocation(new Location((feature.geometry as Point).x,(feature.geometry as Point).y));
						
						if(Math.abs(tmpPx.x-px.x)<this._ToleranceVirtualReal && Math.abs(tmpPx.y-px.y)<this._ToleranceVirtualReal)
						{
							drawing=false;
							break;
						}
					}
				}
				
				if(drawing)
				{
					var tmpPoints:Vector.<Feature> = new Vector.<Feature>;
					
					layerToEdit.map.buttonMode = true;
					
					var lonlat:Location=this.map.getLocationFromMapPx(px);
					lonlat.reprojectTo(vectorfeature.projection);//this.map.getLocationFromLayerPx(px);
					
					var PointGeomUnderTheMouse:Point=new Point(lonlat.lon,lonlat.lat);
					PointGeomUnderTheMouse.projection = lonlat.projection;
					
					if(NewAbstractEditCollectionHandler._pointUnderTheMouse != null)
					{
						NewAbstractEditCollectionHandler._pointUnderTheMouse.visible = false;
						tmpPoints.push(NewAbstractEditCollectionHandler._pointUnderTheMouse);
												
						NewAbstractEditCollectionHandler._pointUnderTheMouse = new PointFeature(PointGeomUnderTheMouse, null, this.virtualStyle);
						this._featureClickHandler.addControledFeature(NewAbstractEditCollectionHandler._pointUnderTheMouse);
					}
					else
					{
						NewAbstractEditCollectionHandler._pointUnderTheMouse = new PointFeature(PointGeomUnderTheMouse,null,this.virtualStyle);
						this._featureClickHandler.addControledFeature(NewAbstractEditCollectionHandler._pointUnderTheMouse);
					}
					
					if(NewAbstractEditCollectionHandler._pointUnderTheMouse.layer == null) 
					{
						layerToEdit.addFeature(NewAbstractEditCollectionHandler._pointUnderTheMouse);
						if (tmpPoints.length > 0)
						{
							layerToEdit.removeFeatures(tmpPoints);
						}
						
						var v:Vector.<Feature> = new Vector.<Feature>();
						v[0] = NewAbstractEditCollectionHandler._pointUnderTheMouse;
						v[1] = vectorfeature;
						
						_editionFeatureArray.push(v);
						
						this._dummyPointOnTheMouse = NewAbstractEditCollectionHandler._pointUnderTheMouse;
					}
					
					if(findIndexOfFeatureCurrentlyDrag(NewAbstractEditCollectionHandler._pointUnderTheMouse) != -1)
					{ 
						NewAbstractEditCollectionHandler._pointUnderTheMouse.visible = true;
					} 
					else
					{
						NewAbstractEditCollectionHandler._pointUnderTheMouse.visible = false;
					}
					
					layerToEdit.redraw();
					layerToEdit.map.buttonMode=false;
				}
				else
				{
					if(NewAbstractEditCollectionHandler._pointUnderTheMouse!=null)
					{
						NewAbstractEditCollectionHandler._pointUnderTheMouse.visible=false;
						layerToEdit.redraw();
						layerToEdit.map.buttonMode=false;		
					}
				}
			}
		}
		/**
		 * To draw the temporaries feature during drag Operation
		 * */
		protected function drawTemporaryFeature(event:MouseEvent):void
		{
			
		}
		
		override public function refreshEditedfeatures(event:MapEvent=null):void
		{
			if(NewAbstractEditCollectionHandler._pointUnderTheMouse)
			{
				this._layerToEdit.removeFeature(NewAbstractEditCollectionHandler._pointUnderTheMouse);
				this._featureClickHandler.removeControledFeature(NewAbstractEditCollectionHandler._pointUnderTheMouse);
				NewAbstractEditCollectionHandler._pointUnderTheMouse=null;
			}
			_layerToEdit.redraw();
		}
		
		/**
		 * To find the index of feature currently dragged in it's geometry parent array
		 * @param vectorfeature:PointFeature the dragged feature
		 */
		public function findIndexOfFeatureCurrentlyDrag(vectorfeature:PointFeature):Number 
		{
			var parentFeature:Feature = findVirtualVerticeParent(vectorfeature);
			
			if (parentFeature && parentFeature.geometry && parentFeature.geometry is ICollection) 
			{
				var parentgeometry:ICollection = editionFeatureParentGeometry(vectorfeature, parentFeature.geometry as ICollection);
				
				if (vectorfeature == NewAbstractEditCollectionHandler._pointUnderTheMouse) 
				{
					return vectorfeature.getSegmentsIntersection(parentgeometry);
				}
				else
				{
					return IsRealVertice(vectorfeature, parentgeometry);
				}
			}
			return -1;
		}
		
		/**
		 * To know if a dragged point is a under the mouse or is a vertice
		 * if it's a point returns its index else returns -1
		 * @private
		 * */
		private function IsRealVertice(vectorfeature:PointFeature,parentgeometry:ICollection):Number
		{
			if(parentgeometry)
			{
				var index:Number=0;		
				var geom:Point=vectorfeature.geometry as Point;
				//for each components of the geometry we see if the point belong to it
				for(index=0;index<parentgeometry.componentsLength;index++)
				{		
					var editionfeaturegeom:Point=parentgeometry.componentByIndex(index) as Point;
					if((vectorfeature.geometry as Point).x==editionfeaturegeom.x && (vectorfeature.geometry as Point).y==editionfeaturegeom.y)
						break;
				}
				
				if(index<parentgeometry.componentsLength) return index;
			}
			return -1;
		}
		/**
		 * This function find a parent Geometry of an edition feature
		 * @param point
		 * TODO: really needs to be rewrited
		 * */
		public function editionFeatureParentGeometry(point:PointFeature,parentGeometry:ICollection):ICollection
		{
			if(point && parentGeometry)
			{
				if(parentGeometry)
				{
					var i:int;
					
					if(parentGeometry.componentsLength==0) 
					{
						return null;
					}
					else
					{
						if(parentGeometry.componentByIndex(0) is Point)
						{
							for(i=0;i<parentGeometry.componentsLength;i++)
							{
								if((point.geometry as Point).equals(parentGeometry.componentByIndex(i) as Point))
								{
									return parentGeometry;
								}	
							}
						}
						else
						{
							for(i=0;i<parentGeometry.componentsLength;i++)
							{
								var geomParent:ICollection=editionFeatureParentGeometry(point,parentGeometry.componentByIndex(i) as ICollection);
								
								if(geomParent!=null)
								{
									return geomParent;
								}
							}
						} 
						
						return parentGeometry as ICollection;
					}
				}
			}
			return null;
		}
		
		//getters && setters
		/**
		 * Tolerance used for detecting  point
		 * */
		public function get detectionTolerance():Number
		{
			return this._detectionTolerance;
		}
		public function set detectionTolerance(value:Number):void
		{	 	
			this._detectionTolerance=value;
		}
		/**
		 * To know if we displayed the virtual vertices of collection feature or not
		 **/
		public function get displayedVirtualVertices():Boolean
		{
			return this._displayedVirtualVertices;
		}
		/**
		 * @private
		 * */
		public function set displayedVirtualVertices(value:Boolean):void
		{
			if(value!=this._displayedVirtualVertices)
			{
				this._displayedVirtualVertices = value;
				
				refreshEditedfeatures();
			}
		}
		
		
	}
}