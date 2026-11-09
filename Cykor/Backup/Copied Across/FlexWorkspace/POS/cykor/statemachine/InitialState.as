package cykor.statemachine
{
	import cykor.statemachine.State;
	import mx.core.Container;

	public class InitialState extends State
	{
		public function InitialState(config:XML,container:Container)
		{
			super(config,container);
		}
		public override function toString():String {
			return "Initial( "+super.toString()+")";
		}
 		protected override function setupCanvas(width:Number,height:Number):void {
 			if (stateName != "") {
 				super.setupCanvas(width,height);
 			} else {
				graphics.clear();
				graphics.beginFill(0x000000,1);
			    graphics.lineStyle(2, 0x000000, 1.0);
				graphics.drawCircle(width/2,height/2,width/8);
				graphics.endFill();
				title.x=0;
				title.y=height/5;
				title.width=width;
				title.height=(height/4);
				title.setStyle("textAlign","center");
 			}
		} 
	}
}