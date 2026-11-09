package com.proiam.slides
{
	import mx.containers.Canvas;
	import flash.display.DisplayObject;
	import mx.core.UIComponent;

	public class SqueezeCanvas extends Canvas
	{
		private var _horizontalGap:int=5;
		[Bindable]
        [Inspectable(defaultValue=5)]
		public function set horizontalGap(value:int):void {
			_horizontalGap=value;
		}
		public function get horizontalGap():int {
			return _horizontalGap;
		}
		private var _verticalGap:int=5;
		[Bindable]
        [Inspectable(defaultValue=5)]
		public function set verticalGap(value:int):void {
			_verticalGap=value;
		}
		public function get verticalGap():int {
			return _verticalGap;
		}
		private function getActiveNode():int {
			for (var i:int=0;i<numChildren;i++) {
				var child:SecondaryItem=SecondaryItem(getChildAt(i));
				if (child.inspecting)
					return(i);
			}
			return (-1);
		}
		private function clearScale():void{
			for (var i:int=0;i<numChildren;i++) {
				var child:SecondaryItem=SecondaryItem(getChildAt(i));
				child.scaleX=1;
				child.scaleY=1;
			}
		}
		private function scaleNodes(an:int):DisplayObject {
			if (an < 0) return null;
			var activeNode:DisplayObject=getChildAt(an);
			var hScale:Number=(height-activeNode.height)/(height/2);
			var wScale:Number=(width-activeNode.width)/4/(width/5);
			wScale*=(width-_horizontalGap*4)/width;
			hScale*=(height-verticalGap)/height;
			for (var i:int=0;i<numChildren;i++) {
				var child:DisplayObject=getChildAt(i);	
				if (i != an) {
					if (((an < 5) &&(i >= 5))||((an>=5)&&(i<5))) {
						child.scaleX=1;
						child.scaleY=hScale;
					} else {
						child.scaleX=wScale;
						child.scaleY=1;
					}
				} else {
					child.scaleX=1;
					child.scaleY=1;
				}
			}
			return activeNode;
		}
		private function layoutChildren():void {
			if (numChildren <3) return;
			var an:int=getActiveNode();
			if (an<0) clearScale();
			var activeNode:DisplayObject=scaleNodes(an);
			var child:DisplayObject;
			if (an!=0) {
				child=getChildAt(0);
			} else {
				child=getChildAt(1);
			}
			var stdHeight:Number=child.height;
			trace(an);
			
			var prevX:Number=0;
			var prevY:Number=0;
			for (var i:int=0;i<numChildren;i++) {
				child=getChildAt(i);
				if ((prevX+child.width)> width) {
					prevX=0;
					if ((an < 5) && (activeNode!=null)) {
						prevY=prevY+activeNode.height+verticalGap;
					} else {
						prevY=prevY+stdHeight+verticalGap;
					}
				}
				child.x=prevX;
				child.y=prevY;
				prevX+=child.width+horizontalGap;
			}
		}
		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
		{
			super.updateDisplayList(unscaledWidth, unscaledHeight);
			layoutChildren();
		}
	}
}