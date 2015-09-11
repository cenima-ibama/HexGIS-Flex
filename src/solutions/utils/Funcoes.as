package solutions.utils
{
  	public class Funcoes
  	{
	
		import mx.formatters.CurrencyFormatter;

		public static function FormatarDinheiro(valor:String):String
		{
			var currencyFormatter:CurrencyFormatter = new CurrencyFormatter();
			with (currencyFormatter)
				{
				precision = 2;
				currencySymbol = "R$ ";
				useNegativeSign = true;
				useThousandsSeparator = true;
				alignSymbol = "left";
				}
				return currencyFormatter.format(valor)	
		}
		//--------------------------------------------------------------------
		public static function dmy(data:String):String
		{
			if( !data )
			{
				return '';
			}
			data = data.replace('12:00:00 AM','');
			var separador:String = '/';
			var aData:Array;
			if( data.indexOf('/') > -1 )
			{
				separador='/';
			}
			else if( data.indexOf('-') > -1 )
			{
				separador='-';
			}
			else
			{
				return data;
			}
			aData = data.split(separador);
			return aData[1]+'/'+aData[0]+'/'+aData[2];
		}
		//-----------------------------------------------------------------
		public static function ymd2dmy(data:String):String
		{
			if( !data )
			{
				return '';
			}
			var ano:String = data.substr(0,4); 
			var mes:String = data.substr(4,2); 
			var dia:String = data.substr(6,2); 
			return dia+'/'+mes+'/'+ano;
		}
		//--------------------------------------------------------------------
		public static function dataHoraCorrenteExtenso():String
		{
			var aDiaSemana:Array = ['domingo','segunda-feira','terça-feira','quarta-feira','quinta-feira','sexta-feira','sábado'];
			var aMes:Array = ['janeiro','fevereiro','março','abril','maio','junho','julho','agosto','setembro','outubro','novembro','dezembro'];
            var agora:Date = new Date();
			var ds:int 	= agora.getDay(); // 0 a 7
			var d:int 	= agora.getDate(); //1 a 31
			var mes:int 	= agora.getMonth(); // 0 a 11
			var ano:int = agora.fullYear;
			var h:int 	= agora.hours;
			var min:int	= agora.minutes;
			var s:int 	= agora.seconds;
			return aDiaSemana[ds]+', '+d.toString()+' de '+aMes[mes]+' de '+ano.toString()+' as '+h.toString()+':'+min.toString()+':'+s.toString();
		}
		//--------------------------------------------------------------------
		public static function horaAtual():String
		{
            var agora:Date = new Date();
			var h:int 	= agora.hours;
			var min:int	= agora.minutes;
			var s:int 	= agora.seconds;
		return ((h<10)?'0':'')+h.toString()+':'+((min<10)?'0':'')+min.toString()+':'+((s<10)?'0':'')+s.toString();
		}
	}
}