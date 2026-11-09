package cykor.statemachine
{
	import cykor.statemachine.State;
	import mx.core.Container;

	public class FinalState extends State
	{
		public function FinalState(config:XML,container:Container)
		{
			super(config,container);
		}
		public override function toString():String {
			return "Final( "+super.toString()+")";
		}
		protected override function setupCanvas(width:Number,height:Number):void {
			graphics.clear();
			graphics.beginFill(0xFFFFFF,1);
		    graphics.lineStyle(2, 0x000000, 1.0);
			graphics.drawCircle(width/2,height/2,width/6);
			graphics.endFill();
			graphics.beginFill(0x000000,1);
		    graphics.lineStyle(2, 0x000000, 1.0);
			graphics.drawCircle(width/2,height/2,width/8);
			graphics.endFill();
			title.x=0;
			title.y=height/6;
			title.width=width;
			title.height=(height/4);
			title.setStyle("textAlign","center");
		}
	}
}