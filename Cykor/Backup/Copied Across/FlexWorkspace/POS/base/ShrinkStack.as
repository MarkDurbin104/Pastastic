package base
{
	import mx.containers.ViewStack;
	import mx.core.Container;
	import mx.events.EffectEvent;
	import mx.effects.*;
	import mx.effects.Fade
    import mx.core.IUIComponent;
    import mx.containers.Canvas;
    import base.ImageSnapshot;
    import mx.controls.Image;
    import mx.events.FlexEvent;
    import mx.events.ResizeEvent;
    import flash.display.IBitmapDrawable;
    import flash.display.Bitmap;
    import flash.geom.Matrix;
    import mx.containers.HBox;
    import flash.display.DisplayObjectContainer;
    import flash.display.BitmapData;
    import mx.core.Application;
    

	public class ShrinkStack extends ViewStack
	{
		public var shrinkBar:HBox=null;
        private var newWidth:Number;
        private var newHeight:Number;
		private var parallel:Parallel=new Parallel();
	    private var mover:Move=new Move();
	    private var zoom:Zoom=new Zoom();
	    private var fade:Fade= new Fade();
	    private var firstPutAway:Boolean=true;
        
		public function ShrinkStack()
		{
			super();
		}

		private function putScreenAway(target:Container,toX:int,toY:int):void 
		{
			if (firstPutAway) {
		        fade.alphaFrom=1;
		        fade.alphaTo=0.4;

				mover.yFrom=0;
				mover.xFrom=0;

				zoom.originX=0;
				zoom.originY=0;
				zoom.zoomWidthFrom=1;
				zoom.zoomHeightFrom=1;

		        parallel.addChild(mover);
		        parallel.addChild(zoom);
		        parallel.addChild(fade);

				parallel.suspendBackgroundProcessing=true;
				parallel.duration=250;
				
		        firstPutAway=false;
			}
	        
	
			zoom.zoomWidthTo=newWidth/target.width;
			zoom.zoomHeightTo=newHeight/target.height;
			
			mover.yTo=toY;
			mover.xTo=toX; 

			parallel.target=target;

			parallel.play();
			parallel.addEventListener(EffectEvent.EFFECT_END,putAwayDone);
		}
		private function putAwayDone(event:EffectEvent):void {
			var ph:Container=Container(event.target.target);
			var img:Image=Image(ph.removeChildAt(0));
			var canv:Canvas=new Canvas();
			ph.visible=false;
			parent.removeChild(ph);
			ph=null;
			img.width=newWidth;	
	       	img.height=newHeight;			
            canv.addChild(img); 
            canv.verticalScrollPolicy="off";
            canv.horizontalScrollPolicy="off";
            img.alpha=1;
            canv.setStyle("backgroundColor","#ECF5E7");
            canv.setStyle("borderStyle","solid");
            canv.setStyle("borderColor","#FFFFFF");
            canv.setStyle("borderThickness","1");
            canv.setStyle("cornerRadius","5");
            shrinkBar.addChild(canv);
		}
        private function takeSnapshot(source:DisplayObjectContainer):Image {
			var img:Image = new Image();
			img.source=new Bitmap(ImageSnapshot.captureBitmapData(source,null,null,null,null,true),"always",true);
            return(img);
        }
		private function gotoScreen(gotoPage:int,toX:Number,toY:Number):void {
			// cover screen with picture of screen
			if (shrinkBar == null) return;
			var pictureHolder:Canvas=new Canvas();
			parent.addChild(pictureHolder);
			var screenShot:Image =takeSnapshot(parent);
			pictureHolder.addChild(screenShot);
			pictureHolder.x=0;
			pictureHolder.y=0;
			pictureHolder.width=screenShot.contentWidth;
			pictureHolder.height=screenShot.contentHeight;
			pictureHolder.alpha=1;
 			pictureHolder.visible=true;
 			// draw underlying screen
             selectedIndex=gotoPage; 
             // play animation
             putScreenAway(pictureHolder,toX,toY);
		}
		public function selectPage(pageNumber:int):void {
			if ((shrinkBar == null) || (pageNumber == selectedIndex)) return;
	        parallel.end();
			newHeight=shrinkBar.height-26;
			newWidth=(newHeight/3)*4;
			var gap:int=shrinkBar.getStyle("horizontalGap");
			var nc:int=shrinkBar.rawChildren.numChildren;
			gotoScreen(pageNumber,shrinkBar.x+(nc-1)*(newWidth+gap)+12+gap,shrinkBar.y+1);
		}
		public function nextScreen():void {
			selectPage((selectedIndex+1)%4);
		}
		
	}
}