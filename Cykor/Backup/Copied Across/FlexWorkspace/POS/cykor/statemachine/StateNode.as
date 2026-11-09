package cykor.statemachine
{
	import mx.core.UIComponent;
	import flash.display.Sprite;
	import mx.containers.Canvas;
	import flash.events.MouseEvent;
	import mx.controls.Label;

	public class StateNode extends Canvas
	{
		protected var title:Label=new Label();
		public var stateName:String;
		public function StateNode(name:String)
		{
			buttonMode = true;
			cacheAsBitmap = true;
			stateName=name;
			super();
			addChild(title);
			title.text=stateName;
			addEventListener( MouseEvent.MOUSE_DOWN, doMouseDown );
			addEventListener( MouseEvent.MOUSE_UP, doMouseUp );
		}
		protected function setupCanvas(width:Number,height:Number):void {
			graphics.clear();
			graphics.beginFill(0xFFFFFF,1);
		    graphics.lineStyle(2, 0x000000, 1.0);
			graphics.drawRoundRect(0,0,width, height,width/5,height/5);
			graphics.moveTo(0,height/4);
			graphics.lineTo(width,height/4);
			graphics.endFill();
			title.x=2;
			title.y=2;
			title.width=width-4;
			title.height=(height/4)-4;
			title.setStyle("textAlign","center");
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