package {
	[SWF(width="400", height="300")]
	import flash.display.Sprite;

	public class logo2 extends Sprite
	{
		private var points:Array=new Array;
		private var r:Number;
		private var degRad:Number=Math.PI/180;
		private function drawPoly(a:int,b:int,c:int,d:int,col:uint):void {
			with (graphics) {
				lineStyle(r/10,0xFFFFFF);
				beginFill(col,1);
				moveTo(points[a].x,points[a].y);
				lineTo(points[b].x,points[b].y);
				lineTo(points[c].x,points[c].y);
				lineTo(points[d].x,points[d].y);
				lineTo(points[a].x,points[a].y);
				endFill();
				//miniPoly(a,b,c,d,col);
				trace("Polygon("+points[a].x+","+points[a].y+","+points[b].x+","+points[b].y+","+points[c].x+","+points[c].y+","+points[d].x+","+points[d].y+",#"+col.toString(16)+")");
			}
		}		
		private function miniPoly(a:int,b:int,c:int,d:int,col:uint):void {
			with (graphics) {
				lineStyle(3,0xFFFFFF);
				beginFill(col,1);
				var scaler:Number=3;
				//lineStyle(r/40,0xFFFFFF);
				moveTo(points[a].x/scaler,points[a].y/scaler);
				lineTo(points[b].x/scaler,points[b].y/scaler);
				lineTo(points[c].x/scaler,points[c].y/scaler);
				lineTo(points[d].x/scaler,points[d].y/scaler);
				lineTo(points[a].x/scaler,points[a].y/scaler);
				endFill();
			}
		}		
		private function drawKrozYR(x:Number,y:Number,r:Number,angle:Number):void {
			var points:Array=new Array;
			with (graphics) {
				for (var i:int=0;i<360;i+=90) {
					var xp:Number=x+r*Math.sin((i+angle)*degRad);
					var yp:Number=y-r*Math.cos((i+angle)*degRad);
					points.push({x:xp,y:yp});
				}
				graphics.lineStyle(1,0);
				moveTo(points[0].x,points[0].y);
				lineTo(points[2].x,points[2].y);
				moveTo(points[1].x,points[1].y);
				lineTo(points[3].x,points[3].y);
			}
		}
		public function logo2():void {
			x=0;
			y=0;
			//width=stage.stageWidth;
			//height=stage.stageWidth;
			/*with (graphics) {
				trace("stagewidth"+stage.stageWidth);
				lineStyle(1,0xFFFFFF);
				beginFill(0xFFFFFF,1);
				drawRect(0,0,stage.stageWidth,stage.stageHeight);
				endFill();
			}*/


			r=20;
			var x:Number=100;
			var y:Number=100;
			//points.push({x:x,y:y});
			for (var i:int=0;i<360;i+=60) {
				var xp:Number=x+r*2*Math.sin(i*degRad);
				var yp:Number=y-r*2*Math.cos(i*degRad);
				points.push({x:xp,y:yp});
			}
//			drawPoly(0,6,1,2,0x406488);
//			drawPoly(0,2,3,4,0x678EB7);
//			drawPoly(0,4,5,6,0xB4C8DC);
//			drawPoly(6,1,2,7,0x678EB7);
//			drawPoly(2,3,4,8,0xB4C8DC);
//			drawPoly(4,5,6,9,0x406488);
			//r/=2;
			//for (i=0;i<6;i++) {
			i=0;
				graphics.lineStyle(2,0);
				graphics.drawCircle(points[i].x,points[i].y,r);
				drawKrozYR(points[i].x,points[i].y,r*2,i*60);
			//}
			
		}
		public function logo3():void {
			x=0;
			y=0;
			//width=stage.stageWidth;
			//height=stage.stageWidth;
//			with (graphics) {
//				trace("stagewidth"+stage.stageWidth);
//				lineStyle(1,0xFFFFFF);
//				beginFill(0xFFFFFF,1);
//				drawRect(0,0,stage.stageWidth,stage.stageHeight);
//				endFill();
//			}

			var degRad:Number=Math.PI/180;

/*			r=Math.min(stage.stageHeight,stage.stageWidth)/10;
			var x:Number=stage.stageWidth/2;
			var y:Number=(stage.stageHeight/2)+r;
/*			r=stage.height/10;
			var x:Number=stage.width/2;
			var y:Number=(stage.height/2)+r;*/
			r=20;
			var x:Number=100;
			var y:Number=110;
			points.push({x:x,y:y});
			for (var i:int=0;i<360;i+=60) {
				var xp:Number=x+r*2*Math.sin(i*degRad);
				var yp:Number=y-r*2*Math.cos(i*degRad);
				points.push({x:xp,y:yp});
			}
			for (i=0;i<360;i+=120) {
				xp=x+r*4*Math.sin(i*degRad);
				yp=y-r*4*Math.cos(i*degRad);
				points.push({x:xp,y:yp});
			}
			
			for (i=0;i<10;i++) {
				points[i].x=Math.round(points[i].x);
				points[i].y=Math.round(points[i].y);
			}
			drawPoly(0,6,1,2,0x406488);
			drawPoly(0,2,3,4,0x678EB7);
			drawPoly(0,4,5,6,0xB4C8DC);
			drawPoly(6,1,2,7,0x678EB7);
			drawPoly(2,3,4,8,0xB4C8DC);
			drawPoly(4,5,6,9,0x406488);

/*			graphics.lineStyle(2,0);
			for (i=0;i<10;i++) {
				graphics.drawCircle(points[i].x,points[i].y,r);
			}*/
			
			/*bg.graphics.moveTo(points[6].x,points[6].y);
			for (i=0;i<6;i++) bg.graphics.lineTo(points[i+1].x,points[i+1].y);
			bg.graphics.moveTo(points[6].x,points[6].y);
			bg.graphics.lineTo(points[0].x,points[0].y);
			bg.graphics.moveTo(points[4].x,points[4].y);
			bg.graphics.lineTo(points[0].x,points[0].y);
			bg.graphics.moveTo(points[2].x,points[2].y);
			bg.graphics.lineTo(points[0].x,points[0].y);
			bg.graphics.moveTo(points[9].x,points[9].y);
			for (i=0;i<3;i++) bg.graphics.lineTo(points[i+7].x,points[i+7].y);*/
//			bg.graphics.drawRect(100,100,800,700);
		}
	}
}
