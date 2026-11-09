package mails
{
	import mx.formatters.NumberBase;
	
	public class Weight extends Object implements IWeight
	{

		/* -----------------------------------------------------------------------------
		IMPORTED CLASSES
		----------------------------------------------------------------------------- */
		import mails.WeightType;
		
		/* -----------------------------------------------------------------------------
		Meta Data
		----------------------------------------------------------------------------- */
		[DefaultProperty("weight")]

		/* -----------------------------------------------------------------------------
		Internal Constants
		----------------------------------------------------------------------------- */
		private const gramsPerOunce:Number		= 28.35;
		private const ouncesPerPound:Number	= 16;
		private const gramsPerPound:Number		= gramsPerOunce*ouncesPerPound;

		/* -----------------------------------------------------------------------------
		Internal Variables
		----------------------------------------------------------------------------- */
		private var _weightInGrams:Number		= 0;
		private var _outputType:WeightType		= WeightType.GRAMS;

		/* -----------------------------------------------------------------------------
		Attributes
		----------------------------------------------------------------------------- */
		public function get weightInGrams():Number {
		    return numDPlace(_weightInGrams,2);
		}
		public function set weightInGrams(value:Number):void {
		    _weightInGrams=value;
		}
		public function get weightInOunces():Number {
			return numDPlace(_weightInGrams/gramsPerOunce,2);
		}
		public function set weightInOunces(value:Number):void {
		    weightInGrams=value*gramsPerOunce;
		}
		public function get weightInPounds():Number {
			return numDPlace(_weightInGrams/gramsPerPound,4);
		}
		public function set weightInPounds(value:Number):void {
		    weightInGrams=value*gramsPerPound;
		}
		public function get weightInLbOz():Number {
			var ounces:Number = weightInOunces;
			var pounds:Number = Math.floor(ounces/ouncesPerPound);
			ounces-=pounds*ouncesPerPound;
		    return numDPlace(pounds+(ounces/100),4);
		}
		public function set weightInLbOz(value:Number):void {
			var pounds:Number = Math.floor(value); // pounds in the whole part
			var ounces:Number = (value-pounds)*100; // ounces / 100 in the fraction
		    weightInGrams=(pounds*ouncesPerPound)+ounces;
		}
		public function get outputType():WeightType {
		    return _outputType;
		}
		public function set outputType(weightType:WeightType):void {
		    _outputType=weightType;
		}
		public function get weight():Number {
			switch (_outputType) {
				case WeightType.OUNCES	: return weightInOunces;
				case WeightType.POUNDS	: return weightInPounds;
				case WeightType.LBOZ		: return weightInLbOz;
				default 									: return weightInGrams;
			}
		}
		public function set weight(weightAmount:Number):void {
			switch (_outputType) {
				case WeightType.OUNCES	: weightInOunces	=weightAmount; break;
				case WeightType.POUNDS	: weightInPounds	=weightAmount; break;
				case WeightType.LBOZ		: weightInLbOz		=weightAmount; break;
				default 									: weightInGrams	=weightAmount; break;
			}
		}
		public function get lbOzString():String {
			var ounces:Number = weightInOunces;
			var pounds:Number = Math.floor(ounces/ouncesPerPound);
			ounces-=pounds*ouncesPerPound;
		    return pounds.toString()+'lb '+numDPlace(ounces,2).toString()+'oz';
		}
		/* -----------------------------------------------------------------------------
		Methods
		----------------------------------------------------------------------------- */
		public function Weight(weightAmount:Number =0,asType:WeightType=null):void
		{
			super();
			if (asType != null) 
				outputType=asType;
			weight=weightAmount;
		}
		private function numDPlace(val:Number,digits:int):Number
		{
			var result:Number=val*Math.pow(10,digits) ;
			result=Math.round(result);
			result/=Math.pow(10,digits);
			return result;
		}
		public function toString(asType:WeightType=null):String {
			if (asType == null) asType=_outputType;
			switch (asType) {
				case WeightType.OUNCES	: return weightInOunces.toString();
				case WeightType.POUNDS	: return weightInPounds.toString();
				case WeightType.LBOZ		: return lbOzString;
				default 									: return weightInGrams.toString();
			}
		}
	}
}
