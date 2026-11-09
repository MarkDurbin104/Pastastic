package cykor.mail
{
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.events.Event;
	import mx.utils.StringUtil;
	import mx.containers.Canvas;
	import mx.controls.Label;
	import mx.controls.TextArea;
	import flash.events.MouseEvent;
	import mx.controls.DataGrid;
	import mx.collections.ArrayCollection;

	public class LookUp extends Canvas
	{
		private var _title:Label=new Label;
		private var lookupData:ArrayCollection;
		private var dg:DataGrid=new DataGrid;
		
		public function get title():String {
			return _title.text;
		}
		public function set title(value:String):void {
			_title.text=value;
		}
		
		public function LookUp(URL:String)
		{
			super();
			title=URL;
			addChild(_title);
			addChild(dg);
			var smLoader:URLLoader = new URLLoader(); 
			smLoader.addEventListener(Event.COMPLETE,lookupLoaded);
			smLoader.load(new URLRequest(URL));
			addEventListener( MouseEvent.MOUSE_DOWN, doMouseDown );
			addEventListener( MouseEvent.MOUSE_UP, doMouseUp );
		}
		private function lookupLoaded(e:Event):void{
			var q:String=e.target.data;
			var params:Array = StringUtil.trim(q).split("\r\n");
			for (var i:int=0;i <params.length;i++) {
				params[i]=params[i].split(",");
				trace (params[i][0]+'*'+params[i][1]);
			}
			lookupData=new ArrayCollection(params.slice(1));
			dg.dataProvider=lookupData;
			for (i=0;i<params[0].length;i++) {
				dg.columns[i].headerText=params[0][i];
			}
			x=100;
			y=300;
			height=23*params.length+25;
			width=200;
		}
		protected function setupCanvas(width:Number,height:Number):void {
			graphics.clear();
			graphics.beginFill(0xFFFFFF,1);
		    graphics.lineStyle(2, 0x000000, 1.0);
			graphics.drawRoundRect(0,0,width, height,10,10);
			graphics.moveTo(0,25);
			graphics.lineTo(width,25);
			graphics.endFill();
			_title.x=2;
			_title.y=2;
			_title.width=width-4;
			_title.height=21;
			_title.setStyle("textAlign","center");
			dg.x=1;
			dg.y=26;
			dg.width=width-2
			dg.height=height-30;
			dg.setStyle("borderStyle","none");
			dg.setStyle("verticalScrollPolicy","off");
			dg.setStyle("horizontalScrollPolicy","off");
		}
		protected override function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void {
			setupCanvas(unscaledWidth,unscaledHeight);
		}
		public function doMouseDown( event:MouseEvent ):void {
			startDrag();
		}
		public function doMouseUp( event:MouseEvent ):void {
			stopDrag();
		}			
	}
}