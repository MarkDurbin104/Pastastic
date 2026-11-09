package com.proiam
{
	import flash.events.MouseEvent;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextLineMetrics;
	
	import mx.containers.Canvas;
	import mx.core.UIComponent;
	import mx.core.UITextField;

	public class XMLView extends Canvas
	{
		private var bgCanvas:Canvas;
		
		private var _dataProvider:XML=new XML();
			public function set dataProvider(value:XML):void { _dataProvider=value; recreateChildren();	}
			public function get dataProvider():XML { return _dataProvider; }
		
		private var _shapeProvider:XML = new XML(<shapes><shape name="roundRect" type="roundRect" cornerRadius="15" borderThickness="2" borderColor="#FF0000"/></shapes>);
			public function set shapeProvider(value:XML):void { _shapeProvider=value; recreateChildren();}
			public function get shapeProvider():XML { return _shapeProvider; }
		
		public var _shapeDataMap:XML = new XML(<shapeDataMap><map elemName="service" shape="roundRect"/></shapeDataMap>);
			public function set shapeDataMap(value:XML):void { _shapeDataMap=value; recreateChildren(); }
			public function get shapeDataMap():XML {return _shapeDataMap;	}

		public function XMLView()
		{
			super();
		}
		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void {
			super.updateDisplayList(unscaledWidth,unscaledHeight);
		}
		override protected function createChildren():void {
			super.createChildren();
			recreateChildren();
		}
		private function nV(value:String,defValue:Number):Number {
			return (value.length>0?Number(value):defValue); 
		}
		private function nS(value:String,defValue:String):String {
			return (value.length>0?value:defValue); 
		}
		private function nI(value:String,defValue:int):int {
			return (value.length>0?int(value):defValue); 
		}
		protected function addChildNodes(parentNode:UIComponent,bgCanvas:Canvas,x:int,y:int,nodes:XMLList):int {
			var nodeHeight:Number=0;
			for each (var node:XML in nodes) {
				var color:int;
				if (parentNode==null)
					color=0x00F0FF;
				else if (node.name()==null) 
					color=0xFFFFF0;
				else if (String(node.@Name).length==0)
					color=0xFFFFE0;
				else
					color=0xE0FF00;
					
				var itemObj:Node=new Node(bgCanvas,parentNode,
																	nV(node.@x,x),nV(node.@y,y+nodeHeight),
																	nV(node.@width,180),nV(node.@height,30),
																	(node.name()==null?node.toXMLString():nS(node.@Name,node.name())),
																	nI(node.@color,color),
																	itemClicked);
					
				nodeHeight+=Math.max(itemObj.height,addChildNodes(itemObj,bgCanvas,itemObj.x+itemObj.width+20,y+nodeHeight,node.children()))+5;
			}
			if (nodeHeight>0) nodeHeight-=5;
			return nodeHeight;
		}
		protected function recreateChildren():void {
			removeAllChildren();
			if (dataProvider != null) {
				bgCanvas=new Canvas();
				addChild(bgCanvas);
				bgCanvas.x=0;
				bgCanvas.y=0;
				bgCanvas.graphics.lineStyle(1);
				addChildNodes(null,bgCanvas,10,10,_dataProvider.children());
			}			
		}
		protected function itemClicked(event:MouseEvent):void {
			
		}
	}
}
	import mx.core.UIComponent;
	import flash.events.MouseEvent;
	import mx.core.UITextField;
	import flash.text.TextLineMetrics;
	import flash.text.TextFieldAutoSize;
	import mx.containers.Canvas;
	
class TextMetrics
{
	public var asString:String="";
	public var width:Number=0;
	public var height:Number=0;
	public var lines:Array=new Array();
	public function TextMetrics(onComp:UIComponent,value:String) {
		var mt:TextLineMetrics;
		value=remCTRL(value); // clean out tabs etc.
		lines=value.split("\n"); // array of lines
		if (lines.length > 1) { // mor than one line, find longest for width calc
			asString=lines.join("\n");
			mt=onComp.measureText(lines[0]);
			width=mt.width;
			height=mt.height+mt.descent;
			for (var i:int=1;i<lines.length;i++) {
				mt=onComp.measureText(lines[i]);
				if (mt.width > width) width=mt.width;
				height+=mt.height+mt.descent;//+mt.ascent
			}
		} else {
			asString=lines[0];
			mt=onComp.measureText(lines[0]);
			width=mt.width;
			height=mt.height+mt.descent;
		} 
	}
	private function remCTRL(s:String):String {
		var retString:String="";
		for (var i:int=0;i<s.length;i++) {
			var charCode:Number=s.charCodeAt(i) ;
			if ((charCode == 10)||(charCode > 31)) {
				retString+=String.fromCharCode(charCode);
			}
		}
		return(retString);
	}
}
class Node extends UIComponent
{
	public function Node(parentCanvas:UIComponent,parentNode:UIComponent,xPos:Number,yPos:Number,w:Number,h:Number,nodeText:String,color:int,clickHandler:Function)
	{
		super();
		width=w; 
		height=h; 
		x=xPos; 
		y=yPos; 
		parentCanvas.addChild(this);		
		// setup object text
		var nameText:UITextField = new UITextField();
		addChild(nameText);

		var tm:TextMetrics=new TextMetrics(parentCanvas,nodeText);
		
		if (tm.width >(width-15)) 		width=tm.width+15;
		if (tm.height>(height-10)) 	height=tm.height+10;
		
		nameText.autoSize = TextFieldAutoSize.CENTER;
		nameText.x = width/2;
		nameText.y = 5;
		nameText.text = tm.asString;

		with (graphics) {
			beginFill(color);
			lineStyle(2);
			drawRoundRect(0,0,width,height,height/5,height/5);
			endFill();
		}
		
		var coverCanvas:Canvas=new Canvas();
		addChild(coverCanvas);
		coverCanvas.x=0;
		coverCanvas.y=0;
		coverCanvas.width=width;
		coverCanvas.height=height;
		coverCanvas.addEventListener(MouseEvent.CLICK,clickHandler);
		coverCanvas.buttonMode=true;
		
		if (parentNode!=null) {
			var startX:Number=parentNode.x+parentNode.width;
			var startY:Number=parentNode.y+parentNode.height/2;
			var endX:Number=x;
			var endY:Number=y+height/2;
			var midX:Number=startX+(endX-startX)/2;
			with (parentCanvas.graphics) {
				moveTo(startX,startY);
				lineTo(midX,startY);
				lineTo(midX,endY);
				lineTo(endX,endY);
			}
		}
	}
}