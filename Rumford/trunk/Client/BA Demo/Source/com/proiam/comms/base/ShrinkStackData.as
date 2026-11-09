package com.proiam.base
{
	import com.proiam.slides.OneDayBase;
	
	public class ShrinkStackData
	{
		public var selectedServices	:Array=new Array;
		public var selectedProduct:OneDayBase=null;
		public function ShrinkStackData(sp:OneDayBase,ss:Array) {
			selectedProduct=sp;
			for (var i:int=0;i<ss.length;i++) selectedServices.push(ss[i]);
		}
	}
}