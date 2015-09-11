package widgets.componentes.printpreview.utils
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.geom.Matrix;
	import flash.net.FileReference;
	import flash.net.URLRequest;
	import flash.printing.PrintJob;
	import flash.printing.PrintJobOptions;
	import flash.system.Capabilities;
	import flash.utils.ByteArray;
	
	import mx.controls.Alert;
	import mx.core.*;
	import mx.graphics.ImageSnapshot;
	import mx.graphics.codec.JPEGEncoder;
	import mx.printing.*;
	
	import org.openscales.core.Map;
	
	

	public class BasicPrint extends Sprite
	{
		private var frame:Sprite = new Sprite();
		private var url:String = "image.jpg";
		private var loader:Loader = new Loader();
		private var map:Map
		
		public function BasicPrint(m:Map)
		{
			map=m;
			/*var bitmapData :BitmapData = new BitmapData(Application.application.stage.stageWidth, Application.application.stage.stageHeight);
			bitmapData .draw(Application.application.stage);			
			
			var bitmap : Bitmap = new Bitmap(bitmapData);
			var jpg:JPEGEncoder = new JPEGEncoder();
			var ba:ByteArray = jpg.encode(bitmapData);
			/*newImage = File.desktopDirectory.resolvePath("Images/" + "teste.text" + ".jpg");
			fileStream = new FileStream();
			fileStream.open(newImage, FileMode.UPDATE);
			fileStream.writeBytes(ba);*/
		}
		
		public function PrintScreen()
		{
			var bitmapData:BitmapData = new BitmapData(map.width, map.height);
			bitmapData.draw(map);
			
			var bitmap:Bitmap = new Bitmap(bitmapData);
			var jpg:JPEGEncoder = new JPEGEncoder();
			var ba:ByteArray = jpg.encode(bitmapData);
			
			var ref:FileReference = new FileReference();
			ref.save(ba);
		}
		
		public function doPrint(){
			
			var printJob:FlexPrintJob = new FlexPrintJob();
			
			if (printJob.start() != true) return; 
			
			Application.application.minHeight = 1600;
			Application.application.minWidth = 900;
			
			printJob.addObject(UIComponent(Application.application),  FlexPrintJobScaleType.MATCH_WIDTH);
			printJob.send();
		}
		
		private function completeHandler(event:Event):void {
			
			var picture:Bitmap = Bitmap(loader.content);
			var bitmap:BitmapData = picture.bitmapData;
			
			var matrix:Matrix = new Matrix();
			
			matrix.scale((200 / bitmap.width), (200 / bitmap.height));
			
			frame.graphics.lineStyle(10);
			frame.graphics.beginBitmapFill(bitmap, matrix, true);
			frame.graphics.drawRect(0, 0, 200, 200);
			frame.graphics.endFill();
			
			addChild(frame);
			
			printPage();    
		}
		
		private function ioErrorHandler(event:IOErrorEvent):void {
			trace("Unable to load the image: " + url);
		}
		
		private function printPage ():void {
			var myPrintJob:PrintJob = new PrintJob();
			var options:PrintJobOptions = new PrintJobOptions();
			options.printAsBitmap = true;
			
			myPrintJob.start();
			
			try {
				myPrintJob.addPage(frame, null, options);
			}
			catch(e:Error) {
				trace ("Had problem adding the page to print job: " + e);
			}
			
			try {
				myPrintJob.send();
			}
			catch (e:Error) {
				trace ("Had problem printing: " + e);    
			}
		}
	}
}