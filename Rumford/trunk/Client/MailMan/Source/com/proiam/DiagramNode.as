package com.proiam
{
	import mx.core.Container;

	public class DiagramNode extends Container
	{
		private var parentList:Array=new Array();
		private var childList:Array=new Array();
		
		public function DiagramNode()
		{
			super();
		}
		protected function addParent(parent:DiagramNode):int {
			var index:int=parentList.indexOf(parent);
			if (index < 0) {
				parentList.push(parent);
				parent.addChild(this);
			}
			return index;
		}
		protected function removeParent(parent:DiagramNode):int {
			var index:int=parentList.indexOf(parent);
			if (index >= 0) {
				parentList.splice(index,1);
				parent.removeChild(this);
			}
			return index;
		}
		protected function hasParent(parent:DiagramNode):Boolean {
			return (parentList.indexOf(parent) >= 0);
		}
		protected function addChild(child:DiagramNode):int {
			var index:int=childList.indexOf(child);
			if (index < 0) {
				childList.push(child);
				child.addParent(this);
			}
			return index;
		}
		protected function removeChild(child:DiagramNode):int {
			var index:int=childList.indexOf(child);
			if (index >= 0) {
				childList.splice(index,1);
				child.removeParent(this);
			}
			return index;
		}
		protected function hasChild(child:DiagramNode):Boolean {
			return (childList.indexOf(child) >= 0);
		}
		protected function repaint():void {
			var r:Number=Math.min(width,height)/10;
			with (graphics) {
				beginFill(0x400000);
				drawRoundRect(0,0,width,height,r,r);
				endFill();
			}
		}
		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void {
			super.updateDisplayList(unscaledWidth,unscaledHeight);
			repaint();
		}
		// create
		override protected function createChildren():void {
			super.createChildren();
		}
		protected function recreateChildren():void {
		//	removeAllChildren();
			repaint();
		}		
	}
}