package com.tappernimer.components{
	import mx.containers.Canvas;
	import mx.core.UIComponent;
	import flash.display.BitmapData;
	import flash.geom.Matrix;
	import flash.display.IBitmapDrawable;
	import mx.events.FlexEvent;
	public class VerticalReflection extends Canvas {
		private var referenceComp:UIComponent;
		private var newComp:UIComponent = new UIComponent();
		public var transparency:Number=0.2;
		public var filterArray:Array=new Array();
		public var reflectedScale:Number=0.95;
		public var reflectedGap:Number=0.05;
		public function get referenceComponent():UIComponent{
			return referenceComp;
		}
		public function set referenceComponent(value:UIComponent):void{
			referenceComp = value;
			if (!referenceComp.initialized) {
				referenceComp.addEventListener(FlexEvent.CREATION_COMPLETE,reflectDown);
			} else {
				reflectDown(null);
			}
		}
		private function reflectDown(event:FlexEvent):void {
			var invertMatrix:Matrix = new Matrix();
			invertMatrix.scale(1, 0-reflectedScale);
			invertMatrix.translate(0,referenceComp.height*(reflectedScale+reflectedGap));
			var bmpData:BitmapData = new BitmapData(referenceComp.width,referenceComp.height*(reflectedScale+reflectedGap),true,0);
			bmpData.draw(referenceComp as IBitmapDrawable,invertMatrix);

			newComp.setActualSize(referenceComp.width,referenceComp.height*(reflectedScale+reflectedGap));
			newComp.graphics.beginBitmapFill(bmpData);
			newComp.graphics.drawRect(0, 0,referenceComp.width,referenceComp.height*(reflectedScale+reflectedGap));
			newComp.graphics.endFill();
			newComp.alpha=transparency;
			newComp.filters=filterArray;
			addChild(newComp);
		} 
	}
}