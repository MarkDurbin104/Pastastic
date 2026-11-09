package com.proiam.mails
{
	public class Dimensions
	{
		private const MMPerInch:Number=25.4;
		private const CMPerInch:Number=2.54;
		
		public var length:Number;
		public var width:Number;
		public var height:Number;
		public var units:String;
		
		public function Dimensions(dimData:XML=null) {
			if (dimData != null) {
				units	=dimData.units;
				length	=dimData.length;
				width	=dimData.width;
				height	=dimData.height;
				var swap:Number;
				if (width > length) { //length longest
					swap=length;
					length=width;
					width=swap;
				}
				if (height > length) {// then width
					swap=length;
					length=height;
					height=swap;
				}
				if (height > width) { //then height
					swap=width;
					width=height;
					height=swap;
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
		public function itemType(weight:Number):String {
			var len:Number=inInches(length);
			var wid:Number=inInches(width);
			var hgt:Number=inInches(height);
			if (len < 5) return "Undersize";
			if (wid < 3.5) return "Undersize";
			if (hgt< 0.007) return "Undersize";
			if ((len<=6)&&(wid<=4.25)&&(hgt<=0.016)&&(weight<=1) && (len > (1.3*wid)) && (len < (2.5*wid))) {
				return "Postcard";
			}
			if ((len <= 11.5) && (wid <= 6.125) && (hgt <= 0.25) && (weight <=3.5)) {
				if ((len > (1.3*wid)) && (len < (2.5*wid))) {
					return "Letter";
				} else if (len<(1.3*wid)) {
					if ((len < 5) || (wid < 5)) {
						return "UndersizeSQ";
					}
					return "Square";
				}  
				return "Long";
			}
			if ((len <= 15) && (wid <= 12) && (hgt <= 0.75) && (weight <=13)) {
				if ((len > (1.3*wid)) && (len < (2.5*wid))) {
					return "Large Letter";
				} else if (len<(1.3*wid)) {
					return "Large Square";
				}  
				return "Large Long";
			} 
			if (((len +wid *2 +hgt *2) < 84) &&((len*wid*hgt) < (12*12*12)) && (weight <= 16*70)) {
				return "Package";
			}
			if (((len +wid *2 +hgt *2) < 130) && (weight <= 16*70)) {
				if (((len +wid *2 +hgt *2) >108) || (len > 31) || (wid > 17) || (hgt > 17)) {
					return "Oversize Parcel";
				}
				return "Parcel";				
			}
			return "Oversize";
		}
	}
}