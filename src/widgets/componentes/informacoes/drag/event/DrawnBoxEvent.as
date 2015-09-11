package widgets.componentes.informacoes.drag.event
{
	
	import flash.display.Sprite;
	
	import org.openscales.core.events.OpenScalesEvent;
	import org.openscales.geometry.basetypes.Bounds;
	
	public class DrawnBoxEvent extends OpenScalesEvent
	{
		
		private var _bounds:Bounds;
		private var _sprite:Sprite;
		
		/**
		 * Event type dispatched when the box is drawn.
		 */
		public static const DRAWN:String="openscales.boxdrawn";
		
		public function DrawnBoxEvent(type:String, bounds:Bounds, sprite:Sprite, bubbles:Boolean = false, cancelable:Boolean = false)
		{
			this._bounds = bounds;
			this._sprite = sprite;
			super(type, bubbles, cancelable);
		}
		
		public function get bounds():Bounds
		{
			return this._bounds;
		}
		
		public function set bounds(value:Bounds):void 
		{
			this._bounds = value;	
		}
		
		public function get sprite():Sprite
		{
			return this._sprite;
		}
		
		public function set sprite(value:Sprite):void 
		{
			this._sprite = value;	
		}
	}
}