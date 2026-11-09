package com.proiam
{
	import flash.display.DisplayObject;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	
	import mx.containers.Canvas;
	import mx.controls.TextArea;

	[Event(name="designerClicked", type="flash.events.MouseEvent")]

	public class CircuitDesigner extends Canvas
	{
		private var selBox:Canvas=new Canvas();
		public function CircuitDesigner() {
			super();
			selBox.visible=false;
			selBox.setStyle("backgroundColor","#FFFFFF");
			selBox.setStyle("backgroundAlpha","0.25");
			selBox.setStyle("borderStyle","solid");
			selBox.setStyle("borderThickness","2");
			selBox.setStyle("borderColor","0");
			selBox.setStyle("borderAlpha","0.5");
			addEventListener(MouseEvent.MOUSE_DOWN,onMouseDown);
			addEventListener(MouseEvent.MOUSE_WHEEL,onMouseWheel);
			addEventListener(MouseEvent.MOUSE_MOVE,onMouseMove);
			addEventListener(MouseEvent.MOUSE_UP,onMouseUp);
			setStyle("backgroundColor","#F0F0F0");
		}
		
		private function sortRect(rect:Rectangle):Rectangle {
			if (rect!=null) {
				if (rect.left > rect.right) {
					if (rect.top > rect.bottom) {
						return new Rectangle(rect.right,rect.bottom,rect.left-rect.right,rect.top-rect.bottom);
					} else {
						return new Rectangle(rect.right,rect.top,rect.left-rect.right,rect.bottom-rect.top);
					}
				} else if (rect.top > rect.bottom) {
					return new Rectangle(rect.left,rect.bottom,rect.right-rect.left,rect.top-rect.bottom);
				}
			}
			return rect;
		}
		public function setSelected(toState:Boolean,withinRect:Rectangle=null,toggle:Boolean=false,exclude:NodeCanvas=null):Boolean {
			var changed:Boolean=false;
			withinRect=sortRect(withinRect);
			for (var i:int=0;i<numChildren;i++) {
				if (getChildAt(i) is NodeCanvas) {
					var nc:NodeCanvas=NodeCanvas(getChildAt(i));
					if ((nc.node!=null)&&(exclude!=nc)&&((withinRect==null)||(withinRect.containsRect(new Rectangle(nc.x,nc.y,nc.width,nc.height))))) {
						changed=true;
						if (toggle)
							nc.selected=!nc.selected;
						else					
							nc.selected=toState;			
					}
				}
			}
			return changed;
		}
		private var selStart:Point=new Point(-1,-1);
		private var selRect:Rectangle=new Rectangle(0,0,0,0);
		private function drawBGRect():void {
			if ((selRect.width==0)&&(selRect.height==0)) {
				if (selBox.parent!=null) removeChild(selBox);
			} else {
				if (selBox.parent==null) addChild(selBox);
				selBox.x=selRect.x;
				selBox.y=selRect.y;
				selBox.width=selRect.width;
				selBox.height=selRect.height;
				selBox.visible=true;
			}
		}
		public function onMouseWheel( event:MouseEvent ):void {
			if ((event.delta<0)&&(scaleX<4)) {
				scaleY*=2;
				scaleX=scaleY;
			} else if ((event.delta>0)&&(scaleX>0.25)) {
				scaleY/=2;
				scaleX=scaleY;
			}
		}
		public function onMouseMove( event:MouseEvent ):void {
			if ((event.buttonDown)&&(selStart.x>=0)) {
				selRect.width=event.stageX-selStart.x;
				selRect.height=event.stageY-selStart.y;
				drawBGRect();
				trace ("move "+selRect.left+","+selRect.top+","+selRect.right+","+selRect.bottom+","+selRect.width+","+selRect.height);
				setSelected(true,selRect,event.shiftKey||event.ctrlKey);
			}
		}
		public function onMouseUp( event:MouseEvent ):void {
			trace ("up "+selRect.left+","+selRect.top+","+selRect.right+","+selRect.bottom);
			selRect.x=0;
			selRect.y=0;
			selRect.width=0;
			selRect.height=0;
			selStart.x=-1;
			selStart.y=-1;
			drawBGRect();
		}
		public function onMouseDown( event:MouseEvent ):void {
			if (event.target==this) {
				var changed:Boolean=false;
				if (!(event.ctrlKey||event.shiftKey)) {
					if (numChildren>0) 
						changed=NodeCanvas(getChildAt(0)).deleselectOthers(null);
				}
				selRect.x=event.localX;
				selRect.y=event.localY;
				selRect.width=0;
				selRect.height=0;
				selStart.x=event.stageX;
				selStart.y=event.stageY;
				trace ("down "+selRect.left+","+selRect.top+","+selRect.right+","+selRect.bottom);
			}
		}
		public var dataProvider:XML=null;
		private var symbols:XML=null;
		private var shapes:Array=new Array();
		private var links:Array=new Array();
		public var filePath:String="";
		private var _fileName:String="";
		[Bindable]
		public var ready:Boolean=false;
		[Bindable]
		public var modified:Boolean=false;
		public var cursorType:String="Arrow";
		public var stickyCursor:Boolean=false;
		public var selecting:Boolean=false;
		[Bindable]
		public function set fileName(value:String):void {
			_fileName=value;
			if (fileName!="")	loadFile(_fileName);
		}
		public function get fileName():String {
			return _fileName;
		}
		private function clearCanvas():void {
			symbols=null;
			dataProvider=null;
			shapes=new Array();
			links=new Array();
			removeAllChildren();
		}
		private function uniqueString():String {
			return("?unique="+new Date().getTime());
		}
		private function loadFile(fileName:String):void {
			clearCanvas();
			var fileLoader:URLLoader = new URLLoader(); 
			fileLoader.addEventListener(Event.COMPLETE,onFileLoaded);
			fileLoader.load(new URLRequest(filePath+fileName+uniqueString()));
		}				
		private function onFileLoaded(event:Event):void {				
			dataProvider=new XML(event.target.data);
			if (getString(dataProvider.elements.@definedIn,"") !="") {
				loadSymbols(getString(dataProvider.elements.@definedIn,""));
			} else {
				loadSymbols("serviceSymbols.xml");
			}
		}
		private function onMouseClick(event:MouseEvent):void {
			if ((cursorType=="Magnify")&&(scaleX<4)) {
				scaleY*=2;
				scaleX=scaleY;
			} else if ((cursorType=="UnMagnify")&&(scaleX>0.25)) {
				scaleY/=2;
				scaleX=scaleY;
			} else if (cursorType=="Line") {
			} else if (cursorType=="Text") {
			} else if (cursorType=="Arrow") {
			} else {
				addNewNode(event.localX,event.localY,cursorType);
            	dispatchEvent(new MouseEvent("designerClicked",event.bubbles,event.cancelable,
            															event.localX,event.localY,event.relatedObject,
            															event.ctrlKey,event.altKey,event.shiftKey,
            															event.buttonDown,event.delta));
			}
           	event.stopPropagation();
		}
		private function loadSymbols(fileName:String):void {
			var fileLoader:URLLoader = new URLLoader(); 
			fileLoader.addEventListener(Event.COMPLETE,onSymbolsLoaded);
			fileLoader.load(new URLRequest(filePath+fileName+uniqueString()));
			ready=true;			
		}				
		private function onSymbolsLoaded(event:Event):void {				
			symbols=new XML(event.target.data);
			recreateChildren();
		}
		public function newDiagram(fileName:String=""):void {				
			dataProvider=new XML(<diagram><elements definedIn="serviceSymbols.xml"/></diagram>);			
			loadSymbols(dataProvider.elements.@definedIn);
		}
		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void {
			super.updateDisplayList(unscaledWidth,unscaledHeight);
		}
		override protected function createChildren():void {
			super.createChildren();
			recreateChildren();
		}
		protected function recreateChildren():void {
			removeAllChildren();
			if (symbols !=null) {
				addSymbols(symbols);
				if (dataProvider != null) {
					addChildNodes(dataProvider);
					if (dataProvider.elements.children().length<1) {
						var tmp:NodeCanvas=new NodeCanvas(null);
						tmp.x=parent.width-1;
						tmp.y=parent.height-1;
						tmp.width=1;
						tmp.height=1;
						tmp.setStyle("backgroundColor","#FFFFFF");
						addChild(tmp);
					}			
				}
			}
			modified=false;
			selecting=true;
			setStyle("backgroundColor","#FFFFFF");
			addEventListener( MouseEvent.CLICK, onMouseClick );
		}
		private function getString(value:String,defaultValue:String):String {
			if ((value == null)||(value=="")) {
				return defaultValue;
			}
			return value;
		}
		private function getNumber(value:String,defaultValue:Number):Number {
			if ((value == null)||(value=="")) {
				return defaultValue;
			}
			return Number(value);
		}
		private function getInt(value:String,defaultValue:int):int {
			if ((value == null)||(value=="")) {
				return defaultValue;
			}
			return int(value);
		}
		private function pointPrior(list:Array,prior:int):Boolean {
			var compPoint:Point=list[prior];
			for (var i:int=0;i<prior;i++) {
				var point:Point=list[i];
				if ((int(compPoint.x)==int(point.x))&&(int(compPoint.y)==int(point.y))) {
				//if (compPoint.equals(point)) {
					return true;
				}
			}
			return false;
		}
		private function pointAfter(list:Array,after:int):Boolean {
			var compPoint:Point=list[after];
			for (var i:int=after+1;i<list.length;i++) {
				var point:Point=list[i];
				if ((int(compPoint.x)==int(point.x))&&(int(compPoint.y)==int(point.y))) {
				//if (compPoint.equals(point)) {
					return true;
				}
			}
			return false;
		}
		private function adjustCompRect(compA:DisplayObject,compB:DisplayObject):void {
			var rectA:Rectangle=new Rectangle(compA.x,compA.y,compA.width,compA.height);
			var rectB:Rectangle=new Rectangle(compB.x+compA.x,compB.y+compA.y,compB.width,compB.height);
			if (rectA.containsRect(rectB)) return; 
			rectA=rectA.union(rectB);
			compA.x=rectA.x;
			compA.y=rectA.y;
			compA.width=rectA.width;
			compA.height=rectA.height;
		}
		public function drawPolygon(node:XML,diagramNode:Canvas,overrideX:Number,overrideY:Number,includeShape:Boolean,color:int,lineColor:int,lineThickness:Number,highLightCorners:Boolean=false,linkSection:int=-1):void {
			var minX:Number=Number.MAX_VALUE;					
			var minY:Number=Number.MAX_VALUE;					
			var maxX:Number=0;					
			var maxY:Number=0;					
			var pointList:Array=new Array();
			var x:Number;
			var y:Number;
			var width:Number;
			var height:Number;
			var itemType:String=node.name();
			
			for each (var point:XML in node.children()) {
				x=int(point.@x);
				y=int(point.@y);
				var p:Point=new Point(x,y);
				pointList.push(p);
				if (x<minX) minX=x;
				if (y<minY) minY=y;
				if (x>maxX) maxX=x;
				if (y>maxY) maxY=y;
			}
			if (pointList.length<1) return;
			
			x=((overrideX>=0)?overrideX:minX);
			y=((overrideY>=0)?overrideY:minY);
			width =maxX-minX;
			height=maxY-minY;
			
			if (!includeShape) {
				if (itemType == "link") {
					diagramNode.graphics.clear();
					if (highLightCorners) {
						lineColor=0xFF0000;
					}
					diagramNode.x=x;
					diagramNode.y=y;
					diagramNode.width =2;
					diagramNode.height=2;
					
				} else {
					diagramNode.x=x;
					diagramNode.y=y;
					diagramNode.width =width;
					diagramNode.height=height;
				}
			} else {
				minX-=overrideX-diagramNode.x;
				minY-=overrideY-diagramNode.y;
			}
			
			var index:int=0;
			
			if (itemType == "link") {
				index=0;
				/*diagramNode.graphics.lineStyle(lineThickness+1,0xFFFFFF,1,false,"normal","none");
				for each (point in node.children()) {
					x=point.@x-minX;
					y=point.@y-minY;
					
					if ((index==0)||(point.name()=="mpoint")||(point.name()=="jmpoint")||(point.name()=="mjpoint")) { 
						diagramNode.graphics.moveTo(int(x),int(y));
					} else {
	  			 		if  (String(point.@controlx)!="") {
					 		diagramNode.graphics.curveTo(int(point.@controlx-minX),int(point.@controly-minY),int(x),int(y));
				 		} else {
							diagramNode.graphics.lineTo(int(x),int(y));
				 		}
					}
					index++;
				}*/
				
				if (linkSection>=0) {
					diagramNode.graphics.lineStyle(0,0xFFFFFF);
					diagramNode.graphics.beginFill(0xFFFFFF,0.01);
					diagramNode.graphics.drawRect(0-diagramNode.x,0-diagramNode.y,diagramNode.x+diagramNode.width+1000,diagramNode.y+diagramNode.height+1000);
					diagramNode.graphics.endFill();
				}
				
				var lastPoint:Point=pointList[pointList.length-1];
				var prevPoint:Point=pointList[pointList.length-2];
				x=lastPoint.x-minX;
				y=lastPoint.y-minY;
				diagramNode.graphics.beginFill(lineColor);
				diagramNode.graphics.lineStyle(1,lineColor);
				diagramNode.graphics.moveTo(x,y);
				if (lastPoint.y == prevPoint.y ) {
					if (lastPoint.x > prevPoint.x) { 							// pointing right
						diagramNode.graphics.lineTo(x-10,y-3.5);
						diagramNode.graphics.lineTo(x-10,y+3.5);
					} else { 																// pointing left
						diagramNode.graphics.lineTo(x+10,y-3.5);
						diagramNode.graphics.lineTo(x+10,y+3.5);
					}
				} else {
					if (lastPoint.y > prevPoint.y) { 							// pointing down 					
						diagramNode.graphics.lineTo(x+3.5,y-10);
						diagramNode.graphics.lineTo(x-3.5,y-10);
					} else { 																// pointing up 					
						diagramNode.graphics.lineTo(x+3.5,y+10);
						diagramNode.graphics.lineTo(x-3.5,y+10);
					}
				}
				diagramNode.graphics.lineTo(x,y);
				diagramNode.graphics.endFill();
			}

			diagramNode.graphics.lineStyle(lineThickness,lineColor);
			
			index=0;
			
			diagramNode.graphics.beginFill(lineColor);
			for each (point in node.children()) {
				x=point.@x-minX;
				y=point.@y-minY;
				if ((point.name()=="jpoint")||(point.name()=="jmpoint")||(point.name()=="mjpoint")) {
					diagramNode.graphics.drawCircle(x,y,3.5);
				} 
				if ((highLightCorners)&&((linkSection<0)||(linkSection==index)||(linkSection+1==index))) {
					diagramNode.graphics.drawRect(x-4,y-4,8,8);
				} 
				index++;
			}
			diagramNode.graphics.endFill();
			
			diagramNode.graphics.lineStyle(lineThickness,lineColor);
			index=0;
			for each (point in node.children()) {
				x=point.@x-minX;
				y=point.@y-minY;
				
				if ((color >=0) &&(pointAfter(pointList,index))) 
					diagramNode.graphics.beginFill(color); // first point in a closed polygon - begin fill
					
				if ((index==0)||(point.name()=="mpoint")||(point.name()=="jmpoint")||(point.name()=="mjpoint")) { 
					diagramNode.graphics.moveTo(int(x),int(y));
				} else {
  			 		if  (String(point.@controlx)!="") {
				 		diagramNode.graphics.curveTo(int(point.@controlx-minX),int(point.@controly-minY),int(x),int(y));
			 		} else {
						diagramNode.graphics.lineTo(int(x),int(y));
			 		}
				}
				
				if ((color >=0) &&(pointPrior(pointList,index))) 
					diagramNode.graphics.endFill(); // last point in a closed polygon - end fill

				index++;
			}
		}
		protected function drawNode(diagramNode:NodeCanvas,x:Number,y:Number,itemType:String,overrideX:Number,overrideY:Number,node:XML,includeShape:Boolean=false,compositeNode:XML=null,sourceNode:XML=null):void {
			var lineThickness:Number=getNumber(node.@lineThickness,-1); 
			var lineColor:int=getInt(node.@lineColor,-1);
			var color:int=getInt(node.@color,-1);
			var width:Number;
			var height:Number;
				
			if (itemType == "link") {
				lineThickness=2;
				lineColor=0;
				color=-1;
			}
			if (itemType != "composite") {
				if ((lineThickness>=0) || (lineColor>=0) || (color<0)) {
					if (lineThickness<0) lineThickness=1;
					if (lineColor<0) lineColor=0;
					diagramNode.graphics.lineStyle(lineThickness,lineColor);						
				}
			}
			if (itemType ==	"rectangle") {
				x=((overrideX>=0)?overrideX:x);
				y=((overrideY>=0)?overrideY:y);
				width =getNumber(node.@width,100);
				height=getNumber(node.@height,30);
				if (!includeShape) {
					diagramNode.x=x;
					diagramNode.y=y;
					diagramNode.width =width;
					diagramNode.height=height;
				}
				var cornerRadius:Number=getNumber(node.@cornerRadius,0);
				
				if (color >=0)	diagramNode.graphics.beginFill(color);
				diagramNode.graphics.drawRoundRect(x-diagramNode.x,y-diagramNode.y,width-1,height-1,cornerRadius,cornerRadius);
				if (color >=0) diagramNode.graphics.endFill();
				
			}  else if (itemType ==	"circle") {
				var radius:Number=getNumber(node.@radius,-1);
				if (radius > 0) {
					x=((overrideX>=0)?overrideX:x)-radius;
					y=((overrideY>=0)?overrideY:y)-radius;
					width =(radius*2)+1;
					height=(radius*2)+1;
				} else {
					x=((overrideX>=0)?overrideX:x);
					y=((overrideY>=0)?overrideY:y);
					width =getNumber(node.@width,100);
					height=getNumber(node.@height,30);
				}
				if (!includeShape) {
					diagramNode.x=x;
					diagramNode.y=y;
					diagramNode.width =width;
					diagramNode.height=height;
				}
				
				if (color >=0)	diagramNode.graphics.beginFill(color);
				diagramNode.graphics.drawEllipse(x-diagramNode.x,y-diagramNode.y,width-1,height-1);
				if (color >=0) diagramNode.graphics.endFill();
				
			}  else if ((itemType == "polygon")||(itemType == "link")) {
				drawPolygon(node,diagramNode,overrideX,overrideY,includeShape,color,lineColor,lineThickness);
			} else if (itemType == "text") {
				var text:String=node.@text;
				if ((compositeNode!=null)&&(sourceNode!=null)) {
					var attr:XMLList=sourceNode.attribute(node.@shapeName);
					if (attr.length()>0)
						text=attr[0].toString();
				}
				var textArea:TextArea=new TextArea();
				x=((overrideX>=0)?overrideX:x);
				y=((overrideY>=0)?overrideY:y);
				width =getNumber(node.@width,100);
				height=getNumber(node.@height,30);
				if (!includeShape) {
					diagramNode.x=x;
					diagramNode.y=y;
					diagramNode.width =width;
					diagramNode.height=height;
				}
				diagramNode.addChild(textArea);
				textArea.x=x-diagramNode.x;
				textArea.y=y-diagramNode.y;
				textArea.width =width;
				textArea.height=height;
				textArea.addEventListener(MouseEvent.MOUSE_WHEEL,onMouseWheel);
				adjustCompRect(diagramNode,textArea);
				textArea.setStyle("fontWeight","bold");
				textArea.setStyle("height","");
				textArea.text=text;
				textArea.setStyle("backgroundAlpha","0");
				textArea.setStyle("borderStyle","none");
				textArea.wordWrap=true; 
				textArea.editable=false; 
				textArea.selectable=false; 
				textArea.enabled=false; 
				textArea.setStyle("disabledColor","0"); 
				textArea.setStyle("textAlign",getString(node.@xJustify,"center"));
				textArea.buttonMode=true;
				var tm:TextMetrics=new TextMetrics(textArea,textArea.text);
				textArea.height=tm.height;
				var vJustify:String=getString(node.@yJustify,"middle");	
				if 	(vJustify =="middle") {					
					textArea.y+=(height-tm.height)/2;
				} else if (vJustify =="bottom") {
					textArea.y+=(height-tm.height);
				}	
			} else if (itemType == "composite") {
				var compNode:XML=node;
				var firstShape:Boolean=true;
				diagramNode.graphics.clear();
				for each(var shape:XML in compNode.children()) {
					for (var e:int=0;e<shapes.length;e++) {
						if (shapes[e].style==shape.name()) {
							var adjX:Number=getNumber(shape.@x,0);
							var adjY:Number=getNumber(shape.@y,0);
							drawNode(diagramNode,x,y,shapes[e].node.name(),x+adjX,y+adjY,shapes[e].node,!firstShape,compNode,sourceNode);
							break;
						}
					}
					firstShape=false;
				}
			} 
			if ((diagramNode.selected)&&(itemType=="composite")&&(itemType!="link")) {
				diagramNode.graphics.lineStyle(2,0x80FF00);
				diagramNode.graphics.drawRect(-1,-1,diagramNode.width+1,diagramNode.height+1);
			} 
		}
		protected function addSymbols(symbols:XML):void {
			for each (var node:XML in symbols.elements.children()) {
				var shapeName:String=node.@shapeName;
				if ((shapeName != null) && (shapeName!="")) {
					shapes.push({style:shapeName,node:node});
				}
			}
		}
		public function addNewNode(x:Number,y:Number,shapeType:String):void {
			if (numChildren==0) {
				setStyle("width","");
				setStyle("height","");
			}
			var nodes:XMLList=dataProvider.elements;
			var newNode:XML;
			if (shapeType=="Input") {
				newNode=new XML(<input/>);
				newNode.@InText=shapeType;
			} else if (shapeType=="LookUp") {
				newNode=new XML(<lookup/>);
				newNode.@LookText=shapeType;
			} else if (shapeType=="Fee") {
				newNode=new XML(<fee/>);
				newNode.@FeeText=shapeType;
			} else if ((shapeType=="PrimaryService")||(shapeType=="SecondaryService")) {
				newNode=new XML(<service/>);
				newNode.@ServiceTitle=shapeType;
			} else {
				newNode=new XML(<gate/>);
				newNode.@GateType="";//shapeType.slice(0,shapeType.length-4);
			}
			newNode.@x=x;
			newNode.@y=y;
			newNode.@name=shapeType;
			newNode.@style=shapeType;	
			nodes.appendChild(newNode);
			createNode(newNode,false);
			modified=true;
		}
		public function redrawNode(diagramNode:NodeCanvas):void {
			var node:XML=diagramNode.node;
			var x:Number=getNumber(node.@x,0); 
			var y:Number=getNumber(node.@y,0); 
			
			var itemType:String=node.name();
			if (itemType != "link") {
				var style:String=node.@style;
				for (var e:int=0;e<shapes.length;e++) {
					if (shapes[e].style==style) {
						diagramNode.graphics.clear();
						drawNode(diagramNode,x,y,shapes[e].node.name(),x,y,shapes[e].node,false,null,node);
						break;
					}
				}
			} else {
				drawNode(diagramNode,x,y,itemType,-1,-1,node);
			}
		}
		public function createNode(node:XML,addToLinkList:Boolean=true):NodeCanvas {
			var diagramNode:NodeCanvas=new NodeCanvas(node,shapes,links);

			var x:Number=getNumber(node.@x,0); 
			var y:Number=getNumber(node.@y,0); 
			
			var itemType:String=node.name();
			if (itemType != "link") {
				var style:String=node.@style;
				for (var e:int=0;e<shapes.length;e++) {
					if (shapes[e].style==style) {
						drawNode(diagramNode,x,y,shapes[e].node.name(),x,y,shapes[e].node,false,null,node);
						break;
					}
				}
			} else {
				if (addToLinkList) links.push({fromNode:node.@from,toNode:node.@to,node:node,canvas:diagramNode});
				drawNode(diagramNode,x,y,itemType,-1,-1,node);
			}
			addChild(diagramNode);
			return diagramNode;
		}
		protected function addChildNodes(dataProvider:XML):void {
			for each (var node:XML in dataProvider.elements.children()) {
				createNode(node);
			}
		}
	}
}
	import flash.geom.Point;
	import flash.text.TextLineMetrics;
	import mx.core.UIComponent;
	import mx.containers.Canvas;
	import flash.events.MouseEvent;
	import mx.messaging.channels.StreamingAMFChannel;
	import com.proiam.CircuitDesigner;
	import mx.managers.CursorManager;
	import flash.display.DisplayObject;
	import mx.events.FlexMouseEvent;
	import mx.charts.CategoryAxis;
	import flash.external.ExternalInterface;
	import mx.effects.easing.Exponential;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.events.Event;
	import mx.utils.StringUtil;
	import mx.messaging.channels.StreamingHTTPChannel;
	import mx.collections.ArrayCollection;
	import flash.events.ErrorEvent;

class NodeCanvas extends Canvas {
 	public  var node:XML;
 	private var _shapes:Array=null;
 	private var _links:Array=null
	private var saveX:int=-1;
	private var saveY:int=-1;
	
	private var _selected:Boolean=false;
	public function set selected(value:Boolean):void {
		if (_selected!=value) {
			_selected=value;
		}
		CircuitDesigner(parent).redrawNode(this);
	}
	public function get selected():Boolean {
		return _selected;
	}
 	public function NodeCanvas(node:XML,shapes:Array=null,links:Array=null) {
 		super();
		addEventListener( MouseEvent.MOUSE_DOWN, doMouseDown );
		addEventListener( MouseEvent.MOUSE_UP, doMouseUp );
		addEventListener( MouseEvent.MOUSE_OVER, doMouseOver );
		addEventListener( MouseEvent.MOUSE_OUT, doMouseOut);
		addEventListener( MouseEvent.MOUSE_MOVE, doMouseMove);
		addEventListener( MouseEvent.MOUSE_WHEEL,doMouseWheel);
		verticalScrollPolicy="off";
		horizontalScrollPolicy="off";
		//buttonMode=true;
		setStyle("borderStyle","none");
		
		this.node=node;
		_shapes=shapes;
		_links=links;
		if (node!=null) {
			var nodeName:String=node.@name;
			if ((nodeName!=null)&&(nodeName!="")) {
				name=nodeName;
			} else {
				name="";
			}
		}
 	}
 	private function Within(a:Number,b:Number,plusMinus:Number):Boolean {
 		return Math.abs(a-b) <= plusMinus;
 	}
 	private function between(a:Number,b:Number,x:Number):Boolean {
 		return ((x>=a)&&(x<=b))||((x>=b)&&(x<=a));
 	}
 	public function highLightLink(localX:Number,localY:Number,highLight:Number):int {
		var listLen:int=node.children().length();
 		for (var i:int=0;i<listLen-1;i++) {
 			var fromNode:XML=node.children()[i];
 			var toNode:XML=node.children()[i+1];
 			var fromX:Number=fromNode.@x-x;
 			var fromY:Number=fromNode.@y-y;
 			var toX:Number=toNode.@x-x;
 			var toY:Number=toNode.@y-y;
 			  
 			if ((fromX==toX)&&(Within(localX,fromX,2))&&between(fromY,toY,localY)) {
 			//  vertical			AND  	on the line to within 2 pixels	AND		between the top and bottom ends of the line	
				CircuitDesigner(parent).drawPolygon(node,this,-1,-1,false,-1,0,2,highLight!=1,i);
				return i;
			} else if ((fromY==toY)&&(Within(localY,fromY,2))&&between(fromX,toX,localX)) {
			//  horizontal			AND  	on the line to within 2 pixels	AND		between the left and right ends of the line
				CircuitDesigner(parent).drawPolygon(node,this,-1,-1,false,-1,0,2,highLight!=1,i);
				return i;
 			}
 		}
 		return-1;
 	}
 	public function doMouseWheel( event:MouseEvent ):void {
 		CircuitDesigner(parent).onMouseWheel(event);
 	}
	public function doMouseOver( event:MouseEvent ):void {
		/*if ((CircuitDesigner(parent).selecting)&&(!event.buttonDown)) 
			highLight(0.5);*/
	}		
	public function doMouseOut( event:MouseEvent ):void {
		/*if ((CircuitDesigner(parent).selecting)&&(!event.buttonDown)) 
			highLight(1);*/
	}
	private var highlightedLinkSection:int=-1;
	public  function deleselectOthers(thanThis:NodeCanvas):Boolean {
		return CircuitDesigner(parent).setSelected(false,null,false,thanThis);
	}
	public function doMouseMove( event:MouseEvent ):void {
		if (highlightedLinkSection!=-1) {
			if (event.buttonDown) {
				trace("move "+event.localX+" "+event.localY);
				var newX:int=int(event.localX/5)*5;
				var newY:int=int(event.localY/5)*5;
				if ((saveX>=0)&&(saveY>=0)&&((saveX!=newX)||(saveY!=newY))) {
		 			var fromNode:XML=node.children()[highlightedLinkSection];
	 				var toNode:XML=node.children()[highlightedLinkSection+1];
	 				if (fromNode.@x==toNode.@x) {
						fromNode.@x=newX+x;
						toNode.@x=newX+x;
	 				} else {
						fromNode.@y=newY+y;
						toNode.@y=newY+y;
					}
					CircuitDesigner(parent).drawPolygon(node,this,-1,-1,false,-1,0,2,true,highlightedLinkSection);
				}
			}	
		}
	}
	public function doMouseDown( event:MouseEvent ):void {
		if (CircuitDesigner(parent).selecting) {
			var changed:Boolean=false;
			if (!(event.ctrlKey||event.shiftKey)) {
				changed=deleselectOthers(this);
			}
			if (changed) {
				selected=true; 
			} else {
				selected=!selected;				
			}
			CircuitDesigner(parent).addChild(CircuitDesigner(parent).removeChild(this));
			if (node.name() == "link") {
				saveX=int(event.localX/5)*5;
				saveY=int(event.localY/5)*5;
				//highLight(1);
				highlightedLinkSection=highLightLink(event.localX,event.localY,0.5);
			} else {
				saveX=int(x/5)*5;
				saveY=int(y/5)*5;
				//highLight(0.5);
				startDrag();
			}
		}
		//event.stopPropagation();
	}
	public function doMouseUp( event:MouseEvent ):void {
		if (CircuitDesigner(parent).selecting) {
			//selected=false;
			if (highlightedLinkSection!=-1) {
				trace("up "+event.localX+" "+event.localY);
				//highLight(0.9);
				highlightedLinkSection=-1;
				highLightLink(event.localX,event.localY,1);
		} else {
				stopDrag();
				if ((saveX>=0)&&(saveY>=0)) {
					var newX:Number=int(x/5)*5;
					var newY:Number=int(y/5)*5;
					if ((node.@x!=newX)||(node.@y!=newY)) CircuitDesigner(parent).modified=true;
		
					node.@x=newX;
					node.@y=newY;
					x=newX;
					y=newY;
					if ((_links !=null)&&(name!="")) {
						for (var i:int=0;i<_links.length;i++) {
							if ((_links[i].fromNode==name)||(_links[i].toNode==name)) 
								_links[i].canvas=movelink(_links[i].fromNode==name,_links[i].canvas,newX-saveX,newY-saveY);
						}
					}
					saveX=-1;
					saveY=-1;
				}
			}
			//highLight(1);
		}
		//event.stopPropagation();
	}		
	
	private function drawNotches(highLight:Boolean):void {
		CircuitDesigner(parent).drawPolygon(node,this,-1,-1,false,-1,0,2,highLight);
	}
	private function highLight(newAlpha:Number):void {
		if (alpha != newAlpha) {
			alpha=newAlpha;
			if (node.name()=="link") {
				if (alpha == 1) {
		 			drawNotches(false);
				} else {
		 			drawNotches(true);
				}
			} else  {
				for (var i:int=0;i<numChildren;i++) {
					getChildAt(i).alpha=alpha;
				}
			}
		}
	}
	private function getNumber(value:String,defaultValue:Number):Number {
		if ((value == null)||(value=="")) {
			return defaultValue;
		}
		return Number(value);
	}

	private function splitLine(node:XML,point1:Point,point2:Point):void {
		var Xpoint3:XML=new XML(<point/>);
		var Xpoint4:XML=new XML(<point/>);
		var midpoint:Number;
		
		if (point1.x!=point2.x) {
			midpoint=point1.x+((point2.x-point1.x)/2);
			node.children()[1].@x=midpoint;
			node.children()[1].@y=point1.y;
			Xpoint3.@x=midpoint;
			Xpoint3.@y=point2.y;
		} else {
			midpoint=point1.y+((point2.y-point1.y)/2);
			node.children()[1].@x=point1.x;
			node.children()[1].@y=midpoint;
			Xpoint3.@x=point2.x;
			Xpoint3.@y=midpoint;
		}
		Xpoint4.@x=point2.x;
		Xpoint4.@y=point2.y;
		node.appendChild(Xpoint3);
		node.appendChild(Xpoint4);
	}
	private function movelink(startOfLink:Boolean,nodeCanvas:NodeCanvas,deltaX:Number,deltaY:Number):NodeCanvas {
		var node:XML=nodeCanvas.node;
		var Xpoint1:XML;
		var Xpoint2:XML;
		var listLen:int=node.children().length();
		if (startOfLink) {
			Xpoint1=node.children()[0];
			Xpoint2=node.children()[1];
		} else {
			Xpoint1=node.children()[listLen-1];
			Xpoint2=node.children()[listLen-2];
		}
		var point1:Point=new Point;
		var point2:Point=new Point;
		point1.x=getNumber(Xpoint1.@x,0);
		point1.y=getNumber(Xpoint1.@y,0);
		point2.x=getNumber(Xpoint2.@x,0);
		point2.y=getNumber(Xpoint2.@y,0);
		// two point link needs to be split into a four point link?
		if ((listLen==2)&&(((point1.x!=point2.x)&&(deltaY!=0))||((point1.y!=point2.y)&&(deltaX!=0)))) {
			if (startOfLink)  // which way round
				splitLine(node,point1,point2);
			else
				splitLine(node,point2,point1);
			//	changed line, so refill the vars with new line details
			listLen=node.children().length();
			if (startOfLink) {
				Xpoint1=node.children()[0];
				Xpoint2=node.children()[1];
			} else {
				Xpoint1=node.children()[listLen-1];
				Xpoint2=node.children()[listLen-2];
			}
			point1.x=getNumber(Xpoint1.@x,0);
			point1.y=getNumber(Xpoint1.@y,0);
			point2.x=getNumber(Xpoint2.@x,0);
			point2.y=getNumber(Xpoint2.@y,0);
		} 
		if (point1.x!=point2.x) {
			Xpoint1.@x=point1.x+deltaX;
			Xpoint1.@y=point1.y+deltaY;
			Xpoint2.@y=point2.y+deltaY;
		} else { 
			Xpoint1.@x=point1.x+deltaX;
			Xpoint2.@x=point2.x+deltaX;
			Xpoint1.@y=point1.y+deltaY;
		} 
		return reCreateNode(nodeCanvas,false);
	}
	public function reCreateNode(nodeCanvas:NodeCanvas,addToLinkList:Boolean=true):NodeCanvas {
		var newNode:NodeCanvas=null;
		if (nodeCanvas.parent is CircuitDesigner) {
			var parentCanvas:CircuitDesigner=CircuitDesigner(nodeCanvas.parent);
			parentCanvas.removeChild(nodeCanvas);
			newNode=parentCanvas.createNode(nodeCanvas.node,addToLinkList);
		} 
		return newNode;
	}		
}	

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
class TriState {
	public static const TRUE:Object=true; 
	public static const FALSE:Object=false; 
	public static const UNDEFINED:Object=undefined;
	 
	private var state:Object=undefined;
	public function get value():Object { return state; }  
	public function set value(newValue:Object):void { state=newValue; }
	public function get NOT():TriState { 
		if (state is undefined) 
			return this; 
		else 
			return new TriState(!state); 
	}  
	public function AND(other:TriState):TriState { 
		if ((state is undefined)||other .state is undefined) 
			return new TriState(state); 
		else 
			return new TriState(state&&other.state); 
	}  
	public function OR(other:TriState):TriState { 
		if ((state is undefined)||other .state is undefined) 
			return new TriState(state); 
		else 
			return new TriState(state||other.state); 
	}  
	public function XOR(other:TriState):TriState { 
		if ((state is undefined)||other.state is undefined) 
			return new TriState(state); 
		else 
			return new TriState((state||other.state)&&(!(state&&other.state))); 
	}  
	public function NAND(other:TriState):TriState {
		return AND(other).NOT;
	}  
	public function NOR(other:TriState):TriState { 
		return OR(other).NOT;
	}  
	public function XNOR(other:TriState):TriState { 
		return XOR(other).NOT;
	}  
	//public function TriState() { state=undefined; }
	public function TriState(newValue:Object=undefined) { state=newValue; }
}
class ServiceDesignerGate extends TriState {
	protected var outputNode:Object=null;
	protected var inputNodes:Array=new Array();
	// returns true if lookup class initialized
	public function initialize(outnode:Object=null,inNodes:Array=null):Boolean {
		outputNode=outnode;
		inputNodes=inNodes;
		return true; 
	}
	// returns true if lookup class ready for use
	public function ready():Boolean { return true; }
	public function outputstate():TriState {
		return this; 
	}
}
class ServiceDesignerNotGate extends ServiceDesignerGate{
	override public function outputstate():TriState {
		if ((inputNodes!=null)&&(inputNodes.length>0)) {
			var inputnode:TriState = inputNodes[0];
			return inputnode.NOT; 
		}
		return new TriState(); 
	}
}
class ServiceDesignerANDGate extends ServiceDesignerGate{
	override public function outputstate():TriState {
		if ((inputNodes!=null)&&(inputNodes.length>1)) {
			var inputnode:TriState = inputNodes[0];
			for (var i:int=1;i<inputNodes.length;i++) {
				inputnode=inputnode.AND(inputNodes[i]);
				if (inputnode.value!=true) break;
			}
			return inputnode; 
		}
		return new TriState(); 
	}
}
class ServiceDesignerORGate extends ServiceDesignerGate{
	override public function outputstate():TriState {
		if ((inputNodes!=null)&&(inputNodes.length>1)) {
			var inputnode:TriState = inputNodes[0];
			for (var i:int=1;i<inputNodes.length;i++) {
				if (inputnode.value==true) break;
				inputnode=inputnode.OR(inputNodes[i]);
			}
			return inputnode; 
		}
		return new TriState(); 
	}
}
class ServiceDesignerOutput {
	protected var inputValue:String="";
	// returns true if lookup class initialized
	public function initialize(params:Array=null):Boolean { if (params.length>0) { inputValue=params[0]; } return true; }
	// returns true if lookup class ready for use
	public function ready():Boolean { return true; }
    public function get value():String { return inputValue; }
    public function set value(newValue:String):void { inputValue=newValue; }
}
class ServiceDesignerInput {
	protected var outputValue:String="";
	// returns true if lookup class initialized
	public function initialize(params:Array=null):Boolean { if (params.length>0) { outputValue=params[0]; } return true; }
	// returns true if lookup class ready for use
	public function ready():Boolean { return true; }
    public function get value():String { return outputValue; }
    public function set value(newval:String):void { outputValue=newval; }
}
class ServiceDesignerSizeItem {
	public var isInRange:Boolean=false; 		// current weight and dimensions are valid for thei type of item
	public var currentSize:Dimensions=null;	// last size passed to inRange
	public var currentWeight:Weight=null;		// last weight passed to inRange
	public var errorCondition:Error=null;			// details of any error causing invalid output
	
	// returns true if lookup class initialized
	public function initialize(params:Array=null):Boolean { return true; }
	// returns true if lookup class ready for use
	public function ready():Boolean { return true; }
	// returns true if valid size
	public function inRange(ItemSize:Dimensions=null,itemWeight:Weight=null):Boolean {
		try {
			currentSize=ItemSize;
			currentWeight=itemWeight;
			isInRange=true;
		} catch (error:Error) {
			isInRange=false;
			errorCondition=error;
		}
		return isInRange;		
	}
}
class ServiceDesignerLookup {
	public var hasValidInputs:Boolean=false; // current input values provide a valid output value
	public var outputValue:String="";				// output value defined by inputs (if hasValidInputs is true)
	public var currentRow:String="";				// last row passed to LookupValue
	public var currentColumn:String="";			// last column passed to LookupValue
	public var errorCondition:Error=null;			// details of any error causing invalid output

	// returns true if lookup class initialized
	public function initialize(params:Array=null):Boolean { return true; }
	// returns true if lookup class ready for use
	public function ready():Boolean { return true; }
	// returns true if valid inputs
	public function LookupValue(rowValue:String,columnValue:String=""):Boolean {
		try {
			currentRow			=rowValue;			// save rowValue
			currentColumn	=columnValue;	// save column value
			outputValue="";								// set output value
			hasValidInputs=true;						// set return = valid
		} catch (error:Error) {
			errorCondition=error;	
			hasValidInputs=false;
		}
		return hasValidInputs;		
	}
}

class CSVTariffLookup extends ServiceDesignerLookup { // Tariff Lookup
	public var filePath:String="tariffs/";
	public var fileName:String="tariff.csv";
	public var startRow:int=0;
	public var startColumn:int=0;
	public var titleRow:int=-1
	public var titleColumn:int=-1
	public var title:String="";
	public var minValue:Number=Number.MIN_VALUE;
	
	protected var lookupData:ArrayCollection=null;
	protected var headings:Array = new Array;
	protected var tariffLoaded:Boolean=false;

	
	override public function initialize(params:Array=null):Boolean {
		try {
			filePath=params[0];
			fileName=params[1];
			var smLoader:URLLoader = new URLLoader(); 
			smLoader.addEventListener(Event.COMPLETE,fileLoaded);
			smLoader.load(new URLRequest(filePath+fileName));
			hasValidInputs=true;
		} catch (error:Error) {
			errorCondition=error;
			hasValidInputs=false;
		}
		return hasValidInputs;		
	}
    protected function trimQuotes(str:String):String
    {
        var startIndex:int = 0;
        var endIndex:int = str.length - 1;
        while ((str.charAt(startIndex) == '"') || StringUtil.isWhitespace(str.charAt(startIndex)))  ++startIndex;
        while ((str.charAt(endIndex) == '"') || StringUtil.isWhitespace(str.charAt(endIndex)))  --endIndex;
        if (endIndex >= startIndex)
            return str.slice(startIndex, endIndex + 1);
        else
            return "";
    }
    protected function summary():String {
			var sumData:Array=new Array();
			sumData.push(["Column Name","Range"]);
			for (var i:int=0;i<headings.length;i++) { 
				if ((lookupData[0].length > i) &&(lookupData[lookupData.length-1].length > i)) { // some rows may not have as many columns as the headings row
					var lastLine:String=lookupData[lookupData.length-1][i];
					if (lastLine.toLowerCase()=="oversized") {
						lastLine=lookupData[lookupData.length-2][i]+' and Oversized';
					}
					sumData.push([trimQuotes(headings[i]),lookupData[0][i]+'-'+lastLine]);
				} else {
					sumData.push([trimQuotes(headings[i]),"No Data!"]);
				}
			}
    	return sumData.toString();
    }
	protected function fileLoaded(event:Event):void{
		try {
			var contents:String=event.target.data;
			var wholeCSV:Array = StringUtil.trim(contents).split("\r\n"); // get each line into array
			var params:Array = wholeCSV.slice(startRow); 						// get lines from startRow onwards  
			if (titleColumn>=0) {
				var titleData:Array=wholeCSV[titleRow].split(",");
				title=trimQuotes(titleData[titleColumn])+' ('+title+')'; 
			}
			for (var i:int=0;i <params.length;i++) {
				params[i]=params[i].split(",");						// convert each line to an array
				params[i]=params[i].slice(startColumn);		// remove coluns prior to startColumn
			}
			lookupData=new ArrayCollection(params.slice(1)); // we have our lookup table
			tariffLoaded=true;
			headings=params[0]; // first row is assumed to be headings
			
		}
		catch (error:Error) {
			errorCondition=error;
			hasValidInputs=false;
		}
	}
	// returns true if lookup class ready for use
	override public function ready():Boolean {
		return tariffLoaded;
	}
	// returns true if valid inputs
	override public function LookupValue(rowValue:String,columnValue:String=""):Boolean {
		try {
			super.LookupValue(rowValue,columnValue);
			var value:Number=Number(rowValue);
			
			hasValidInputs=false;
			outputValue="";
			if (value<minValue) {
				errorCondition=new Error("Underrange");
			} else {
				var i:int;
				var colIndex:int=1;
				if (columnValue!="") {
					for (i=0;i<headings.length;i++) {
						if (headings[i] == columnValue)  {
							colIndex=i;
							break;
						}
					}
				}
				for (i=0;i<lookupData.length;i++) {
					var rangeVal:Number = lookupData[i][0];
					if (rangeVal >= value) {
						if (lookupData[i].length <= colIndex) {
							errorCondition=new Error("Overrange");
							hasValidInputs=false;
						} else {
							outputValue=lookupData[i][colIndex];
							hasValidInputs=true;
						}
						break;		
					}
				}
			}
		} catch (error:Error) {
			errorCondition=error;
			hasValidInputs=false;
		}
		
		return hasValidInputs;		
	}
}
class CSVListLookup extends CSVTariffLookup { // Int Letter Lookup
	override public function LookupValue(rowValue:String,columnValue:String=""):Boolean {
		try {
			currentRow			=rowValue;			// save rowValue
			currentColumn	=columnValue;	// save column value
			
			hasValidInputs=false;
			outputValue="";
			var i:int;
			var colIndex:int=1;
			if (columnValue!="") {
				for (i=0;i<headings.length;i++) {
					if (headings[i] == columnValue)  {
						colIndex=i;
						break;
					}
				}
			}
			for (i=0;i<lookupData.length;i++) {
				if (String(lookupData[i][0]).toLowerCase() == rowValue.toLowerCase())  {
					if (lookupData[i].length <= colIndex) {
						errorCondition=new Error("Overrange");
						hasValidInputs=false;
					} else {
						outputValue=lookupData[i][colIndex];
						hasValidInputs=true;
					}
					break;		
				}
			}
		} catch (error:Error) {
			errorCondition=error;
			hasValidInputs=false;
		}
		
		return hasValidInputs;		
	}
}
class XMLCountryZoneLookup extends CSVTariffLookup { // Int Letter Lookup
    protected var intZoneList:Array=null;
	override protected function fileLoaded(event:Event):void{
        intZoneList=new Array();
		var intZoneData:XML=new XML(event.target.data);
        var xl:XMLList;
        xl=new XMLList(intZoneData.zones);
        for each(var zone:XML in xl.zone) {
			var countries:String=zone.@countries;
			var cList:Array=countries.split(",");
			for (var j:int=0;j<cList.length;j++)	cList[j]=StringUtil.trim(cList[j]).toUpperCase();
				
        	if (String(zone.@Name).length>0)
     			intZoneList.push({name:zone.@Name,countries:cList});
     		else
     			intZoneList.push({name:zone.@name,countries:cList});
     	}
	}
	override public function LookupValue(rowValue:String,columnValue:String=""):Boolean {
		try {
			currentRow			=rowValue;			// save rowValue
			currentColumn	=columnValue;	// save column value
			
			hasValidInputs=false;
			var country:String=rowValue.toUpperCase();
			outputValue="Unknown";
			
			for (var i:int=0;i<intZoneList.length;i++) {
				var zoneName:String=intZoneList[i].name;
				var cList:Array=intZoneList[i].countries;
				if (cList.indexOf(country) !=-1) {
					outputValue=zoneName;
					hasValidInputs=true;
					break;
				}
			}
		} catch (error:Error) {
			errorCondition=error;
			hasValidInputs=false;
		}
		return hasValidInputs;		
	}
}
class Dimension {
	private var _inMM:Number;
	private var _resultInInches:Boolean=false;
	public function get value():Number { return _resultInInches?_inMM/25.4:_inMM; }
	public function set value(newAmount:Number):void { _inMM=_resultInInches?newAmount*25.4:newAmount; }
	public function get inInches():Boolean { return _resultInInches; }
	public function set inInches(value:Boolean):void { _resultInInches=value; }
	public function Dimension(value:Number=0,inInches:Boolean=false) {
		_resultInInches=inInches;
		if (_resultInInches) 
			_inMM=value*25.4;
		else
			_inMM=value;
	}
}
class Dimensions {
	public var _height:Dimension;	
	public var _width:Dimension;	
	public var _thickness:Dimension;	
	private var _inInches:Boolean=false;
	public function get height():Number { return _height.value; } 
	public function set height(newAmount:Number):void { _height.value=newAmount; }
	public function get width():Number { return _height.value; }
	public function set width(newAmount:Number):void { _height.value=newAmount; }
	public function get thickness():Number { return _height.value; }
	public function set thickness(newAmount:Number):void { _height.value=newAmount; }
	public function get inInches():Boolean { return _inInches; }
	public function set inInches(value:Boolean):void { _inInches=value; }
	public function Dimensions(widthValue:Number=0,heightValue:Number=0,thicknessValue:Number=0,inInches:Boolean=false) {
		_inInches=inInches;
		_height=new Dimension(heightValue,_inInches);	
		_width=new Dimension(widthValue,_inInches);	
		_thickness=new Dimension(thicknessValue,_inInches);	
	}
}
class Weight {
	private var _weightInGrames:Number=0;
	public function valueOf():Number { return _weightInGrames; }
    public function toString():String { return valueOf().toPrecision(6); }
	public function Weight(value:Number) { _weightInGrames=value; }
}
class IsDomesticLookup extends ServiceDesignerLookup { // Is Domestic Lookup
	override public function LookupValue(rowValue:String,columnValue:String=""):Boolean {
		try {
			super.LookupValue(rowValue,columnValue);
			
			if ((rowValue=="USA")||(rowValue=="U.S.A.")||(rowValue=="United States")||(rowValue=="America")) { 
				hasValidInputs=true;
			} else {
				hasValidInputs=false;
			}
			
		} catch (error:Error) {
			errorCondition=error;
			hasValidInputs=false;
		}
		
		return hasValidInputs;		
	}
}
class IntLetterLookup extends CSVTariffLookup { // Int Letter Lookup
	override public function initialize(params:Array=null):Boolean {
		startRow=2;
		startColumn=0;
		titleRow=0;
		titleColumn=0;
		return super.initialize(["data/","GXG.csv"]);
	}
}
class IntZoneLookup extends XMLCountryZoneLookup { // Int Zone Lookup
	override public function initialize(params:Array=null):Boolean {
		startRow=2;
		startColumn=0;
		titleRow=0;
		titleColumn=0;
		return super.initialize(["data/","IntZones.xml"]);
	}
}
class WHTLimit extends ServiceDesignerSizeItem { // PostCard Input
	protected var minWidth:Number=Number.MIN_VALUE;
	protected var maxWidth:Number=Number.MAX_VALUE;
	protected var minHeight:Number=Number.MIN_VALUE;
	protected var maxHeight:Number=Number.MAX_VALUE;
	protected var minThickness:Number=Number.MIN_VALUE;
	protected var maxThickness:Number=Number.MAX_VALUE;
	protected var minWHRatio:Number=Number.MIN_VALUE;
	protected var maxWHRatio:Number=Number.MAX_VALUE;
	// returns true if lookup class initialized
	override public function initialize(params:Array=null):Boolean {
		if (params.length > 5) {
			minWidth			=params[0];
			maxWidth		=params[1];
			minHeight		=params[2];
			maxHeight		=params[3];
			minThickness	=params[4];
			maxThickness	=params[5];
			return true; 
		}
		return false; 
	}
	protected function setRanges(minW:Number,maxW:Number,minH:Number,maxH:Number,minT:Number,maxT:Number,minWH:Number,maxWH:Number):Boolean {
		minWidth			=minW;
		maxWidth		=maxW;
		minHeight		=minH;
		maxHeight		=maxH;
		minThickness	=minT;
		maxThickness	=maxT;
		minWHRatio	=minWH;
		maxWHRatio	=maxWH;
		return true; 
	}
	// returns true if lookup class ready for use
	override public function ready():Boolean { return true; }
	// returns true if valid size
	override public function inRange(itemSize:Dimensions=null,itemWeight:Weight=null):Boolean {
		try {
			isInRange=false;
			errorCondition=new Error("Invalid Size");
			if (itemSize!=null) {
				super.inRange(itemSize,itemWeight);
				if (	(itemSize.height			>= minHeight			)	&&	(itemSize.height			<= maxHeight		) 			
				&&	(itemSize.width			>= minWidth			)	&&	(itemSize.width			<= maxWidth			) 			
				&&	(itemSize.thickness		>= minThickness	)	&&	(itemSize.thickness		<= maxThickness	)  			
				&&	(itemSize.width			>= minWHRatio*itemSize.height	)	
				&&	(itemSize.width			<= maxWHRatio*itemSize.height	)		) {	
					isInRange=true;
				}
			}
		} catch (error:Error) {
			isInRange=false;
			errorCondition=error;
		}
		return isInRange;		
	}
}
class InchesWHTLimit extends WHTLimit { 
	override public function inRange(itemSize:Dimensions=null,itemWeight:Weight=null):Boolean {
		try {
			itemSize.inInches=true;
			isInRange=super.inRange(itemSize,itemWeight);
		} catch (error:Error) {
			isInRange=false;
			errorCondition=error;
		}
		return isInRange;		
	}
}
class PostCard extends InchesWHTLimit {
   public function PostCard():void { setRanges( 5.0, 6.0, 3.0, 4.25, 0.007, 0.016, 1.3, 2.5 ); }
}
class Letter extends InchesWHTLimit {
   public function Letter():void { setRanges( 5.0, 6.125, 3.0, 11.5, 0.016, 0.25, 1.3, 2.5 ); }
}
class Flat extends InchesWHTLimit {
   public function Flat ():void { setRanges( 5.0, 15.0, 3.0, 12.0, 0.016, 0.75, 1.3, 2.5 ); }
}
class OverUnder extends InchesWHTLimit {
   public function OverUnder():void { setRanges( 5.0, 15.0, 3.0, 12.0, 0.007, 0.75, 1.3, 2.5 ); }
   override public function inRange(itemSize:Dimensions=null,itemWeight:Weight=null):Boolean {
		try {
			isInRange=!super.inRange(itemSize,itemWeight);
		} catch (error:Error) {
			isInRange=false;
			errorCondition=error;
		}
		return isInRange;		
	}
}
class CountryInput extends ServiceDesignerInput {
    override public function get value():String { return "USA"; }
}
class WeightInput extends ServiceDesignerInput {
    override public function get value():String { return "10"; }
}
class StandardFeeOutput extends ServiceDesignerOutput {
//    override public function set value(newValue:String):void { StandardFee.text=newValue; }
}
class ORGate1 extends ServiceDesignerORGate {
}
class ANDGate1 extends ServiceDesignerANDGate {
}
class IntLetter /*extends ServiceDesignerService */{
	    public function IntLetter() {
	    	var postcard:PostCard=new PostCard(); 
	    	var letter:Letter=new Letter(); 
	    	var flat:Flat=new Flat(); 
	    	var countryInput:CountryInput=new CountryInput();
	    	var weightInput:WeightInput=new WeightInput();
	    	var orGate1:ORGate1=new ORGate1(); 
	    	var intZoneLookup:IntZoneLookup= new IntZoneLookup();
	    	var intLetterLookup:IntLetterLookup= new IntLetterLookup();
	    	var standardFeeOutput:StandardFeeOutput=new StandardFeeOutput();
	    	var andGate1:ANDGate1=new ANDGate1();
	    	orGate1.initialize(andGate1,[postcard,letter,flat]);
	    	andGate1.initialize(this,[orGate1,intZoneLookup,IntLetterLookup]); 
	    } 
}



