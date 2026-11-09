package com.proiam.mails
{
	import flash.xml.XMLNode;
   	import mx.utils.StringUtil;
   	import mx.collections.ArrayCollection;
   	import flash.utils.ByteArray;
   	import flash.utils.Endian;
   	import flash.events.Event;
   	import flash.events.EventDispatcher;
   	import flash.net.URLLoader;
   	import flash.net.URLRequest;
   	import mx.containers.Canvas;
   	import flash.events.MouseEvent;
   	import com.cykorsystems.utils.CachedURLLoader;
   	import com.cykorsystems.utils.Utils;
   	import mx.controls.ProgressBar;
   	import flash.utils.Timer;
   	import flash.events.TimerEvent;
	
	[Event(name="mailsLoadComplete", type="flash.events.Event")]

	public class MailServices extends Canvas
	{
		public var serviceGroups:Array=new Array;
		public var loaded:Boolean=false;
		public var services:Array=new Array;
		private var mailServiceData:XML;
	    [Embed(source="../../../resources/_ServiceLevels.bin.zlib", mimeType="application/octet-stream")]
	     private var SLevelsClass:Class;
	    [Embed(source="../../../resources/Cities.zlib", mimeType="application/octet-stream")]
	     private var CitiesClass:Class;
	     private var allServiceLevels:ByteArray = new ByteArray;
	     private var serviceTypes:Array;
	     private var cities:Array = new Array;
	     private var onMailsLoadComplete:*;
	     private var servicesLoaded:int=0;

		public function MailServices(URL:String,notifyFunc:*)
		{
			super();
			loadZipData();
			onMailsLoadComplete=notifyFunc;
			var mailsLoader:CachedURLLoader = new CachedURLLoader(); 
			mailsLoader.addEventListener(Event.COMPLETE,onMailsLoaded);
			mailsLoader.load(new URLRequest(URL));				
		}
   		private function addServiceElements(mailService:MailService,services:Array):void {
	   		mailService.addEventListener(MouseEvent.ROLL_OVER,onRollOver);
       		mailService.addEventListener(MouseEvent.ROLL_OUT,onRollOut);
       		mailService.addEventListener("ImageLoaded",onImageLoaded);
     		services.push(mailService);
   		}
   		private function onImageLoaded(event:Event):void {
   			servicesLoaded++;
   		}
   		private function addServiceGroup(group:XML,services:Array):void {
       		var mailService:MailServiceGroup=new MailServiceGroup(group);
       		addServiceElements(mailService,services);
   		}
   		private function addService(service:XML,services:Array):void {
       		var mailService:MailService=new MailService(service);
       		addServiceElements(mailService,services);
   		}
   		private function addSecondaryService(service:XML,services:Array):void {
       		var mailService:SecondaryMailService=new SecondaryMailService(service);
       		addServiceElements(mailService,services);
   		}
		private function calledByPrimary(service:String,primaryList:Array):Boolean {
			for (var i:int=0;i<primaryList.length;i++) {
				for (var j:int=0;j<MailService(primaryList[i]).services.length;j++) {
					if (MailService(primaryList[i]).services[j] == service) {
						return(true);
					}
				}
			}
			return(false);
		}
	    private var timer:Timer=new Timer(100);
		private function onMailsLoaded(event:Event):void {				
			var mailServiceData:XML=new XML(event.target.data);
	        var xl:XMLList;
	        var service:XML;
			
	        xl=new XMLList(mailServiceData.ServiceGroups);
         	for each(service in xl.ServiceGroup) {
         		addServiceGroup(service,serviceGroups);
         	}
	        xl=new XMLList(mailServiceData.Services);
         	for each(service in xl.Service) {
         		if (calledByPrimary(service.@Name,services)) {
	         		addSecondaryService(service,services);
         		} else {
	         		addService(service,services);
	     		}
	        }
	        timer.addEventListener(TimerEvent.TIMER,callNotifyFunction);
	        timer.start();
		}
		private function callNotifyFunction(event:TimerEvent):void {
			if (servicesLoaded >= (serviceGroups.length + services.length)) {
		        timer.stop();
		        timer=null;
		        onMailsLoadComplete(null);
		        loaded=true;
				dispatchEvent(new Event("mailsLoadComplete"));
			}
		}
		private function clearHighLight(targetList:Array):void {
			for (var j:int=0;j<targetList.length;j++) {
				MailService(targetList[j]).setStyle("backgroundAlpha","0.25");
			}
		}
		private function highLight(mailService:MailService,targetList:Array,referBack:Array=null):void {
			mailService.setStyle("backgroundAlpha","1");
			for (var i:int=0;i<mailService.services.length;i++) {
				for (var j:int=0;j<targetList.length;j++) {
					if (mailService.services[i] == MailService(targetList[j]).shortName) {
						MailService(targetList[j]).setStyle("backgroundAlpha","1");
						if (referBack==null) {
							highLight(MailService(targetList[j]),targetList,targetList);
						}
					}
				}
			}
			if (referBack!=null) {
				for (j=0;j<referBack.length;j++) {
					for (i=0;i<MailService(referBack[j]).services.length;i++) {
						if (MailService(referBack[j]).services[i] == mailService.shortName) {
							MailService(referBack[j]).setStyle("backgroundAlpha","1");
						}
					}
				}
			}
		}
		private function onRollOver(event:MouseEvent):void {
			var mailService:MailService=MailService(event.target);
			if (mailService is MailServiceGroup) {
				highLight(mailService,services);	
			} else {
				highLight(mailService,services,services);	
			}
		}
		private function onRollOut(event:MouseEvent):void {
			clearHighLight(services);	
			clearHighLight(serviceGroups);	
		}
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
	    	if ((serviceIndex >= 0)&&(serviceIndex < serviceTypes.length)) {
	    		result=Utils.trimQuotes(serviceTypes[serviceIndex]);
	    	}
	    	return(result);
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