package widgets.componentes.wmsAuthKey
{
	import org.openscales.core.events.OpenScalesEvent;
	import org.openscales.core.layer.Layer;
	import org.openscales.core.layer.ogc.WMS;
	import org.openscales.core.ns.os_internal;
	import org.openscales.core.tile.ImageTile;
	import org.openscales.geometry.basetypes.Bounds;
	import org.openscales.geometry.basetypes.Pixel;
	import org.openscales.geometry.basetypes.Size;
	import org.openscales.proj4as.ProjProjection;
	import org.openscales.core.layer.ogc.provider.OGCTileProvider;
	import org.openscales.core.layer.ogc.provider.WMSTileProvider;
	
	import mx.controls.Alert;
	
	use namespace os_internal;
	
	/**
	 * The WMSTileProvider is the exclusive way of requesting a service.
	 * It contains the mandatory and optional parameters needed to construct the request.
	 * The request is automaticaly generated when necessary, based on the previously set parameters.
	 * 
	 * @author javocale
	 * 
	 */
	
	public class WMSAuthKeyTileProvider extends WMSTileProvider
	{	

		/**
		 * Constructor of the WMSAuthKeyTileProvider.
		 * 
		 * @param openscalesLayer Layer in openscales linked to this tileProvider.
		 * @param url URL of the server to request.
		 * @param version Version of the service requested.
		 * @param layer Layers to request on the server.
		 * @param projection Projection system used to request the service.
		 * @param style Styles of the requested layers.
		 * @param format Mime type used for the returned tiles.
		 * 
		 */
		public function WMSAuthKeyTileProvider(url:String,
										version:String,
										layer:String,
										projection:*,
										style:String = "",
										format:String = "image/jpeg")
		{
			//call the constructor of the mother class WMSTileProvider
			super(url, version, layer, projection, style, format);

		}
		
		/**
		 * Generate a request URL based on the parameters set in the tile provider
		 * 
		 * @param bounds bounds of the tile to set in the request string
		 */ 
		override os_internal function buildGETQuery(bounds:Bounds, params:Object):String
		{			
			var str:String;
			
			str = super.buildGETQuery(bounds, params);
			
			//authentication key parameter
			str += "&authkey=88203dcc-2ae8-48ff-99f5-d9eab0f43e7e";
			
			//Alert.show(str);
			//return str.substr(0, str.length-1);
			return str;
		}
	}
}