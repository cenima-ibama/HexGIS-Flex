package widgets.componentes.wmsAuthKey
{
	
	import org.openscales.core.layer.Grid;
	import org.openscales.core.layer.ogc.WMS;
	import org.openscales.core.layer.ogc.provider.WMSTileProvider;
	import org.openscales.core.layer.params.ogc.WMSParams;
	import org.openscales.core.tile.ImageTile;
	import org.openscales.core.tile.Tile;
	import org.openscales.geometry.basetypes.Bounds;
	import org.openscales.geometry.basetypes.Location;
	import org.openscales.geometry.basetypes.Pixel;
	import org.openscales.geometry.basetypes.Size;
	
	import mx.controls.Alert;
	
	
	/**
	 * Instances of WMS are used to display data from OGC Web Mapping Services.
	 *
	 * @author Bouiaw
	 */	
	public class WMSAuthKey extends WMS
	{
		
		/**
		 * @private
		 * The tile provider allows users to generate requests to the server and get the requested tiles
		 */
		private var _tileProvider:WMSAuthKeyTileProvider=null;
		
		/**
		 * Constructor of the class
		 * 
		 * @param name Name of the layers to display
		 * @param url URL of the service to request
		 * @param styles Styles of the layers to display
		 * 
		 */
		public function WMSAuthKey(identifier:String = "",
							url:String = "",
							layers:String = "",
							styles:String = "",
							format:String = "image/png"){
			
			super(identifier);
			// Properties initialization
			this._layerName = name;
			super.url = url;
			this._layers = layers;
			this._styles = styles;
			this._format = format;
			// In WMS we must be in single tile mode
			this.tiled = false;
			// Call the tile provider to generate the request and get the tile requested
			this._tileProvider = new WMSAuthKeyTileProvider(url, this._version, layers, this.projection, styles, format);
		}
		
		/**
		 * Override method used to update the wms tile displayed when using the zoom control
		 * 
		 */
		override public function redraw(fullRedraw:Boolean = false):void {
			if (this.map == null)
				return;
			(_tileProvider as WMSAuthKeyTileProvider).width = this.tileWidth;
			(_tileProvider as WMSAuthKeyTileProvider).height = this.tileHeight;
			super.redraw(fullRedraw);
		}
	}
}

