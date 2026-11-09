package com.proiam.base
{
	import com.cykorsystems.utils.UIUtils;
	
	import flash.display.DisplayObjectContainer;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import mx.containers.Canvas;
	import mx.containers.HBox;
	import mx.containers.ViewStack;
	import mx.controls.Image;
	import mx.core.Container;
	import mx.effects.*;
	import mx.effects.easing.Exponential;
	import mx.events.EffectEvent;
	import mx.managers.PopUpManager;
    

    [Event(name="PoppedItem", type="flash.events.Event")]
	public class ShrinkStack extends ViewStack
	{
		public var shrinkBar:HBox=null;
		public var zoomSpeed:int=750;
		private var stackItems:Array=new Array();
        private var newWidth:Number;
        private var newHeight:Number;
		private var parallel:Parallel=new Parallel();
	    private var mover:Move=new Move();
	    private var zoom:Zoom=new Zoom();
	    private var fade:Fade= new Fade();
	    private var firstPutAway:Boolean=true;
	    private var previousPage:int=-1;
	    private var gotoPage:int;
		private var xScale:Number=1;
		private var yScale:Number=1;
        
		public function ShrinkStack()
		{
			super();
		}
		public function reset(toPage:int=0):void {
			while (stackItems.length > 0) {
				var canv:Canvas=stackItems[stackItems.length-1].canvas;
				var page:int=stackItems[stackItems.length-1].pageNo;
				shrinkBar.removeChild(canv);
				stackItems.pop();
			}
			selectedIndex=toPage;
		}

		private function putScreenAway(target:Container,toX:int,toY:int):void 
		{
			if (firstPutAway) {
		        fade.alphaFrom=1;
		        fade.alphaTo=1;//0.6;

				mover.yFrom=0;
				mover.xFrom=0;
				mover.easingFunction=Exponential.easeInOut;

				zoom.originX=0;
				zoom.originY=0;
				zoom.zoomWidthFrom=1;
				zoom.zoomHeightFrom=1;
				zoom.easingFunction=Exponential.easeInOut;
				
		        parallel.addChild(mover);
		        parallel.addChild(zoom);
		        parallel.addChild(fade);
				parallel.suspendBackgroundProcessing=true;
								
		        firstPutAway=false;
			}
	        if (zoomSpeed > 100) {
				parallel.startDelay=250;
	        } else {
				parallel.startDelay=0;
	        }
			parallel.duration=zoomSpeed;
	
			zoom.zoomWidthTo=(newWidth*xScale)/target.width;
			zoom.zoomHeightTo=(newHeight*yScale)/target.height;
			zoom.zoomWidthFrom=xScale;
			zoom.zoomHeightFrom=yScale;
			
			mover.yTo=toY;
			mover.xTo=toX; 

			parallel.target=target;

			parallel.play();
			parallel.addEventListener(EffectEvent.EFFECT_START,putAwayStart);
			parallel.addEventListener(EffectEvent.EFFECT_END,putAwayDone);
		}
		private function putAwayStart(event:EffectEvent):void {
			if (gotoPage>=0) {
				selectedIndex=gotoPage;
				validateNow();
				gotoPage=-1;
			}
		}
        
		private function putAwayDone(event:EffectEvent):void {
			var ph:Container=Container(event.target.target);
			var img:Image=Image(ph.removeChildAt(0));
			var canv:Canvas=new Canvas();
 			PopUpManager.removePopUp(ph);
			ph.visible=false;
//			parent.removeChild(ph);
			ph=null;
			img.width=newWidth;	
	       	img.height=newHeight;			
            canv.addChild(img); 
            canv.verticalScrollPolicy="off";
            canv.horizontalScrollPolicy="off";
            img.alpha=1;
            img.id=String(stackItems.length);
            img.addEventListener(MouseEvent.CLICK,stackItemClicked);
            canv.buttonMode=true;
            canv.setStyle("backgroundColor","#ECF5E7");
            canv.setStyle("borderStyle","solid");
            canv.setStyle("borderColor","#FFFFFF");
            canv.setStyle("borderThickness","1");
            canv.setStyle("cornerRadius","5");
            UIUtils.addExpand(canv,2.5,30);
            stackItems.push({canvas:canv,pageNo:previousPage});
            shrinkBar.addChild(canv);
		}
		private function PopStackItem():int {
			var page:int;
			if (stackItems.length == 0) {
				page=selectedIndex;
			} else {
				var canv:Canvas=stackItems[stackItems.length-1].canvas;
				page=stackItems[stackItems.length-1].pageNo;
				shrinkBar.removeChild(canv);
				stackItems.pop();
				dispatchEvent(new Event("PoppedItem"));
			}
			return page;
		}
		private function stackItemClicked(event:MouseEvent):void {
			var index:int=int(Image(event.target).id);
			if (index < stackItems.length) {
				while (stackItems.length > index+1) {
					PopStackItem();
				}
				selectedIndex=PopStackItem();
			}
		}
        /*private function takeSnapshot(source:DisplayObjectContainer,flipVertically:Boolean=false):Image {
			var img:Image = new Image();
			var hgt:Number=(source is DisplayObject		 )?DisplayObject(source).height:
										  (source is BitmapData    		 )?BitmapData(source).height:
										  (source is IFlexDisplayObject)?IFlexDisplayObject(source).height:
										  source.height;

			var matrix:Matrix=new Matrix(1,0,0,(flipVertically?-1:1),0,(flipVertically?hgt:0));
			img.source=new Bitmap(ImageSnapshot.captureBitmapData(source,matrix));
			img.width=source.width;
			img.height=source.height;
            return(img);
        }	*/		
		private function gotoScreen(gotoPage:int,toX:Number,toY:Number):void {
			if (shrinkBar == null) return;
			// cover screen with picture of screen
			var pictureHolder:Canvas=new Canvas();
			var screenShot:Image =UIUtils.takeSnapshot(parent);
			
			pictureHolder.addChild(screenShot);
			pictureHolder.x=0;
			pictureHolder.y=0;
			pictureHolder.width=screenShot.contentWidth;
			pictureHolder.height=screenShot.contentHeight;
			pictureHolder.alpha=1;
 			pictureHolder.visible=true;
			var p:DisplayObjectContainer=parent;
			xScale=1;
			while (p!=null) {
				xScale*=p.scaleX;
				p=p.parent;
			}
			p=parent;
			yScale=1;
			while (p!=null) {
				yScale*=p.scaleY;
				p=p.parent;
			}
 			pictureHolder.scaleX=xScale;
 			pictureHolder.scaleY=yScale;
 			toX*=xScale;
 			toY*=yScale;
 			
 			PopUpManager.addPopUp(pictureHolder,parent,false);
 			PopUpManager.bringToFront(pictureHolder);
 			pictureHolder.validateNow();
 			previousPage=selectedIndex;
 			this.gotoPage=gotoPage;
             // play animation
             putScreenAway(pictureHolder,toX,toY);
		}
		public function selectPage(pageNumber:int,SamePageAgain:Boolean=false):void {
			if ((shrinkBar == null) || ((pageNumber == selectedIndex)&&(!SamePageAgain))) return;
	        parallel.end();
			newHeight=shrinkBar.height-26;
			newWidth=(newHeight/3)*4;
			var gap:int=shrinkBar.getStyle("horizontalGap");
			var nc:int=shrinkBar.numChildren;
			gotoScreen(pageNumber,shrinkBar.x+(nc-1)*(newWidth+gap)+gap*2,shrinkBar.y+1);
		}
		public function nextScreen():void {
			selectPage((selectedIndex+1)%numChildren);
		}
		public function prevScreen():void {
			selectedIndex=PopStackItem();
		}
		
	}
}