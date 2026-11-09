package base {
	
	import mx.core.UIComponent;
	import flash.filters.DropShadowFilter;

	public class GradientRoundBaseSkin extends UIComponent	{
		
			import flash.display.Graphics;
			import flash.geom.Rectangle;
			import mx.graphics.GradientEntry;
			import mx.graphics.LinearGradient;
			  
			protected override function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void {
			   super.updateDisplayList(unscaledWidth,unscaledHeight);
				var w:Number = unscaledWidth;
				var h:Number = unscaledHeight;
				
				// hold the values of the gradients depending on button state
				var backgroundFillColor:Number;
				var backgroundFillColor2:Number;
				var backgroundFillColor3:Number;
				
				
				var fill:LinearGradient = new LinearGradient();
				
				// reference the graphics object of this skin class
				var g:Graphics = graphics;
				g.clear();				
				
				//	which skin is the button currently looking for? Which skin to use?
				switch (name) {
					case "upSkin":
						backgroundFillColor = 0x558DC6; //  //828EBC
						backgroundFillColor2 = 0x2963A2; // //485798
						break;
					case "overSkin":
						backgroundFillColor = 0x558DC6;
						backgroundFillColor2 = 0x2963A2;
						break;
					case "downSkin":
						backgroundFillColor = 0x2963A2;
						backgroundFillColor2 = 0x558DC6;
						color: 0xFF0000;
						break;
					case "disabledSkin":
						backgroundFillColor = 0x558DC6;
						backgroundFillColor2 = 0xD1E7D2;
						break;
				}				
				// depending on which state the button's in, we set our color for the 
				// gradients on the skin
				var g1:GradientEntry = new GradientEntry(backgroundFillColor,.10,100);
				var g2:GradientEntry = new GradientEntry(backgroundFillColor2,.60,100);
				  
				fill.entries = [g1,g2];
				fill.angle = 90;
				// fill the rectangle
				g.moveTo(0,0);
				fill.begin(g,new Rectangle(0,0,w,h));
				g.lineTo(w,0);
				g.lineTo(w,2*(h/3));
				g.curveTo(w,h,w-h/3,h);
				g.lineTo(h/3,h);
				g.curveTo(0,h,0,2*(h/3));
				g.lineTo(0,0);  
				fill.end(g);
				// if we're not showing the down skin, show the shadow. Otherwise hide it on the "down state" to look like it's being pressed
				if(name != "downSkin") {	            
		            filters = [new DropShadowFilter(4, 45,0x000000,.2)];
				}
			 }
	}
}