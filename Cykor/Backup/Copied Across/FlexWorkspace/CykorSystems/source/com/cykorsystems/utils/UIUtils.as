package com.cykorsystems.utils
{
	import mx.core.UIComponent;
	import mx.effects.Zoom;
	import mx.core.UITextField;
	import mx.controls.Text;
	import flash.display.BitmapData;
	import flash.geom.Matrix;
	import flash.utils.ByteArray;
	import flash.geom.Rectangle;
	
	public class UIUtils
	{
        static public function addExpand(toComponent:UIComponent,zoom:Number,duration:int):void {
            // Define a new Zoom effect.
            var zoomOver:Zoom = new Zoom();
            zoomOver.duration = duration; 
            zoomOver.zoomHeightTo = zoom; 
            zoomOver.zoomWidthTo = zoom; 
            var zoomOut:Zoom = new Zoom();
            zoomOut.duration =duration; 
            zoomOut.zoomHeightTo = 1; 
            zoomOut.zoomWidthTo = 1; 
            
            toComponent.setStyle("rollOverEffect", zoomOver); 
            toComponent.setStyle("rollOutEffect", zoomOut); 
        } 
		static public function drawText(container:UIComponent,xPos:Number,yPos:Number,outputText:String):void {
			var t:UITextField=new UITextField();
			t.text=outputText;
			t.validateNow();
			var texture:BitmapData = new BitmapData(t.width,t.height, true, 0x00000000 );
            texture.draw(t);
			container.graphics.beginBitmapFill(texture);
			container.graphics.drawRect(xPos,yPos,t.width,t.height);
			container.graphics.endFill();			
			t=null;
			texture=null;
		}
	    static public function drawComponent(source:UIComponent,dest:UIComponent,useScale:Boolean=true):void
	    {
            if ((source == null) || (dest == null)) return;

			var texture:BitmapData = new BitmapData(dest.width,dest.height, true, 0x00000000 );
			var matrix:Matrix;
			if (useScale) {
				matrix=new Matrix(dest.width/(source.width/source.scaleX),0,0,dest.height/(source.height/source.scaleY));
			} else {
				matrix=new Matrix(dest.width/source.width,0,0,dest.height/source.height);
			}
            texture.draw(source,matrix);
			dest.graphics.clear();
			dest.graphics.beginBitmapFill(texture);
			dest.graphics.drawRect(0,0,dest.width,dest.height);
			dest.graphics.endFill();			
			texture=null;	
	    }
	    public static function clone(source:ByteArray):ByteArray {
		    var myBA:ByteArray = new ByteArray();
		    myBA.writeBytes(source,0,source.length);
		    myBA.position= 0;
		    return(myBA);
		}

		public static function bitmapDataToByteArray(bmpData:BitmapData):ByteArray {
			var binaryImage:ByteArray=new ByteArray();
			var bmpWidth:int=bmpData.width;
			var bmpHeight:int=bmpData.height;

			binaryImage.writeUnsignedInt(bmpWidth);
			binaryImage.writeUnsignedInt(bmpHeight);
			binaryImage.writeObject(bmpData.getPixels(new Rectangle(0,0,bmpWidth,bmpHeight)));
//			for (var i:uint=0;i<bmpWidth;i++) {
//				for (var j:uint=0;j<bmpHeight;j++) {
//					binaryImage.writeUnsignedInt(bmpData.getPixel32(i,j));
//				}
//			}
			binaryImage.compress();
			return binaryImage;
		}	    		
		public static function byteArrayToBitmapData(binaryImage:ByteArray):BitmapData {
			binaryImage=clone(binaryImage);
			binaryImage.uncompress();
			var bmpWidth:int=binaryImage.readUnsignedInt();
			var bmpHeight:int=binaryImage.readUnsignedInt();
			var bmpData:BitmapData=new BitmapData(bmpWidth,bmpHeight);
			bmpData.setPixels(new Rectangle(0,0,bmpWidth,bmpHeight),binaryImage);

//			for (var i:uint=0;i<bmpWidth;i++) {
//				for (var j:uint=0;j<bmpHeight;j++) {
//					bmpData.setPixel32(i,j,binaryImage.readUnsignedInt());
//				}
//			}
			return bmpData;
		}	    		
	}
}