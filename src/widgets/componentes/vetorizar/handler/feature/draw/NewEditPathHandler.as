package widgets.componentes.vetorizar.handler.feature.draw
{
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	
	import org.openscales.core.Map;
	import org.openscales.core.events.FeatureEvent;
	import org.openscales.core.events.MapEvent;
	import org.openscales.core.feature.Feature;
	import org.openscales.core.feature.LineStringFeature;
	import org.openscales.core.feature.MultiLineStringFeature;
	import org.openscales.core.feature.PointFeature;
	import org.openscales.core.handler.feature.FeatureClickHandler;
	import org.openscales.core.layer.VectorLayer;
	import org.openscales.core.style.Style;
	import org.openscales.core.utils.Util;
	import org.openscales.geometry.Collection;
	import org.openscales.geometry.ICollection;
	import org.openscales.geometry.LineString;
	import org.openscales.geometry.MultiLineString;
	import org.openscales.geometry.Point;
	import org.openscales.geometry.basetypes.Location;
	import org.openscales.geometry.basetypes.Pixel;
	
	import widgets.componentes.vetorizar.handler.NewAbstractEditCollectionHandler;
	
	/**
	 * This Handler is used for Path edition 
	 * its extends CollectionHandler
	 * */
	public class NewEditPathHandler extends NewAbstractEditCollectionHandler
	{
		public function NewEditPathHandler(map:Map = null,active:Boolean = false,layerToEdit:VectorLayer = null,featureClickHandler:FeatureClickHandler = null,drawContainer:Sprite = null,isUsedAlone:Boolean = true,featuresToEdit:Vector.<Feature> = null,virtualStyle:Style = null)
		{
			this.featureClickHandler = featureClickHandler;
			super(map,active,layerToEdit,featureClickHandler,drawContainer,isUsedAlone);
			this.featuresToEdit = featuresToEdit;
			if(virtualStyle == null)
				this.virtualStyle = Style.getDefaultCircleStyle();
			else
				this.virtualStyle = virtualStyle;
		}
		
		/**
		 * @inheritDoc 
		 * */
		override public function dragVerticeStart(vectorfeature:PointFeature):void{
			// The feature edited is the parent of the virtual vertice
			var featureEdited:Feature = findVirtualVerticeParent(vectorfeature as PointFeature);
			if(featureEdited != null && (featureEdited is LineStringFeature || featureEdited is MultiLineStringFeature)){
				super.dragVerticeStart(vectorfeature);
			}
		}
		
		/**
		 * @inheritDoc 
		 * */
		override public function dragVerticeStop(vectorfeature:PointFeature):void{
			// The feature edited is the parent of the virtual vertice
			var featureEdited:Feature = findVirtualVerticeParent(vectorfeature as PointFeature);
			if(featureEdited != null && (featureEdited is LineStringFeature || featureEdited is MultiLineStringFeature)){
				this.map.dispatchEvent(new FeatureEvent(FeatureEvent.FEATURE_EDITED_END,featureEdited));
				return super.dragVerticeStop(vectorfeature);
			}
		}
		
		/**
		 * @inheritDoc 
		 * */
		override public function refreshEditedfeatures(event:MapEvent = null):void{
			
			if(_layerToEdit != null && !_isUsedAlone){
				for each(var feature:Feature in this.featuresToEdit){
					if((feature.geometry is LineString || feature.geometry is MultiLineString)){
						// We display on the layer concerned by the operation the virtual vertices used for edition
						// If the virtual vertices have to be displayed we displayed them
						if(displayedVirtualVertices)
							displayVisibleVirtualVertice(feature);
					}
						// Virtual vertices treatment ?
					else if(feature is Point)
					{
						var j:int;
						var i:int = this._editionFeatureArray.length - 1;
						for(i; i>-1; --i){
							if(this._editionFeatureArray[i][0] == feature){
								//We remove the edition feature to create another 						
								//TODO Damien nda only delete the feature concerned by the operation
								layerToEdit.removeFeature(feature);
								this._featureClickHandler.removeControledFeature(feature);
								this._editionFeatureArray.splice(i,1);
								feature.destroy();
								feature=null;
							}
						}
					} 
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
			//the feature currently dragged is a real vertice
			if(this._featureCurrentlyDrag!=null){
				parentFeature=findVirtualVerticeParent(this._featureCurrentlyDrag as PointFeature)
				parentgeom=editionFeatureParentGeometry(this._featureCurrentlyDrag as PointFeature,parentFeature.geometry as ICollection);
			}
				//the feature currently dragged is a point under the mouse 	
			else{
				// parentgeom=AbstractEditCollectionHandler._pointUnderTheMouse.editionFeatureParentGeometry;
				parentFeature=findVirtualVerticeParent(NewAbstractEditCollectionHandler._pointUnderTheMouse)
				parentgeom=editionFeatureParentGeometry(NewAbstractEditCollectionHandler._pointUnderTheMouse,parentFeature.geometry as ICollection);
				pointUnderTheMouse=true;
			}
			
			//The  Mouse button is down
			if(event.buttonDown){
				var point1:Point=null;
				var point2:Point=null;
				var point1Px:Pixel=null;
				var point2Px:Pixel=null;
				//We take 2 points in the collection depends on the index of the feature currently dragged
				if(indexOfFeatureCurrentlyDrag==0){
					if(pointUnderTheMouse){
						point1=parentgeom.componentByIndex(0) as Point;
						point2=parentgeom.componentByIndex(1) as Point;
					}
					else point1=parentgeom.componentByIndex(1) as Point;
				}
					
				else if(indexOfFeatureCurrentlyDrag==parentgeom.componentsLength-1){
					if(pointUnderTheMouse){
						point1=parentgeom.componentByIndex(indexOfFeatureCurrentlyDrag-1) as Point;
						point2=parentgeom.componentByIndex(indexOfFeatureCurrentlyDrag) as Point;
					}
					else point1=parentgeom.componentByIndex(parentgeom.componentsLength-2) as Point;	 	
				}	 	
				else{
					if(pointUnderTheMouse){
						point1=parentgeom.componentByIndex(indexOfFeatureCurrentlyDrag-1) as Point;
						point2=parentgeom.componentByIndex(indexOfFeatureCurrentlyDrag) as Point;
					}
					else{ point1=parentgeom.componentByIndex(indexOfFeatureCurrentlyDrag+1) as Point;
						point2=parentgeom.componentByIndex(indexOfFeatureCurrentlyDrag-1) as Point;
					}
				}
				if(point1!=null)point1Px=this.map.getMapPxFromLocation(new Location(point1.x,point1.y));
				
				//We draw the temporaries lines
				if(point2==null && point1!=null){
					_drawContainer.graphics.clear();
					_drawContainer.graphics.lineStyle(1, 0xFF00BB);	 		
					_drawContainer.graphics.moveTo(point1Px.x,point1Px.y);
					_drawContainer.graphics.lineTo(map.mouseX, map.mouseY);
					_drawContainer.graphics.endFill();
				}
				else if (point2!=null && point1!=null){
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
			else{
				_drawContainer.graphics.clear();
			}
		}
	}
}