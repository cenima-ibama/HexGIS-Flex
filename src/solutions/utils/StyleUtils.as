package solutions.utils
{
	import org.openscales.core.style.Rule;
	import org.openscales.core.style.Style;
	import org.openscales.core.style.fill.SolidFill;
	import org.openscales.core.style.stroke.Stroke;
	import org.openscales.core.style.marker.WellKnownMarker;
	import org.openscales.core.style.symbolizer.LineSymbolizer;
	import org.openscales.core.style.symbolizer.PointSymbolizer;
	import org.openscales.core.style.symbolizer.PolygonSymbolizer;

	public class StyleUtils
	{
		public function StyleUtils()
		{
		}
		
		public static function getDefaultPointStyle():Style
		{
			var fill:SolidFill = new SolidFill(0x0033cc, 0.5);
			var stroke:Stroke = new Stroke(0x032ea9, 3.0, 0.5, "round");
			
			var mark:WellKnownMarker = new WellKnownMarker(WellKnownMarker.WKN_CIRCLE, fill, stroke, 7.0, 1);
			
			var rule:Rule = new Rule();
			rule.symbolizers.push(new PointSymbolizer(mark));
			
			var style:Style = new Style();
			style.name = "New point style";
			style.rules.push(rule);
			
			return style;
		}
		
		public static function getOthersPointStyle():Style
		{
			var fill:SolidFill = new SolidFill(0x939393, 0.8);
			var stroke:Stroke = new Stroke(0xc2c3c3, 1.0, 1.0, "round");
			var mark:WellKnownMarker = new WellKnownMarker(WellKnownMarker.WKN_CIRCLE, fill, stroke, 8.0, 1);
			
			var rule:Rule = new Rule();
			rule.symbolizers.push(new PointSymbolizer(mark));
			
			var style:Style = new Style();
			style.name = "New point style";
			style.rules.push(rule);
			
			return style;
		}
		
		public static function getSelectedPointStyle():Style
		{
			var fill:SolidFill = new SolidFill(0x78f09f, 1.0);
			var stroke:Stroke = new Stroke(0x1fb551, 2.0, 0.75, "round");
			var mark:WellKnownMarker = new WellKnownMarker(WellKnownMarker.WKN_CIRCLE, fill, stroke, 7.0, 1);
			
			var rule:Rule = new Rule();
			rule.symbolizers.push(new PointSymbolizer(mark));
			
			var style:Style = new Style();
			style.name = "New point style";
			style.rules.push(rule);
			
			return style;
		}

		public static function getGridPointStyle():Style
		{
			var fill:SolidFill = new SolidFill(0xfcff00, 0.8);
			var stroke:Stroke = new Stroke(0xe2fc07, 13.0, 0.3, "round");
			var mark:WellKnownMarker = new WellKnownMarker("circle", fill, stroke, 6.0, 1);
			
			var rule:Rule = new Rule();
			rule.symbolizers.push(new PointSymbolizer(mark));
			
			var style:Style = new Style();
			style.name = "New point style";
			style.rules.push(rule);
			
			return style;
		}
		
		public static function getDefaultLineStyle():Style
		{			
			var stroke:Stroke = new Stroke(0x0033cc, 3.0, 0.5, "round");
			
			var rule:Rule = new Rule();
			rule.symbolizers.push(new LineSymbolizer(stroke));
			//rule.symbolizers.push(new LineSymbolizer(new Stroke(0x40A6D9, 1)));
			
			var style:Style = new Style();
			style.name = "New line style";
			style.rules.push(rule);
			
			return style;
		}
		
		public static function getOthersLineStyle():Style
		{
			var stroke:Stroke = new Stroke(0x939393, 3.0, 0.75, "round");
			var rule:Rule = new Rule();
			rule.symbolizers.push(new LineSymbolizer(stroke));
			//rule.symbolizers.push(new LineSymbolizer(new Stroke(0x40A6D9, 1)));
			
			var style:Style = new Style();
			style.name = "New line style";
			style.rules.push(rule);
			
			return style;
		}
		
		public static function getSelectedLineStyle():Style
		{
			var stroke:Stroke = new Stroke(0x78f09f, 2.0, 0.75, "round");
			
			var rule:Rule = new Rule();
			rule.symbolizers.push(new LineSymbolizer(stroke));
			//rule.symbolizers.push(new LineSymbolizer(new Stroke(0x40A6D9, 1)));
			
			var style:Style = new Style();
			style.name = "New line style";
			style.rules.push(rule);
			
			return style;
		}
		
		public static function getDefaultPolygonStyle():Style
		{
			var fill:SolidFill = new SolidFill(0x0033cc, 0.5);
			var stroke:Stroke = new Stroke(0x032ea9, 3.0, 0.5, "round");
			
			var ps:PolygonSymbolizer = new PolygonSymbolizer(fill, stroke);
			
			var rule:Rule = new Rule();
			rule.symbolizers.push(ps);
			
			var style:Style = new Style();
			style.rules.push(rule);
			style.name = "New polygon style";
			
			return style;
		}
		
		public static function getOthersPolygonStyle():Style
		{
			var fill:SolidFill = new SolidFill(0x939393, 0.8);
			var stroke:Stroke = new Stroke(0xc2c3c3, 1.0, 1.0, "round");
			
			var ps:PolygonSymbolizer = new PolygonSymbolizer(fill, stroke);
			
			var rule:Rule = new Rule();
			rule.symbolizers.push(ps);
			
			var style:Style = new Style();
			style.rules.push(rule);
			style.name = "New polygon style";
			
			return style;
		}
		
		public static function getSelectedPolygonStyle():Style
		{
			var fill:SolidFill = new SolidFill(0x78f09f, 0.5);
			var stroke:Stroke = new Stroke(0x1fb551, 1.0, 0.75, "round");
			
			var ps:PolygonSymbolizer = new PolygonSymbolizer(fill, stroke);
			
			var rule:Rule = new Rule();
			rule.symbolizers.push(ps);
			
			var style:Style = new Style();
			style.rules.push(rule);
			style.name = "New polygon style";
			
			return style;
		}
		
	}
}