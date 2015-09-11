package widgets.componentes.ibama.layer
{
	import com.adobe.serialization.json.JSON;
	
	import flash.events.Event;
	import flash.net.URLLoader;
	
	import mx.controls.Alert;
	
	import org.openscales.core.basetypes.Resolution;
	import org.openscales.core.events.LayerEvent;
	import org.openscales.core.layer.TMS;
	import org.openscales.core.layer.originator.DataOriginator;
	import org.openscales.core.request.XMLRequest;
	import org.openscales.core.utils.Trace;
	import org.openscales.geometry.basetypes.Bounds;
	import org.openscales.geometry.basetypes.Location;
	import org.openscales.proj4as.ProjProjection;
	
	/**
	 * This class is used to display BingMaps.
	 */ 
	public class RapidEyeTMS extends TMS
	{
		private var _z:int;
		
		
		public static const resolutions:Array = new Array(
			156543.03390625,
			78271.516953125,
			39135.7584765625,
			19567.87923828125,
			9783.939619140625,
			4891.9698095703125,
			2445.9849047851562,
			1222.9924523925781,
			611.4962261962891,
			305.74811309814453,
			152.87405654907226,
			76.43702827453613,
			38.218514137268066,
			19.109257068634033,
			9.554628534317017,
			4.777314267158508,
			2.388657133579254,
			1.194328566789627,
			0.5971642833948135,
			0.29858214169740677,
			0.14929107084870338,
			0.07464553542435169
		);
		
		/**
		 * @private
		 * Metadata for this layer, as returned by the callback script
		 */
		private var _metadata:Object = null;
		
		/**
		 * @private
		 * the xmlrequest used in the layer. It prevents simultaneous requests.
		 */ 
		protected var _request:XMLRequest = null;
		
		public function RapidEyeTMS (identifier:String, url:String, layerName:String="")
		{
			super(identifier, url, "");
			this.layerName = layerName;
			
			this.altUrls = [];
						
			this.format = "png";
			this.projection = "EPSG:900913";
			this.maxExtent = new Bounds(-20037508,-20037508,20037508,20037508.34, this.projection);
		}
		
		
		override public function getURL(bounds:Bounds):String 
		{
			const desvio:Number = 1.4375;
			var d:Number;
			var url:String;
						
			var res:Resolution = this.getSupportedResolution(this.map.resolution);

			this._tileOrigin = new Location(this.map.maxExtent.left, this.map.maxExtent.bottom, this.map.projection);

			var x:Number = Math.round((bounds.left - this.maxExtent.left) / (res.value * this.tileWidth));
			var y:Number = Math.round((bounds.bottom - this._tileOrigin.lat) / (res.value * this.tileHeight));
			
			var z:Number = this.getZoomForResolution(res.reprojectTo(this.projection).value);
			
			var limit:Number = Math.pow(2, z);
			
			if (z > 4)
			{
				d = (desvio * Math.pow(2,(z-4)));
				y = y-d;
				y = Math.round(y);
				//y = y-1;
			}
			
			//url = this.url + "/" + z + "/" + x + "/" + y+"."+this.format;
			
			if ((z < 8) || (y < 0) || (y >= limit) || (x < 0 )|| (x >= limit))
			{
				url = "http://www.maptiler.org/img/none.png";
			}
			else
			{
				url = this.url + "/" + z + "/" + x + "/" + y+"."+this.format;
			}	


			return url;
		}

	}
}