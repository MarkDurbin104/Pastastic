package com.cykorsystems.CoverFlow
{
	import mx.containers.Canvas;
	import mx.core.UIComponent;
	import mx.events.FlexEvent;
	import flash.geom.Rectangle;
	import flash.display.DisplayObject;
	import mx.controls.Image;
	import flash.display.Bitmap;
	import flash.display.IBitmapDrawable;
	import flash.display.BitmapData;
	import mx.core.IFlexDisplayObject;
	import com.cykorsystems.effects.SlideTween;
	import flash.events.Event;
	import mx.binding.utils.BindingUtils;
	import flash.events.MouseEvent;
	import mx.containers.HBox;
	import flash.geom.Matrix;
	import mx.controls.Spacer;
	import mx.controls.sliderClasses.Slider;
	import flash.utils.Timer;
	import flash.events.TimerEvent;
	import mx.effects.Move;
	import mx.effects.Resize;
	import mx.effects.Parallel;
	import mx.events.TweenEvent;
	import mx.events.EffectEvent;
	import mx.effects.Zoom;
	import com.cykorsystems.effects.ScaleTween;
	import mx.controls.Label;
	import mx.effects.easing.Exponential;
	import mx.effects.easing.Bounce;
	import mx.events.IndexChangedEvent;
	import com.cykorsystems.utils.UIUtils;

[Event(name="tweenComplete", type="flash.events.Event")]
[Event(name="change", type="mx.events.IndexChangedEvent")]

	public class CoverFlowCanvas extends Canvas
	{
		[Bindable]
		public var displayOn:Canvas;
		[Bindable]
		public var itemCount:int=0;
		private var _fullScreenMode:Boolean=true;
		[Bindable]
		public var fingerButton:Image=null;
		private var localFingerButton:Image=null;
		public var startDelay_mS:int=250;
		[Bindable]
		public var title:Label;
		
		private var slidesInitialised:Boolean=false;
		private var currentPosition:Number=0;
		private var displayComponent:UIComponent;
		private var slider:HBox;
		private var sliderBox:Canvas;
		private var sliderSpacer:Spacer;
		private var slides : Array = new Array();
		private var movingSlide:Boolean=false;
		private var slideTween:SlideTween;
		private var scaleTween:ScaleTween;
		private var magnitudePic:Canvas;
		
		public function CoverFlowCanvas()
		{
			super()
			addEventListener(FlexEvent.CREATION_COMPLETE,initSlides);
		}
		public function onSetMagnitudeComplete(value:Number):void {
			dispatchEvent(new Event("SetMagnitudeComplete"));
			if (_fullScreenMode) {
				try { CoverFlowSlide(slides[position]).target.visible=true; } catch(e:Error) {}
			}
//			try { displaySlideNumber(position); } catch(e:Error) {}
			try { position=position; } catch(e:Error) {}
			try { displayOn.removeChild(magnitudePic); } catch(e:Error) {}
			magnitudePic=null;
		}
		public function set magnitude(value:Number):void {
			if (magnitudePic !=null) {
				magnitudePic.scaleX=value;
				magnitudePic.scaleY=value;
				magnitudePic.x=(1024-(value*1024))/2;
				magnitudePic.y=(768-(value*768))/2;
			}
		}
		[Bindable]
		public function set fullScreenMode(value:Boolean):void {
			if (_fullScreenMode != value) {
				_fullScreenMode=value;
				if (slidesInitialised) {
					if (CoverFlowSlide(slides[position]).target.visible) {
						CoverFlowSlide(slides[position]).refresh();
		 				CoverFlowSlide(slides[position]).target.visible=false;
					}
					if (scaleTween != null) {
						scaleTween.end();
						scaleTween=null;
					}
					scaleTween=new ScaleTween(this);
					scaleTween.easingFunction=Exponential.easeInOut;
					scaleTween.duration=400;
					if (_fullScreenMode) {
						scaleTween.magFrom=600/1024;
						scaleTween.magTo=1;
					} else {
						scaleTween.magFrom=1;
						scaleTween.magTo=600/1024;
					}
					if (magnitudePic !=null) {
						try {
							displayOn.removeChild(magnitudePic);
						}catch (e:Error) {}
					}
	 				magnitudePic=new Canvas();
	 				magnitudePic.width=1024;
	 				magnitudePic.height=768;
	 				UIUtils.drawComponent(UIComponent(CoverFlowSlide(slides[position]).target),magnitudePic,true);
	 				magnitudePic.graphics.lineStyle(4,0);
	 				magnitudePic.graphics.drawRect(0,0,1024,768);
	 				magnitude=scaleTween.magFrom;
	 				displayOn.addChild(magnitudePic);
					scaleTween.play();
				}
				fingerButton.visible=_fullScreenMode;
			}
		}
		private function fsChangeComplete(event:EffectEvent):void {
			displaySlideNumber(position);
		}
		
		public function get fullScreenMode():Boolean {
			return _fullScreenMode;
		}
		public function set tweeningPosition(value:Number):void {
			displaySlideNumber(value);
		}
		public function get tweeningPosition():Number {
			return currentPosition;
		}
		public function onTweenComplete(value:Number):void {
//			if (_fullScreenMode)
//				dispatchEvent(new IndexChangedEvent(IndexChangedEvent.CHANGE));
			dispatchEvent(new Event("tweenComplete"));
		}
		public function set position(value:Number):void {
			var oldPos:Number=currentPosition;
			var targetPosition:Number;
			if (Math.floor(value)<Math.round(value)) { // closer to right
				targetPosition=Math.round(value);
			} else { // closer to left
				targetPosition=Math.floor(value);
			}
			if (_fullScreenMode) {
				displaySlideNumber(value);
				dispatchEvent(new IndexChangedEvent(IndexChangedEvent.CHANGE,false,false,null,oldPos,value));
//				dispatchEvent(new Event("SlideSelected"));
				return;
			} else {
				displaySlideNumber(value);
				if (slideTween != null) {
					slideTween.end();
					slideTween=null;
				}
				slideTween=new SlideTween(this);
				slideTween.percentFrom=value;
				slideTween.percentTo=targetPosition;
				slideTween.duration=250;
				slideTween.startDelay=startDelay_mS;
				slideTween.play();
			}
		}
		public function get position():Number {
			if (Math.floor(currentPosition)<Math.round(currentPosition)) { // closer to right
				return Math.round(currentPosition);
			}
			// closer to left
			return Math.floor(currentPosition);
		}
		private function initSlides(event:FlexEvent) : void{			
			if (displayOn ==null) return;
			slidesInitialised=true;
			var childRect:Rectangle=new Rectangle(0,0,1024,768);
			var workArea:Rectangle=new Rectangle(0,0,1024,768);
			displayComponent=new UIComponent();
			displayOn.addChild(displayComponent);
			displayComponent.setActualSize(displayOn.width,displayOn.height);
			displayComponent.visible=false;
			title=new Label();
			displayOn.addChild(title);
			title.x=0;
			title.width=displayOn.width;
			title.setStyle("top","100"); 
			title.setStyle("fontFamily","Verdana");
			title.setStyle("fontSize","16");
			title.setStyle("fontWeight","bold"); 
			title.setStyle("textAlign","center");
			title.setStyle("color","#3E70A4");
			title.enabled=true;
			title.selectable=false;
			slider=new HBox();
			displayOn.addChild(slider);
			slider.x=20;
			slider.y=workArea.height-140;
			slider.width=workArea.width-40;
			slider.height=120;
			slider.setStyle("backgroundColor","#3E70A4");
			slider.horizontalScrollPolicy="off";
			slider.verticalScrollPolicy="off";
			slider.setStyle("verticalAlign","middle");
			slider.setStyle("horizontalGap","10");
			sliderSpacer=new Spacer()
			slider.addChild(sliderSpacer);
			sliderSpacer.width=512-71;
			if (fingerButton != null) {
				localFingerButton=new Image();
				localFingerButton.source=fingerButton.source;
				localFingerButton.x=fingerButton.x;
				localFingerButton.y=fingerButton.y;
				localFingerButton.width=fingerButton.width;
				localFingerButton.height=fingerButton.height;
				displayOn.addChild(localFingerButton);
				fingerButton.x=512-(fingerButton.width/2);
 				fingerButton.addEventListener(MouseEvent.MOUSE_DOWN,mainFingerButtonOver);
 				localFingerButton.addEventListener(MouseEvent.MOUSE_MOVE,fingerButtonOver);
				localFingerButton.x=512-(fingerButton.width/2)
			}
			sliderBox=new Canvas();
			displayOn.addChild(sliderBox);
			sliderBox.x=0;
			sliderBox.y=slider.y;
			sliderBox.width=workArea.width;
			sliderBox.height=(workArea.height-sliderBox.y);
 			sliderBox.addEventListener(MouseEvent.MOUSE_OUT,sliderOut);
 			sliderBox.addEventListener(MouseEvent.MOUSE_UP,sliderOut);
 			sliderBox.addEventListener(MouseEvent.MOUSE_MOVE,sliderOver);
 			sliderBox.addEventListener(MouseEvent.MOUSE_DOWN,sliderOver);
			addEventListener("slideUpdated",slideUpdated);
			itemCount=numChildren;
 			for(var i:int=0;i<itemCount; i++) {
				var child:UIComponent=UIComponent(getChildAt(i)); 
 				if (fullScreenMode) child.setActualSize(1024,768);
//				child.validateNow();
				child.visible=false;

 				var childPic:Canvas=new Canvas();
				var slide:CoverFlowSlide = new CoverFlowSlide(this,child,childRect,true,workArea,childPic);
				displayComponent.addChild(slide.container);
				slide.container.addEventListener(MouseEvent.CLICK,containerClicked);
				slides.push(slide);
				
 				childPic.width=132;
 				childPic.height=100;
 				UIUtils.drawComponent(child,childPic,false);
 				slider.addChild(childPic);
			}
			position=0; // draw initial coverflow
			if (localFingerButton != null) {
				slider.visible=false;
				sliderBox.visible=false;
			}
			displaySlideNumber(position);
		}	
		private var inMouseHandler:Boolean=false;
		private function sliderOut(event:MouseEvent):void {
			position=position; // finish off any tween
			inMouseHandler=false;
			sliderBox.graphics.clear();
			if (localFingerButton != null) {
				slider.visible=false;
				sliderBox.visible=false;
				localFingerButton.x=512-(localFingerButton.width/2);
				fullScreenMode=true;
			}
		}
		private var listLength:Number=0;
		private var listCentre:Number=0;
		private const totalMouseTravel:Number=600;
		private var listMovePerMousePixel:Number=0;
		private function fingerButtonOver(event:MouseEvent):void {
			slider.visible=true;
			sliderBox.visible=true;
			sliderOver(event);
		}
		private function mainFingerButtonOver(event:MouseEvent):void {
			fullScreenMode=false;
			slider.visible=true;
			sliderBox.visible=true;
			sliderOver(event,true);
		}
		private function sliderOver(event:MouseEvent,ignoreMouseX:Boolean=false):void {
			if (!inMouseHandler) {
				listLength=(slides.length*142)-10;
				listCentre=(position*142);
				if (listCentre < (listLength/2))
					listMovePerMousePixel=(listLength-listCentre)/(totalMouseTravel/2);
				else
					listMovePerMousePixel=listCentre/(totalMouseTravel/2);
			}
			inMouseHandler=true;
			
			sliderBox.graphics.clear();
			sliderBox.graphics.lineStyle(1,0xFFFFFF);
			
			var mouseAtX:Number;
			if (ignoreMouseX) {
				mouseAtX=512;
			} else {
				mouseAtX=event.localX;
			}
			if (mouseAtX < 212)  mouseAtX=212;
			else if (mouseAtX > 812)  mouseAtX=812;

			var mouseDistanceFromCentre:int=mouseAtX-512;
			var centreLinePosition:Number=listCentre+(mouseDistanceFromCentre*listMovePerMousePixel);
			
			// TODO limit slider travel to keep thambs on screen 
//			var maxLeftMove:Number=listCentre;
//			var maxRightMove:Number=listLength-listCentre;
//			if (centreLinePosition < maxLeftMove) centreLinePosition=maxLeftMove;
//			if (centreLinePosition > maxRightMove) centreLinePosition=maxRightMove;

			var mousePositionInList:Number=centreLinePosition+mouseDistanceFromCentre;
			var itemPositionInList:Number=mousePositionInList/142;
			if (itemPositionInList < 0) itemPositionInList=0;
			if (itemPositionInList >= slides.length) itemPositionInList=slides.length-1;
			var rightEndStop:int=(slider.width/2)-71;
			var leftEndStop:int=rightEndStop-listLength;
			
			sliderSpacer.width=rightEndStop-centreLinePosition;
			
			var selectedItem:Number=itemPositionInList;
			if (Math.floor(selectedItem) < Math.round(selectedItem)) {
				selectedItem=Math.round(selectedItem);
			} else {
				selectedItem=Math.floor(selectedItem);
			}

			if (event.buttonDown) {
				position=selectedItem;
				if (event.ctrlKey) {
					position=selectedItem;
				} else {
					position=itemPositionInList;
				}
			}
			if (localFingerButton != null) {
				localFingerButton.x=mouseAtX-(localFingerButton.width/2)
			} else {
				sliderBox.graphics.lineStyle(4,0xFFFF00);
				sliderBox.graphics.drawRoundRect(mouseAtX-70,5,140,sliderBox.height-10,10,10);
			}

//			var newPosition:int=(position*142)+sliderSpacer.width+slider.x;
//			sliderBox.graphics.lineStyle(2,0xECF5E7);
//			sliderBox.graphics.drawRoundRect(newPosition+5,5,140,110,10,10);
		} 
		private function slideUpdated(event:Event):void {
			var child:UIComponent=UIComponent(slider.getChildAt(position+1)); 
	 		UIUtils.drawComponent(UIComponent(CoverFlowSlide(slides[position]).target),child);
		}
		private function containerClicked(event:MouseEvent):void {
			for(var i:int=0; i<slides.length; i++) {
				if (slides[i].container==event.currentTarget) {
					startDelay_mS=0;
					if (i > currentPosition) {
						position=i-0.4;
					} else {
						position=i+0.4;
					}
					startDelay_mS=250;
					break;
				}
			}
		}
		private function sliderClicked(event:MouseEvent):void {
			try {
				for(var i:int=0; i<slider.numChildren; i++) {
					var child:UIComponent=UIComponent(slider.getChildAt(i)); 
					if (child==event.currentTarget) {
						startDelay_mS=0;
						if (i > currentPosition) {
							position=i-0.4;
						} else if (i < currentPosition) {
							position=i+0.4;
						}
						startDelay_mS=250;
						break;
					}
				}
			} catch (e:Error) { }
		}
		private function displaySlideNumber(position: Number) :void {
			var count:int=slides.length;
			if ((position < 0) || (Math.round(position) >= count)) return;
			movingSlide=true;
			try {
				var slide:CoverFlowSlide;
				var i:int;
				displayComponent.visible=false;
				
				try { 
					slide=slides[position];
					title.text=Object(slide.target).label;
				} catch(e:Error) {}
				
				for(i=0; i<count; i++) {
					slide=slides[i];
					var index:int=(count-1)-(Math.abs(Math.round(position)-i));
					displayComponent.setChildIndex(slide.container,index);
					slide.container.alpha=(1/(count-0.8))*index;
					slide.positionAt(50+((i-position)*15),int(position)==position);
				}
				displayComponent.visible=true;
				currentPosition=position;
			}
			finally {
				movingSlide=false;
			}
		}
	}
}