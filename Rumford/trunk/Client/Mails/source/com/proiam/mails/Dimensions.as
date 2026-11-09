package com.proiam.mails
{
	public class Dimensions
	{
		private const MMPerInch:Number=25.4;
		private const CMPerInch:Number=2.54;
		
		public var length:Number=0;
		public var width:Number=0;
		public var height:Number=0;
		public var units:String="metric";
		public var hasData:Boolean=false;
		
		
		public function Dimensions(dimData:XML=null) {
			hasData=false;
			if (dimData != null) {
				if (dimData.hasOwnProperty("units"))  {
					units	=dimData.units;
					hasData=true;
				}
				if (dimData.hasOwnProperty("length")) {
					length	=dimData.length;
					hasData=true;
				}  
				if (dimData.hasOwnProperty("width")) {
					width	=dimData.width;
					hasData=true;
				}  
				if (dimData.hasOwnProperty("height")) {
					height	=dimData.height;
					hasData=true;
				}  
			}
		}
		private function inInches(value:Number):Number {
			if (units == "metric") {
				if (value <= 0.01) {
					return Math.round((value/CMPerInch)*1000)/1000;
				} else if (value <= 0.1) {
					return Math.round((value/CMPerInch)*100)/100;
				} else {
					return Math.round((value/CMPerInch)*10)/10;
				}
			} else {
				return value;
			}
			
		}
		public function inchesString():String {
			return inInches(length)+' x '+inInches(width)+' x '+inInches(height);
		}
		public function girthInInches():String {
			return String(Math.round((inInches(length)+inInches(width)*2+inInches(height)*2)*100)/100);
		}
		// calulates what the item is
		public function itemType(weightInOnces:Number):String {
			var itemLength		:Number=inInches(length);
			var itemWidth		:Number=inInches(width);
			var itemThickness:Number=inInches(height);
			
			if (itemThickness < 0.007) itemThickness=0.1; // device error
			 
			if ((itemLength < 5) || (itemWidth < 3.5) || (itemThickness< 0.007)) { 
				return "Undersize";
			}
			
			if ( (itemLength<=6) && (itemWidth<=4.25) && (itemThickness<=0.016) && (weightInOnces<=1) && (itemLength > (1.3*itemWidth) ) 
				 && (itemLength < (2.5*itemWidth)) ) {
				return "Postcard";
			}
			if ((itemLength <= 11.5) && (itemWidth <= 6.125) && (itemThickness <= 0.25) && (weightInOnces <=3.5)) {
				if ((itemLength > (1.3*itemWidth)) && (itemLength < (2.5*itemWidth))) {
					return "Letter";
				} else if (itemLength<(1.3*itemWidth)) {
					if ((itemLength < 5) || (itemWidth < 5)) {
						return "UndersizeSQ";
					}
					return "Square";
				}  
				return "Long";
			}
			if ((itemLength <= 15) && (itemWidth <= 12) && (itemThickness <= 0.75) && (weightInOnces <=13)) {
				if ((itemLength > (1.3*itemWidth)) && (itemLength < (2.5*itemWidth))) {
					return "Large Letter";
				} else if (itemLength<(1.3*itemWidth)) {
					return "Large Square";
				}  
				return "Large Long";
			} 
			if ( ((itemLength +itemWidth *2 +itemThickness *2) < 84) &&((itemLength*itemWidth*itemThickness) < (12*12*12)) 
				&& (weightInOnces <= 16*70)) {
				return "Package";
			}
			if (((itemLength +itemWidth *2 +itemThickness *2) < 130) && (weightInOnces <= 16*70)) {
				if (((itemLength +itemWidth *2 +itemThickness *2) >108) || (itemLength > 31) || (itemWidth > 17) || (itemThickness > 17)) {
					return "Oversize Parcel";
				}
				return "Parcel";				
			}
			return "Oversize";
		}
	}
}