package com.proiam.slides
{
	import mx.containers.Canvas;
	import mx.controls.Label;

	public class SelectedList extends Canvas
	{
		private var _items:Array=null;
		
		[Bindable]
		public function get items():Array {
			return _items;	
		}
		public function set items(value:Array):void {
			_items=value;
			layoutChildren();
		}
		
		public function SelectedList()
		{
			super();
			layoutChildren();
		}
		
		protected function layoutChildren():void {
			while (numChildren > 0) removeChildAt(0);
			graphics.clear();
			if (_items == null) return;
			var yOfs:int=0;
			for (var i:int=0;i<_items.length;i++) {
            	var label:Label = createTextField(0,yOfs,_items[i].caption);
            	label.width=200;
            	var price:Label = createTextField(150,yOfs,_items[i].price);
            	price.setStyle("textAlign","right");
            	price.setStyle("right","0");
            	yOfs+=15;
			}
		}
        private function createTextField(x:Number, y:Number,text:String):Label {
            var result:Label = new Label();
            result.x = x; result.y = y;
            result.text=text;
            addChild(result);
            return result;
        }
	}
}