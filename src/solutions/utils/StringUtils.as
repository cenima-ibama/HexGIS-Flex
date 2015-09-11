package solutions.utils
{
	import mx.controls.Alert;

	public class StringUtils
	{
		public static function reverseString(value:String):String 
		{
			var tmpString:String = "";
			var len:uint = value.length;
			while(len>0)
			{
				tmpString += value.substr(len-1, 1);
				len--;
			}
			return tmpString;
		}
		
		public static function capitalizeString(value:String):String
		{		
			value = value.toLowerCase();
									
			return (value.charAt(0).toUpperCase()+value.substr(1, value.length));
		}
	}
}