package com.cykorsystems.CoverFlow
{
	import sandy.util.DistortImage;
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.geom.Rectangle;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.display.Shape;
	import flash.display.Sprite;
	import mx.controls.sliderClasses.Slider;
	import flash.utils.describeType;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import mx.core.UIComponent;
	import mx.containers.Canvas;
	import com.cykorsystems.utils.UIUtils;
	
[Event(name="slideUpdated", type="flash.events.Event")]

	public class CoverFlowSlide
	{
		public var smooth : Boolean;
		public var offsetRect : Rectangle;
		public var target : DisplayObject;
		public var parent : CoverFlowCanvas;
		public var container : Sprite;
		public var childPic:Canvas;
		private var transformedSlide : DistortImage;
		public var workArea:Rectangle
		
		public function CoverFlowSlide(parent:CoverFlowCanvas,target:DisplayObject,offsetRect:Rectangle=null,smooth:Boolean=true,workArea:Rectangle=null,childPic:Canvas=null)
		{
			this.target = target;			
			
			if (offsetRect == null) {
				offsetRect=target.getRect(target);
			}
			if (workArea== null) {
				workArea=offsetRect;
			}
			this.offsetRect = offsetRect;
			this.workArea=workArea;
			this.smooth=smooth;
			this.parent=parent;
			this.childPic=childPic;
			container = new Sprite();
			transformedSlide = new DistortImage();
			transformedSlide.smooth = smooth;
			transformedSlide.container = container;
			transformedSlide.target = target;								
			transformedSlide.initialize( 2,2, offsetRect );
			target.scaleX=(offsetRect.width/target.width)
			target.scaleY=(offsetRect.height/target.height)
			transformedSlide.smooth=true;
		}

		public function refresh():void {
			UIComponent(target).validateNow();
			transformedSlide.initialize( 2,2, offsetRect );
			UIUtils.drawComponent(UIComponent(target),childPic,false);
		}

		public function positionAt(percentage:Number,traceAngles:Boolean=false):void
		{
			if ((percentage > 91) || (percentage < 1)) {
				target.visible=false;
				container.visible=false;
				return;
			}
			// get target rectangle
			var targetRect:PolyRect = new PolyRect(offsetRect);
			// centre on screen
			offsetRect.width=600;
			offsetRect.height=450;
			targetRect.moveBy(new Point(workArea.left+(workArea.width-offsetRect.width)/2,
														workArea.top+(workArea.height-offsetRect.height)/2));
			// we're on the centre position, show the actual screen and exit
			if ((percentage == 50)&&(parent.fullScreenMode)){
				target.x=workArea.x;
				target.y=workArea.y;
				target.width=workArea.width;
				target.height=workArea.height;
				target.visible=true; 
//				container.visible=false; // hide background container
				return;
			} else {
				// if we're moving off the centre screen, save an image of it (in chase it changed)
				if (target.visible)  {
					parent.dispatchEvent(new Event("slideUpdated"));
					transformedSlide.initialize( 2,2, offsetRect );
					target.visible=false;
				}
				container.visible=true; // show background container
			}
			var itemRotation:Number;
			itemRotation=percentage*1.8; // 0-100 % == 0-180 degrees
			if (percentage < 50) { // 0-50 % move in from left
				var TL:Point=new Point(targetRect.cornerBL.x-200,targetRect.cornerBL.y);
				targetRect.rotateYBy(itemRotation-90,targetRect.cornerBL);
				targetRect.moveBy(new Point(-(50-percentage)*5,0-(50-percentage)/2));
				targetRect.scaleBy(new Point(1,0.8+0.004*percentage));
			} else { // 50-100% move out to right
				targetRect.rotateYBy(itemRotation-90,targetRect.cornerBR);
				targetRect.moveBy(new Point((percentage-50)*5,0-(percentage-50)/2));
				targetRect.scaleBy(new Point(1,0.8+0.004*(100-percentage)));
			}
			// do the transformation
			transformedSlide.setTransform(targetRect.cornerTL.x,targetRect.cornerTL.y,
																	 targetRect.cornerTR.x,targetRect.cornerTR.y,
																	 targetRect.cornerBR.x,targetRect.cornerBR.y,
																	 targetRect.cornerBL.x,targetRect.cornerBL.y);
		}
	}
}