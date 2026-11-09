package com.cykorsystems.utils
{
	import mx.utils.StringUtil;
	
	public class Utils
	{
	    public static function trimNonAlpha(str:String):String {
    		var chars:Array=str.match(/[a-zA-Z]+/gi);
    		var s:String=(chars !=null?chars.join(""):"");
    		return s.toUpperCase();
	    }
	    public static function alphaCompare(strA:String,strB:String):Boolean {
			return trimNonAlpha(strA) == trimNonAlpha(strB);
	    }
	    public static function trimQuotes(str:String):String
	    {
	        var startIndex:int = 0;
	        while ((str.charAt(startIndex) == '"') || StringUtil.isWhitespace(str.charAt(startIndex)))
	            ++startIndex;
	
	        var endIndex:int = str.length - 1;
	        while ((str.charAt(endIndex) == '"') || StringUtil.isWhitespace(str.charAt(endIndex)))
	            --endIndex;
	
	        if (endIndex >= startIndex)
	            return str.slice(startIndex, endIndex + 1);
	        else
	            return "";
	    }
	}
}