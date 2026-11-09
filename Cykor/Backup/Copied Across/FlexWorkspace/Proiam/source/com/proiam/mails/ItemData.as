package com.proiam.mails
{
	import com.cykorsystems.utils.CachedURLLoader;
	
	
	public class ItemData extends PostBack
	{
		public var status:String="";
		public var destination:Address=new Address;
		public var origin:Address=new Address;
		public var postage:String="";
		public var services:String="";
		public var weight:Weight=new Weight();
		public var dimensions:Dimensions;
		public var imageFile:String="";
		
		public function ItemData(data:XML=null,imageSource:String="") {
			if (data != null) {
				status=data.status;
				if (imageSource != "") {
					imageFile=imageSource;
				} else {
					imageFile=CachedURLLoader.LocalPath+"data/"+data.image;
				}
				dimensions=new Dimensions(new XML(data.physicalAttributes));
				if (dimensions.units=="metric") {
					weight.weightInGrams=data.physicalAttributes.weight;
				} else {
					weight.weightInOunces=data.physicalAttributes.weight;
				}
				if (data.hasOwnProperty("destination")) 
					destination=new Address(new XML(data.destination));
				data.hasOwnProperty("origin");
				if (data.hasOwnProperty("origin"))
					origin=new Address(new XML(data.origin));
				if (data.hasOwnProperty("postage")) 
					postage=data.postage;
				if (data.hasOwnProperty("services")) 
					services=data.services;
			}
		}
		override public function postBackData(data:XML):void {
			origin.telephone			=data.item[0].@value;
			origin.email					=data.item[1].@value;
			destination.telephone	=data.item[2].@value;
			destination.email			=data.item[3].@value;
		}		
		public function contactXML():XML {
			var result:XML=new XML(<contactData/>);
			result.@formTitle='Contact Information';

			var itemNode:XML=new XML(<item/>);
			itemNode.@title="Origin Telephone"; 	itemNode.@value=origin.telephone;
			itemNode=result.appendChild(itemNode);

			itemNode=new XML(<item/>);
			itemNode.@title="Origin email"; 	itemNode.@value=origin.email;
			itemNode=result.appendChild(itemNode);

			itemNode=new XML(<item/>);
			itemNode.@title="Destination Telephone"; 	itemNode.@value=destination.telephone;
			itemNode=result.appendChild(itemNode);

			itemNode=new XML(<item/>);
			itemNode.@title="Destination email"; 	itemNode.@value=destination.email;
			itemNode=result.appendChild(itemNode);
			return result;
		}
	}
}