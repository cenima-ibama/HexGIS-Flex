package solutions.utils
{
	import mx.charts.chartClasses.Series;
	import mx.charts.series.AreaSeries;
	import mx.charts.series.BarSeries;
	import mx.charts.series.ColumnSeries;
	import mx.charts.series.LineSeries;
	import mx.charts.series.PieSeries;
	import mx.controls.Alert;
	import mx.graphics.GradientEntry;
	import mx.graphics.LinearGradient;
	import mx.graphics.SolidColorStroke;
	
	public class ChartUtils
	{
		public function ChartUtils()
		{
		}
		
		/* var red:uint = 0xfe3f3f;
		var yellow:uint = 0xfefe3f;
		var green:uint = 0x3ffe3f;
		var indigo:uint = 0x3ffefe;
		var blue:uint = 0x3f3ffe;
		var violet:uint = 0xfe3ffe;
		var white:uint = 0xffffff;;
		var black:uint = 0x000000;; */
		
		
		public static function SetColBarLinAreChartSeriesFills(chartSeries:Array, tipo:String):void
		{		
			const nIntervalos:uint = 7;
			
			var series:Series;
			var nSeries:int = chartSeries.length;
			
			var i:uint;
			var j:uint;
			
			var incr:uint;
			
			var red:uint = 0xcc0000;
			var yellow:uint = 0xcccc00;
			var green:uint = 0x00cc00;
			var indigo:uint = 0x00cccc;
			var blue:uint = 0x0000cc;
			var violet:uint = 0xcc00cc;
			var white:uint = 0xffffff;;
			var black:uint = 0x000000;;
			
			var initialColorAr:Array = [red, yellow, green, indigo, blue, violet, white, black];
			
			var _fillAlpha:Number = 0.65;
			//var fillAlphaGradient:Number = fillAlpha + 0.15;

			var _fill:LinearGradient;
			var _ge:GradientEntry;
			//var ge2:GradientEntry;
			var _stroke:SolidColorStroke;
						
			var resto:uint = nSeries%nIntervalos;
			var nIteracoes:uint = nSeries/nIntervalos;
			var iteracoes:Array = new Array();	
			
			var sinal:int = 1;
			var meio:int;
			var meio_aux:int;
			var indice:uint = 0;
			
			
			for (i=0; i<nIntervalos; i++)
			{
				iteracoes.push(nIteracoes);
			}
			
			if (nIntervalos%2 == 0)
			{
				meio_aux = (nIntervalos/2)-1;
			}
			else
			{
				meio_aux = (nIntervalos/2);
			}
			
			meio = meio_aux;
			
			
			for (i=0; i<resto; i++)
			{
				indice = meio_aux+(sinal*i);
				
				if ((indice > -1) && (indice < nIntervalos))
				{
					iteracoes[indice]++;
				}
				
				sinal = sinal*(-1);
				
				meio_aux -= sinal*i;
			} 

			var k:uint = 0;
			
			for (i=0; i<iteracoes.length; i++)
			{
				if (initialColorAr[i+1] > initialColorAr[i])
				{
					incr = (initialColorAr[i+1] - initialColorAr[i]);
				}
				else
				{
					incr = (initialColorAr[i] - initialColorAr[i+1]);
				} 
				incr = incr/(iteracoes[i] + 1);
				
				for (j = 0; j < iteracoes[i]; j++)
				{
					series = chartSeries[k];
					k++;
					
					_fill = new LinearGradient();
					_ge = new GradientEntry(initialColorAr[i], 0.0, _fillAlpha);
					//ge2 = new GradientEntry(initialColorAr[i] - 0x001c1c, 0.95, fillAlphaGradient);
					_fill.entries = [_ge];
						
					/*
					*
					*/
					if ((tipo == "Colunas") || (tipo == "Barras"))
					{
						series.setStyle("fill", _fill);
					}
					else if (tipo == "Linhas")
					{
						_stroke = new SolidColorStroke(initialColorAr[i], 3.0, 0.7);

						series.setStyle("lineStroke", _stroke);
						//Alert.show(_stroke.color.toString());
					}
					else if (tipo == "Áreas")
					{
						_stroke = new SolidColorStroke(initialColorAr[i], 1.0, 0.8);
						
						series.setStyle("areaStroke", _stroke);
						series.setStyle("areaFill", _fill);
					}
					
					/*
					*
					*/
					if (initialColorAr[i+1] > initialColorAr[i])
					{
						initialColorAr[i] += incr;
					}
					else
					{
						initialColorAr[i] -= incr;
					}
				}
			}
		}
		
		
		public static function SetPieChartSeriesFills(chartSeries:Array, nDados:int):void
		{		
			const nIntervalos:uint = 7;
			
			var series:Series;
			
			var i:uint;
			var j:uint;
			
			var incr:uint;
			
			var red:uint = 0xcc0000;
			var yellow:uint = 0xcccc00;
			var green:uint = 0x00cc00;
			var indigo:uint = 0x00cccc;
			var blue:uint = 0x0000cc;
			var violet:uint = 0xcc00cc;
			var white:uint = 0xffffff;;
			var black:uint = 0x000000;;
			
			var initialColorAr:Array = [red, yellow, green, indigo, blue, violet, white, black];
			
			var _fillAlpha:Number = 0.65;
			//var fillAlphaGradient:Number = fillAlpha + 0.15;
			
			var _fill:LinearGradient;
			var _ge:GradientEntry;
			//var ge2:GradientEntry;
			var _stroke:SolidColorStroke;
						
			var resto:uint = nDados%nIntervalos;
			var nIteracoes:uint = nDados/nIntervalos;
			var iteracoes:Array = new Array();	
			
			var sinal:int = 1;
			var meio:int;
			var meio_aux:int;
			var indice:uint = 0;
			
			var _fills:Array;
			
			
			for (i=0; i<nIntervalos; i++)
			{
				iteracoes.push(nIteracoes);
			}
			
			if (nIntervalos%2 == 0)
			{
				meio_aux = (nIntervalos/2)-1;
			}
			else
			{
				meio_aux = (nIntervalos/2);
			}
			
			meio = meio_aux;
			
			
			for (i=0; i<resto; i++)
			{
				indice = meio_aux+(sinal*i);
				
				if ((indice > -1) && (indice < nIntervalos))
				{
					iteracoes[indice]++;
				}
				
				sinal = sinal*(-1);
				
				meio_aux -= sinal*i;
			} 

			series = chartSeries[0];
						
			_fills = new Array();
			
			for (i=0; i<iteracoes.length; i++)
			{
				if (initialColorAr[i+1] > initialColorAr[i])
				{
					incr = (initialColorAr[i+1] - initialColorAr[i]);
				}
				else
				{
					incr = (initialColorAr[i] - initialColorAr[i+1]);
				} 
				incr = incr/(iteracoes[i] + 1);
				
				for (j = 0; j < iteracoes[i]; j++)
				{					
					_fill = new LinearGradient();
					_ge = new GradientEntry(initialColorAr[i], 0.0, _fillAlpha);
					//ge2 = new GradientEntry(initialColorAr[i] - 0x001c1c, 0.95, fillAlphaGradient);
					_fill.entries = [_ge];
					
					_fills.push(_fill);
			
					/*
					*
					*/
					if (initialColorAr[i+1] > initialColorAr[i])
					{
						initialColorAr[i] += incr;
					}
					else
					{
						initialColorAr[i] -= incr;
					}
				}
				
				series.setStyle("fills", _fills);	
			}
		}
		
		public static function SetBubChartSeriesFills(chartSeries:Array):void
		{		
			var series:Series;

			var blue:uint = 0x0000cc;
			
			var _fill:LinearGradient;
			var _ge:GradientEntry;
			var _stroke:SolidColorStroke;
		
			
			_fill = new LinearGradient();
			_ge = new GradientEntry(blue, 0.0, 0.5);
			_fill.entries = [_ge];
			
			_stroke = new SolidColorStroke(blue, 1.0, 0.8);
				
			series = chartSeries[0];
			series.setStyle("stroke", _stroke);
			series.setStyle("fill", _fill);
					
		}
	}
}