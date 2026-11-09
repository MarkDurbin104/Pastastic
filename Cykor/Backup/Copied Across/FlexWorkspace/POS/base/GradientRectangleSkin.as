package base {
	
	import mx.core.UIComponent;
	import flash.filters.DropShadowFilter;

	public class GradientRectangleSkin extends UIComponent	{
		
		import flash.display.Graphics;
		import flash.geom.Rectangle;
		import mx.graphics.GradientEntry;
		import mx.graphics.LinearGradient;
		  
		protected override function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void 
		{
		   super.updateDisplayList(unscaledWidth,unscaledHeight);
			var w:Number = unscaledWidth;
			var h:Number = unscaledHeight;
			
			// hold the values of the gradients depending on button state
			var backgroundFillColor1:Number = getStyle("fillColorA"); //fillColor1:#FFF2D1;
			var backgroundFillColor2:Number = getStyle("fillColorB"); //fillColor2:#FDE07C;
			var backgroundFillColor3:Number = getStyle("fillColorC"); //fillColor1:#FFF2D1;
			var backgroundFillColor4:Number = getStyle("fillColorD"); //fillColor2:#FDE07C;

			var cornerRadius:Number = getStyle("cornerRadius");
			var gradiantAngle:Number = getStyle("gradiantAngle");
			var highlightAngle:Number = getStyle("highlightAngle");
			
			var fill:LinearGradient = new LinearGradient();
			
			var g:Graphics = graphics;
			g.clear();				

			var g1:GradientEntry = new GradientEntry(getStyle("fillColorET"),0,100);
			var g2:GradientEntry = new GradientEntry(getStyle("fillColorEB"),1,100);

			fill.entries = [g1,g2]; fill.angle = highlightAngle;
			fill.begin(g,new Rectangle(x,y,w,h));
			var offset:Number=0;
			g.drawRoundRect(x+offset,y+offset,w-(offset*2),h-(offset*2),cornerRadius-(offset/2),cornerRadius-(offset/2));
			fill.end(g);
			
			g1.color=getStyle("fillColorBT");
			g2.color=getStyle("fillColorBB");
			fill.entries = [g1,g2]; fill.angle = gradiantAngle;
			fill.begin(g,new Rectangle(x,y,w,h));
			offset+=getStyle("outerEdge");;
			g.drawRoundRect(x+offset,y+offset,w-(offset*2),h-(offset*2),cornerRadius-(offset/2),cornerRadius-(offset/2));
			fill.end(g);
			
			g1.color=getStyle("fillColorET");
			g2.color=getStyle("fillColorEB");
			fill.entries = [g1,g2]; fill.angle = highlightAngle+180;
			fill.begin(g,new Rectangle(x,y,w,h));
			offset+=getStyle("borderThickness");
			g.drawRoundRect(x+offset,y+offset,w-(offset*2),h-(offset*2),cornerRadius-(offset/2),cornerRadius-(offset/2));
			fill.end(g);

			g1.color=getStyle("fillColorIT");
			g2.color=getStyle("fillColorIB");
			g1.ratio=getStyle("innerStart");
			g2.ratio=getStyle("innerEnd");
			fill.entries = [g1,g2];  fill.angle = gradiantAngle;
			fill.begin(g,new Rectangle(x,y,w,h));
			offset+=getStyle("innerEdge");
			g.drawRoundRect(x+offset,y+offset,w-(offset*2),h-(offset*2),cornerRadius-(offset/2),cornerRadius-(offset/2));
			fill.end(g);
			
// 			if(name != "downSkin")
	            filters = [new DropShadowFilter(4, 45,0x000000,.2)];
	 	}
	}
}