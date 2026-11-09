package base
{
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import mx.events.FlexEvent;
	import mx.collections.ArrayCollection;
	import flash.ui.ContextMenu;
	import flash.ui.ContextMenuItem;
	import flash.ui.ContextMenuBuiltInItems;
	import flash.events.ContextMenuEvent;
	import mx.rpc.AbstractInvoker;
	import mx.core.UIComponent;
	import mx.containers.Canvas;
	import flash.events.TimerEvent;
    import flash.utils.Timer;

	public class Clock extends UIComponent
	{
		private var timer:Timer = new Timer(10,0);

		public function Clock() {
			super();
			addEventListener(MouseEvent.MOUSE_DOWN, doMouseDown );
			addEventListener(MouseEvent.MOUSE_UP, doMouseUp );
			addEventListener(FlexEvent.CREATION_COMPLETE,createComplete);
		}
		public function createComplete(event:FlexEvent):void
		{
			timer.addEventListener(TimerEvent.TIMER,tick);
			timer.start();
		}
		public function tick(event:TimerEvent):void
		{
			var d:Date = new Date();
			drawFace(d.hours,d.minutes,d.seconds);
		}
		public function drawFace(hours:Number,minutes:Number,seconds:Number):void
		{
			var centreX:Number =width/2;
			var centreY:Number =height/2;
			var tickOuterRadius:Number = (width/40)*19;
			var tickInnerRadius:Number = (width/40)*18;
			var qtickInnerRadius:Number = (width/40)*16;
			var minuteHandRadius:Number = (width/40)*14;
			var hourHandRadius:Number = (width/40)*10;
			with (graphics) {
			 	clear();
// 				beginFill(0xFFFFFF,1);
//				drawCircle(width/2,height/2,width/2);
/* 				for (i=0;i<360;i+=30) {
					if ((i %90) == 0) {
					 	lineStyle(2,0x000000);
						moveTo(centreX+qtickInnerRadius*Math.sin(i*(Math.PI/180)),centreY+qtickInnerRadius*Math.cos(i*(Math.PI/180)));
					} else {
					 	lineStyle(1,0x000000);
						moveTo(centreX+tickInnerRadius*Math.sin(i*(Math.PI/180)),centreY+tickInnerRadius*Math.cos(i*(Math.PI/180)));
					}
					lineTo(centreX+tickOuterRadius*Math.sin(i*(Math.PI/180)),centreY+tickOuterRadius*Math.cos(i*(Math.PI/180)));
				}
 */
	 			var hourRadians:Number = (180-((hours*30)+(minutes/2)))*(Math.PI/180);
				var minuteRadians:Number = (180-(minutes*6))*(Math.PI/180);
				var secondRadians:Number = (180-(seconds*6))*(Math.PI/180);
			 	lineStyle(5,0xFFFFFF);
				moveTo(centreX,centreY);
				lineTo(centreX+hourHandRadius*Math.sin(hourRadians),centreY+hourHandRadius*Math.cos(hourRadians));
			 	lineStyle(3,0xFFFFFF);
				moveTo(centreX,centreY);
				lineTo(centreX+minuteHandRadius*Math.sin(minuteRadians),centreY+minuteHandRadius*Math.cos(minuteRadians));
			 	lineStyle(2,0xFF0000);
				moveTo(centreX,centreY);
				lineTo(centreX+minuteHandRadius*Math.sin(secondRadians),centreY+minuteHandRadius*Math.cos(secondRadians));
				
// 				endFill();
			}
		}
		public function doMouseDown( event:MouseEvent ):void {
			startDrag();
		}
		
		public function doMouseUp( event:MouseEvent ):void {
			stopDrag();
		}		
	
	}
}