package com.proiam.slides
{
	import flash.display.DisplayObject;
//	import com.proiam.mails.MailService;
	import com.proiam.mails.MailService;
	import mx.containers.Canvas;

	public class SqueezeCanvas extends Canvas
	{
		public var primaryMailService:MailService=null;		
		private var _horizontalGap:int=5;
		[Bindable]
        [Inspectable(defaultValue=5)]
		public function set horizontalGap(value:int):void {
			_horizontalGap=value;
			layoutChildren();
		}
		public function get horizontalGap():int {
			return _horizontalGap;
		}
		private var _verticalGap:int=5;
		[Bindable]
        [Inspectable(defaultValue=5)]
		public function set verticalGap(value:int):void {
			_verticalGap=value;
			layoutChildren();
		}
		public function get verticalGap():int {
			return _verticalGap;
		}
		private function getActiveNode():int {
			//return (-1);
			for (var i:int=0;i<numChildren;i++) {
				var child:AdditionalItem=AdditionalItem(getChildAt(i));
				if (child.currentState=="inConflictResolution")
					return(i);
			}
			return (-1);
		}
		private function layoutChildren():void {
			if (numChildren < 2) return;
			var activeNode:DisplayObject=null;
			var an:int=getActiveNode();
			if (an>=0) {
				activeNode=getChildAt(an);
			}
			var child:DisplayObject;
			if (an!=0) {
				child=getChildAt(0);
			} else {
				child=getChildAt(1);
			}
			var stdWid:Number=child.width;
			var stdHgt:Number=child.height;
			
			var currentX:Number=0;
			var currentY:Number=0;

			for (var i:int=0;i<numChildren;i++) {
				child=getChildAt(i);
				var secServiceName:String=AdditionalItem(child).service.shortName;
				if ((primaryMailService == null) || (primaryMailService.services.indexOf(secServiceName) >= 0)) {
					child.visible=true;
					if ((currentX+stdWid)> width) {
						currentX=0;
						currentY+=stdHgt+verticalGap;
					}
					child.x=currentX;
					child.y=currentY;
					currentX+=stdWid+horizontalGap;
				} else {
					child.visible=false;
				}
			}

			if (activeNode != null) {
				currentX=0;
				currentY=0;
				activeNode.y=0;
				if ((activeNode.width+activeNode.x) > width) 
					activeNode.x=width-(activeNode.width+1);
					
				for (i=0;i<numChildren;i++) {
					if (i != an) {
						child=getChildAt(i);
						if (((currentX >= activeNode.x)  && (currentX <= activeNode.x+activeNode.width))
						|| ((currentX+child.width >= activeNode.x)  && (currentX < activeNode.x))) {
							currentX=activeNode.x+activeNode.width+horizontalGap;
						}
						if ((currentX+child.width)>= width) {
							currentX=0;
							currentY+=stdHgt+verticalGap;
						}
						if (((currentX >= activeNode.x)  && (currentX <= activeNode.x+activeNode.width))
						|| ((currentX+child.width >= activeNode.x)  && (currentX < activeNode.x))) {
							currentX=activeNode.x+activeNode.width+horizontalGap;
						}
						child.x=currentX;
						child.y=currentY;
						currentX+=stdWid+horizontalGap;
					}
				}
			}
		}
		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
		{
			super.updateDisplayList(unscaledWidth, unscaledHeight);
			layoutChildren();
		}
	}
}