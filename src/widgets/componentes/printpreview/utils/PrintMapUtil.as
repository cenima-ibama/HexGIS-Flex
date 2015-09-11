package widgets.componentes.printpreview.utils
{
	/* import com.esri.ags.Graphic;
	import com.esri.ags.Map;
	import com.esri.ags.geometry.Extent;
	import com.esri.ags.geometry.MapPoint; */
	
	import widgets.componentes.printpreview.utils.ModelLocator;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import org.openscales.core.Map;
	
	public class PrintMapUtil
	{	
		[Bindable] private var _model:ModelLocator=ModelLocator.getInstance();
		private var map:Map;
		
		public function PrintMapUtil()
		{
			//map = Map(ObjectUtil.copy(_model.map));
			_model.mapclone = map;
		}
		
		// Draw the maps print extent ractangle as a graphic on the map, based on
		// an image controls width and height
		/* 		public static function trimmedExtent(map:Map, containerWidth:Number, containerHeight:Number):Graphic
		{
		var rectangle:Rectangle = clipRectangle(map, containerWidth, containerHeight);
		var minMapPoint:MapPoint = map.toMap(new Point(rectangle.x,rectangle.y));
		var maxMapPoint:MapPoint = map.toMap(new Point(rectangle.x + rectangle.width,
		rectangle.y + rectangle.height));
		var extent:Extent = new Extent(minMapPoint.x,minMapPoint.y,maxMapPoint.x,maxMapPoint.y)
		
		return new Graphic(extent);
		} // end trimmedExtent */
		
		// Get the maps print extent image as a BitMap. Used for the source of an image control.
		// Image controls width and height are paramaters of this function.
		public function trimmedMap(bm:Bitmap, containerWidth:Number, containerHeight:Number):Bitmap
		{
			var rectangle:Rectangle = clipRectangle(bm, containerWidth, containerHeight);
			
			//get the map as bitmapdata so the part we want can be copied and clipped
			var myBitmapData:BitmapData = new BitmapData(_model.map.width, _model.map.height);
			myBitmapData.draw(bm,null,null,null,rectangle,true);
			
			// create a new cropped image to fit the map print area
			var newBitmapData:BitmapData = new BitmapData(rectangle.width, rectangle.height)
			newBitmapData.copyPixels(myBitmapData, rectangle, new Point(0, 0));
			
			return new Bitmap(newBitmapData);
		} // end trimmedMap
		
		// Get the print Extent Rectangle based on a container's width and height
		private function clipRectangle(bm:Bitmap, containerWidth:Number, containerHeight:Number ):Rectangle
		{
			// check if the container is portrait or Landscape
			var orientation:String="PORTRAIT";
			if (containerWidth > containerHeight)
			{
				orientation="LANDSCAPE";
			}
			
			var ratioWidth:Number;
			var ratioHeight:Number;
			var clipRect:Rectangle = new Rectangle();
			
			var ratio:Number;
			var mapRatio:Number;
			
			switch (orientation)
			{
				case "PORTRAIT":
				{
					ratio = containerWidth / containerHeight;
					mapRatio = _model.map.width / _model.map.height;
					//check the maps width and height to get the cropped size
					//if (map.width > map.height)
					if (mapRatio > ratio)
					{
						ratioHeight = _model.map.height;
						ratioWidth = _model.map.height * ratio;
						//centre the clip rectangle
						clipRect.x = (_model.map.width - ratioWidth) / 2;
						clipRect.y = 0;
					}
					else
					{
						ratioWidth = _model.map.width;
						ratioHeight = _model.map.width / ratio ;
						clipRect.x = 0;
						clipRect.y = (_model.map.height - ratioHeight) / 2;
					} 
					break;
				}
				case "LANDSCAPE":
				{
					ratio = containerHeight / containerWidth;
					mapRatio = _model.map.height / _model.map.width;
					//check the maps width and height to get the ratio
					if (mapRatio < ratio)
					{
						ratioHeight = _model.map.height;
						ratioWidth = _model.map.height / ratio;
						//centre the clip rectangle
						clipRect.x = (_model.map.width - ratioWidth) / 2;
						clipRect.y = 0;
					}
					else
					{
						ratioWidth = _model.map.width;
						ratioHeight = _model.map.width * ratio;
						clipRect.x = 0;
						clipRect.y = (_model.map.height - ratioHeight) / 2;
					} 
					break;
				}
			}
			clipRect.width=ratioWidth;
			clipRect.height=ratioHeight;
			
			return clipRect;
		} // end clipRectangle
	} // end class PrintMapUtil
	
} // end package