package com.proiam.mails
{
	public interface IWeight
	{
		/* -----------------------------------------------------------------------------
		properties
		----------------------------------------------------------------------------- */
		// weightInGrams:Number
		function get weightInGrams():Number;
		function set weightInGrams(value:Number):void;
		// weightInOunces:Number
		function get weightInOunces():Number;
		function set weightInOunces(value:Number):void;
		// weightInPounds:Number
		function get weightInPounds():Number;
		function set weightInPounds(value:Number):void;
		// weightInLbOz:Number
		function get weightInLbOz():Number;
		function set weightInLbOz(value:Number):void;
		// outputType:WeightType
		function get outputType():WeightType;
		function set outputType(weightType:WeightType):void;
		// weight:Number
		function get weight():Number;
		function set weight(weightAmount:Number):void;
		// lbOzString:String - readonly
		function get lbOzString():String;
		/* -----------------------------------------------------------------------------
		Methods
		----------------------------------------------------------------------------- */
		function toString(asType:WeightType=null):String;
	}
}