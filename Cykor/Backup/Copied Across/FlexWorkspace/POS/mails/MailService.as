package mails
{
	import flash.xml.XMLNode;
   	import mx.utils.StringUtil;
   	import mx.collections.ArrayCollection;
   	import flash.utils.ByteArray;
   	import flash.utils.Endian;
	
	public class MailService extends Object 
	{
	    [Embed(source="../resources/ServiceLevels.zlib", mimeType="application/octet-stream")]
	     private var SLevelsClass:Class;
	    [Embed(source="../resources/Cities.zlib", mimeType="application/octet-stream")]
	     private var CitiesClass:Class;
	     private var allServiceLevels:ByteArray = new ByteArray;
	     private var serviceTypes:Array;
	     private var cities:Array = new Array;

	    private function loadZipData():void {
	        var binData:ByteArray = new SLevelsClass() as ByteArray;
	        binData.uncompress();
	        binData.endian=Endian.LITTLE_ENDIAN;
	        var s:String;
	        var len:int;
	        len=binData.readInt();
	        s=binData.readMultiByte(len,"utf-8");
	        serviceTypes= s.split(",");
	        for (var i:int=0;i<1000;i++) {
	        	var ba:ByteArray = new ByteArray();
	        	binData.readBytes(allServiceLevels,i*1000,i+1);
	        }
	        binData= new CitiesClass() as ByteArray;
	        binData.uncompress();
	        s=binData.toString();
	        var list:Array=s.split("\r\n");
	        for (i=0;i<list.length;i++) {
	        	if (list[i].length == 2) {
	        		var state:String = list[i];
	        	} else {
	        		var zips:Array = list[i].split(',');
	        		var city:String =zips[zips.length-1];
	 		       	city=city.substr(1,city.length-2);
	 		       	for (var z:int =0;z<zips.length-1;z++) {
	 		       		var zip:int =int(zips[z]);
	 		       		cities[zip]=city+','+state;
	 		       	}
	        	}
	        }
	    }
	    public function lookUpCity(zipCode:String):String
	    {
	    	var result:String="Invalid";
	    	if (cities[int(zipCode)] != null) {
	    		result=cities[int(zipCode)];
	    	}	
	    	return(result);
	    }
	    public function lookupServiceLevels(zipA:int,zipB:int):String
	    {
	    	var serviceIndex:int;
	    	var result:String="*****";
	    	zipA=zipA / 100;
	    	zipB=zipB / 100;
	    	if (zipA > zipB) {
	    		serviceIndex=allServiceLevels[zipA*1000+zipB];
	    	} else {
	    		serviceIndex=allServiceLevels[zipB*1000+zipA];
	    	}
	    	serviceIndex--;
	    	if (serviceIndex < serviceTypes.length) {
	    		result=serviceTypes[serviceIndex];
	    	}
	    	return(result);
	    }
		public function MailService()
		{
			ArrayCollection
			super();
			loadZipData();
		}
		public function availableServices(weight:Weight,source:String,destination:String):XML
		{
			var result:XML = <AvailableServices/>;

			result.Weight.@InGrams		=weight.weightInGrams.toString();	
			result.Weight.@InPounds	=weight.weightInPounds.toString();	
			result.Weight.@InOunces	=weight.weightInOunces.toString();	
			result.Weight.@InLbOz		=weight.weightInLbOz.toString();	
			result.Weight.@AsText		=weight.toString();	
			result.Source.@Zip=source;	
			result.Source.@City=lookUpCity(source)
			result.Destination.@Zip=destination;	
			result.Destination.@City=lookUpCity(destination)
			var serviceType:String=lookupServiceLevels(int(source),int(destination));	
			result.ServiceLevels.First="First Class Mail";
			result.ServiceLevels.First.@Days=serviceType.substr(1,1);
			result.ServiceLevels.PckgSvcs="Packages";
			result.ServiceLevels.PckgSvcs.@Days=serviceType.substr(2,1);
			result.ServiceLevels.Priority="Priority Mail";
			result.ServiceLevels.Priority.@Days=serviceType.substr(3,1);
			result.Zone=serviceType.substr(4,1);
	   		if (serviceType.substr(5,1) == "1") 
	   		{
				result.Zone.@ViaBMC="true"
	   		} else {
				result.Zone.@ViaBMC="false"
	   		}
			return (result);
		}
	}
}