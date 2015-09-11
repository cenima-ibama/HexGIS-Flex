package widgets.componentes.vetorizar.handler.feature.draw
{
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	
	import org.openscales.core.Map;
	import org.openscales.core.events.FeatureEvent;
	import org.openscales.core.events.MapEvent;
	import org.openscales.core.feature.Feature;
	import org.openscales.core.feature.MultiPolygonFeature;
	import org.openscales.core.feature.PointFeature;
	import org.openscales.core.feature.PolygonFeature;
	import org.openscales.core.handler.feature.FeatureClickHandler;
	import org.openscales.core.layer.VectorLayer;
	import org.openscales.core.style.Style;
	import org.openscales.core.utils.Util;
	import org.openscales.geometry.ICollection;
	import org.openscales.geometry.MultiPolygon;
	import org.openscales.geometry.Point;
	import org.openscales.geometry.Polygon;
	import org.openscales.geometry.basetypes.Location;
	import org.openscales.geometry.basetypes.Pixel;
	
	import widgets.componentes.vetorizar.handler.NewAbstractEditCollectionHandler;
	
	/**
	 * This Handler is used for polygon edition 
	 * its extends CollectionHandler
	 * */
	public class NewEditPolygonHandler extends NewAbstractEditCollectionHandler
	{
		public function NewEditPolygonHandler(map:Map = null,active:Boolean = false,layerToEdit:VectorLayer = null,featureClickHandler:FeatureClickHandler = null,drawContainer:Sprite = null,isUsedAlone:Boolean = true,featuresToEdit:Vector.<Feature> = null,virtualStyle:Style = null)
		{
			this.featureClickHandler = featureClickHandler;
			super(map,active,layerToEdit,featureClickHandler,drawContainer,isUsedAlone);
			this.featuresToEdit = featuresToEdit;
			if(virtualStyle == null)
				this.virtualStyle = Style.getDefaultCircleStyle();
				//this.virtualStyle = Style.getDefaultPointStyle();
			else
				this.virtualStyle = virtualStyle;
		}
		
		/**
		 * @inheritDoc 
		 * */
		override public function dragVerticeStart(vectorfeature:PointFeature):void{
			//The feature edited  is the parent of the virtual vertice
			var featureEdited:Feature=findVirtualVerticeParent(vectorfeature as PointFeature);
			if(featureEdited!=null && (featureEdited is PolygonFeature || featureEdited is MultiPolygonFeature)){
				super.dragVerticeStart(vectorfeature);
			}
			
		}
		/**
		 * @inheritDoc 
		 * */
		override  public function dragVerticeStop(vectorfeature:PointFeature):void{
			//The feature edited  is the parent of the virtual vertice
			var featureEdited:Feature=findVirtualVerticeParent(vectorfeature as PointFeature);
			if(featureEdited!=null && (featureEdited is PolygonFeature || featureEdited is MultiPolygonFeature)){
				super.dragVerticeStop(vectorfeature);
				this.map.dispatchEvent(new FeatureEvent(FeatureEvent.FEATURE_EDITED_END,featureEdited));	 
			}
		}
		/**
		 * @inheritDoc 
		 * */
		override public function refreshEditedfeatures(event:MapEvent=null):void{
			
			if(_layerToEdit!=null && !_isUsedAlone){
				for each(var feature:Feature in this.featuresToEdit){	
					//if(feature.isEditable && (feature.geometry is Polygon || feature.geometry is MultiPolygon)){
					if((feature.geometry is Polygon || feature.geometry is MultiPolygon)){
						//We display on the layer concerned by the operation the virtual vertices used for edition
						displayVisibleVirtualVertice(feature);
					}
						//Virtual vertices treatment
					else if(feature is Point /* && Util.indexOf(this._editionFeatureArray,feature)!=-1 */)
					{
						var i:int = this._editionFeatureArray.length - 1;
						for(i;i>-1;--i){
							if(this._editionFeatureArray[i][0]==feature){
								//We remove the edition feature to create another 						
								//TODO Damien nda only delete the feature concerned by the operation
								_layerToEdit.removeFeature(feature);
								this._featureClickHandler.removeControledFeature(feature);
								this._editionFeatureArray.splice(i,1);
								feature.destroy();
								feature=null;
							}
						}
					} 
					else this._featureClickHandler.addControledFeature(feature);
				}
			}
			super.refreshEditedfeatures();
		}
		
		/**
		 * @inheritDoc 
		 * */
		override protected function drawTemporaryFeature(event:MouseEvent):void{
			var pointUnderTheMouse:Boolean=false;
			var parentgeom:ICollection=null;
			var parentFeature:Feature; 	
			//We tests if it's the point under the mouse or not
			if(this._featureCurrentlyDrag!=null){
				parentFeature=findVirtualVerticeParent(this._featureCurrentlyDrag as PointFeature)
				parentgeom=editionFeatureParentGeometry(this._featureCurrentlyDrag as PointFeature,parentFeature.geometry as ICollection);
			}
			else{
				
				parentFeature=findVirtualVerticeParent(NewAbstractEditCollectionHandler._pointUnderTheMouse)
				parentgeom=editionFeatureParentGeometry(NewAbstractEditCollectionHandler._pointUnderTheMouse,parentFeature.geometry as ICollection);
				pointUnderTheMouse=true;
				
			}
			//The mouse's button  is always down 
			if(event.buttonDown){
				var point1:Point=null;
				var point2:Point=null;
				var point1Px:Pixel=null;
				var point2Px:Pixel=null;
				//First vertice position 0
				if(indexOfFeatureCurrentlyDrag==0)
				{
					if(pointUnderTheMouse)
					{
						point1=parentgeom.componentByIndex(0) as Point;
						point2=parentgeom.componentByIndex(1) as Point;
					}
					else
					{
						point1=parentgeom.componentByIndex(indexOfFeatureCurrentlyDrag+1) as Point;
						point2=parentgeom.componentByIndex(parentgeom.componentsLength-1) as Point;
					}
				}
					//Last vertice treatment
				else if(indexOfFeatureCurrentlyDrag==parentgeom.componentsLength-1)
				{
					if(pointUnderTheMouse)
					{
						point1=parentgeom.componentByIndex(indexOfFeatureCurrentlyDrag-1) as Point;
						point2=parentgeom.componentByIndex(indexOfFeatureCurrentlyDrag) as Point;
					}
					else
					{
						point1=parentgeom.componentByIndex(0) as Point;
						point2=parentgeom.componentByIndex(parentgeom.componentsLength-2) as Point;
					}
				}
					//Last vertice +1  treatment only  for point under the mouse
				else if(indexOfFeatureCurrentlyDrag==parentgeom.componentsLength)
				{
					if(pointUnderTheMouse)
					{
						point1=parentgeom.componentByIndex(indexOfFeatureCurrentlyDrag-1) as Point;
						point2=parentgeom.componentByIndex(0) as Point;
					}
				}
					//others treatments
				else
				{
					if(pointUnderTheMouse)
					{
						point1=parentgeom.componentByIndex(indexOfFeatureCurrentlyDrag-1) as Point;
						point2=parentgeom.componentByIndex(indexOfFeatureCurrentlyDrag) as Point;
					}
					else
					{
						point1=parentgeom.componentByIndex(indexOfFeatureCurrentlyDrag+1) as Point;
						point2=parentgeom.componentByIndex(indexOfFeatureCurrentlyDrag-1) as Point;
					}
				}
				
				//We draw the temporaries lines of the polygon
				if(point1!=null && point2!=null)
				{
					point1Px=this.map.getMapPxFromLocation(new Location(point1.x,point1.y));
					point2Px=this.map.getMapPxFromLocation(new Location(point2.x,point2.y));
					
					_drawContainer.graphics.clear();
					_drawContainer.graphics.lineStyle(1, 0xFF00BB);	 
					_drawContainer.graphics.moveTo(point1Px.x,point1Px.y);
					_drawContainer.graphics.lineTo(map.mouseX, map.mouseY);
					_drawContainer.graphics.moveTo(point2Px.x,point2Px.y);
					_drawContainer.graphics.lineTo(map.mouseX, map.mouseY);
					_drawContainer.graphics.endFill();
				}
			}
			else
			{
				_drawContainer.graphics.clear();
			}
		}
	}
}