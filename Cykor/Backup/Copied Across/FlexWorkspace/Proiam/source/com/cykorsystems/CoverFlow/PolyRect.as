package com.cykorsystems.CoverFlow
{
	import flash.geom.Rectangle;
	import flash.geom.Point;
	
	public class PolyRect
	{
		public var cornerTL:Point=new Point();
		public var cornerTR:Point=new Point();
		public var cornerBL:Point=new Point();
		public var cornerBR:Point=new Point();
		public function PolyRect(rect:Rectangle):void
		{
			cornerTL.x=rect.top;
			cornerTL.y=rect.left;
			cornerTR.x=rect.right;
			cornerTR.y=rect.top;
			cornerBL.x=rect.left;
			cornerBL.y=rect.bottom;
			cornerBR.x=rect.right;
			cornerBR.y=rect.bottom;
		}
		public function moveBy(byPoint:Point):void
		{
			cornerTL.x+=byPoint.x;
			cornerTL.y+=byPoint.y;
			cornerTR.x+=byPoint.x;
			cornerTR.y+=byPoint.y;
			cornerBL.x+=byPoint.x;
			cornerBL.y+=byPoint.y;
			cornerBR.x+=byPoint.x;
			cornerBR.y+=byPoint.y;
		}
		public function scaleBy(byPoint:Point):void
		{
			var leftHeight:Number=cornerBL.y-cornerTL.y;
			var rightHeight:Number=cornerBR.y-cornerTR.y;
			var topWidth:Number=cornerTR.x-cornerTL.x;
			var bottomWidth:Number=cornerBR.x-cornerBL.x;
			var leftAdj:Number=(leftHeight-(leftHeight*byPoint.y))/2;
			var rightAdj:Number=(rightHeight-(rightHeight*byPoint.y))/2;
			var topAdj:Number=(topWidth-(topWidth*byPoint.x))/2;
			var bottomAdj:Number=(bottomWidth-(bottomWidth*byPoint.x))/2;
			
			cornerTL.x+=topAdj;
			cornerTL.y+=leftAdj;
			cornerTR.x-=topAdj;
			cornerTR.y+=rightAdj;
			cornerBL.x+=bottomAdj;
			cornerBL.y-=leftAdj;
			cornerBR.x-=bottomAdj;
			cornerBR.y-=rightAdj;
		}
		private function rotateYPoint(origin:Point,angleZ:Number,aboutPoint:Point):void {
			var x:Number=origin.x-aboutPoint.x;
			var y:Number=origin.y-aboutPoint.y;
			var dx:Number=x-(x*Math.cos(angleZ*(Math.PI/180)));
			var dz:Number=(x*Math.sin(0-angleZ*(Math.PI/180)));
			var vanishingPoint:Number=1500;
			var theta:Number=Math.atan2(origin.y,vanishingPoint);
			var dy:Number=origin.y-((vanishingPoint-dz)*Math.tan(theta));
			origin.x-=dx;
			if (origin.y < aboutPoint.y)
				origin.y+=dy*3/4;
			else 
				origin.y-=dy*1/4;
		}
		public function rotateYBy(angleZ:Number,aboutPoint:Point):void {
			rotateYPoint(cornerTL,angleZ,aboutPoint);
			rotateYPoint(cornerTR,angleZ,aboutPoint);
			rotateYPoint(cornerBL,angleZ,aboutPoint);
			rotateYPoint(cornerBR,angleZ,aboutPoint);
		}
	}
}