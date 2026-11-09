package com.proiam.mails 
{
	
	public class ItemData extends PostBack
	{
		public var status:String="Invalid";
		public var destination:Address=new Address;
		public var origin:Address=new Address;
		public var postage:String="";
		public var addedServices:Array=new Array();
		public var addedServiceList:Array=null;
		public var weight:Weight=new Weight();
		public var dimensions:Dimensions=new Dimensions();
		public var imageFile:String="";
		public var local:Boolean=true;
		public var IPAddress:String="127.0.0.1";
		public var imageFileProcessed:Boolean=false;
		public var itemType:String="";
		public var payee:String="";
		public var addressee:Address=new Address;
		public var invoiceNumber:InvoiceNumber=new InvoiceNumber;
		public var accountNumber:AccountNumber= new AccountNumber;
		public var amount:Amount= new Amount;

		public var serviceTypes:Array = [
			["Insurance"																		,"Bulk Insurance > $200"																						,"74"],
			["Insurance"																		,"Bulk Insurance £ $200"																						,"75"],
			["Certified"																		,"Certified"																													,"70","71","P","Z"],
			[""																						,"COD"																														,"60","78","79","M"],
			[""																						,"Customs 2976"																										,"LC","LE","LK","LL","LN","LO","LP","LQ","LR","LT","LV"],
			[""																						,"Customs 2976A"																									,"CP","CT"],
			[""																						,"Customs Form 2976"																								,"LC","LE","LJ","LK","LL","LM","LN","LO","LP","LQ","LR","LS","LT","LU","LV"],
			[""																						,"Customs Form 2976A"																							,"CC","CE","CJ","CK","CL","CM","CN","CO","CP","CQ","CR","CS","CT","CU","CV"],
			["DeliveryConfirmation"													,"Delivery Confirmation"																							,"01","02","03","04","14","57","H"],
			["DeliveryConfirmation,Insurance"								,"Delivery Confirmation, Insurance>$200"															,"05","06"],
			["DeliveryConfirmation,Insurance"								,"Delivery Confirmation, Insurance<=$200"														,"07","08"],
			["DeliveryConfirmation"													,"Delivery Confirmation, COD"																				,"09","10"],
			["DeliveryConfirmation,Registered"								,"Delivery Confirmation, Registered"																	,"11"],
			["DeliveryConfirmation,Registered"								,"Delivery Confirmation, COD, Registered"															,"12"],
			["DeliveryConfirmation,ReturnReceipt"						,"Delivery Confirmation, Merchandise Return Receipt"										,"82"],
			["DeliveryConfirmation,ReturnReceipt,Insurance"		,"Delivery Confirmation, Merchandise Return Receipt, Insurance<=$200"	,"83"],
			["DeliveryConfirmation,ReturnReceipt,Insurance"		,"Delivery Confirmation, Merchandise Return Receipt, Insurance>$200"		,"85"],
			[""																						,"Express Mail"																											,"40"],
			[""																						,"Express Mail, COD"																								,"41"],
			[""																						,"Express Mail, Insurance"																						,"43"],
			[""																						,"Express Mail"																											,"EC","A","AA","AB","AC","AD","AE","AF","AG","AH","AI","AJ","AK","AL"
																																																											,"AM","B","BA","BB","C","CD","DA","DB","EA","EB","EC","ED","EE","EF"
																																																											,"EG","EH","EI","EJ","EK","EL","EM","EN","EO","EP","EQ","ER","ES","ET"
																																																											,"EU","EV","EW","EX","EY","EZ","FA","FB","GA","GB","HA","HB","IA","IB"
																																																											,"JA","JB","KA","KB","LA","LB","MA","MB","NA","NB","OA","OB","PA"
																																																											,"PB","QA","QB","RA","RB","SA","SB","TA","TB","UA","UB","VA","VB"
																																																											,"WA","WB","XA","XB","YA","YB","ZA","ZB"],
			[""																						,"GPM"																														,"LW","LX","LY","LZ"],
			[""																						,"GXG"																														,"62"],
			[""																						,"Inbound Int'l"																											,"63"],
			["Insurance"																		,"Insurance>$200"																									,"73","V","VA","VB","VC","VD","VE","VF","VG","VH","VI","VJ","VK","VL"
																																																											,"VM","VN","VO","VP","VQ","VR","VS","VT","VU","VV","VW","VX","VY"
																																																											,"VZ"],
			["Insurance"																		,"Insurance<=$200"																								,"13"],
			[""																						,"Int'l Letter-post"																									,"LA","LB","LC","LD","LE","LF","LG","LH","LI","LJ","LK","LL","LM","LN"
																																																											,"LO","LP","LQ","LR","LS","LT","LU","LV","LW","LX","LY","LZ"],
			[""																						,"Int'l Parcel Post"																									,"CA","CB","CC","CE","CF","CG","CH","CI","CJ","CK","CL","CM","CN"
																																																											,"CO","CP","CQ","CR","CS","CT","CU","CV","CW","CX","CY","CZ","CC"],
			["Registered"																	,"Registered"																											,"77","R","RA","RB","RC","RD","RE","RF","RG","RH","RI","RJ","RK","RL"
																																																											,"RM","RN","RO","RP","RQ","RR","RS","RT","RU","RV","RW","RX","RY"
																																																											,"RZ"],
			["ReturnReceipt"																,"Return Receipt for Merchandise"																		,"80","81","N"],
			["SignatureConfirmation"												,"Signature Confirmation"																						,"21","22","23","24","58","HS"],
			["SignatureConfirmation,Insurance"							,"Signature Confirmation, Insurance"																	,"25","26"],
			["SignatureConfirmation"												,"Signature Confirmation, COD"																				,"29","30"],
			["SignatureConfirmation,Registered"							,"Signature Confirmation, Registered"																	,"31"],
			["SignatureConfirmation,Registered"							,"Signature Confirmation, COD, Registered"														,"32"],
			["SignatureConfirmation"												,"Signature Confirmation, Priority Mail / Standard B"										,"34"],
			[""																						,"Unknown"										,""]
		];
		
		
		public function serviceType(productCode:String):int {
			for (var i:int=0;i<serviceTypes.length-1;i++) {
				for (var j:int=2;j<serviceTypes[i].length;j++) {
					if (serviceTypes[i][j] == productCode.slice(0,serviceTypes[i][j].length)) {
						return i;
					}
				}
			}
			return serviceTypes.length-1;
		}
		public function mergeIn(additional:ItemData,processImage:Boolean):ItemData {
			try {
				status+=" "+additional.status;
				imageFileProcessed=!processImage;
				if (additional.imageFile != "") {
					imageFile=additional.imageFile;
				}
				
				// mail item
				if (additional.dimensions.hasData) {
					dimensions=additional.dimensions;
					weight=additional.weight;
				}
				if (additional.destination.hasData) {
					destination=additional.destination;
				}
				if (additional.origin.hasData) {
					origin=additional.origin;
				}
				if (additional.postage != "") {
					postage=additional.postage;
				}
				for (var i:int=0;i<additional.addedServices.length;i++) {
					addedServices.push(additional.addedServices[i]);
				}
				addedServiceList=additional.addedServiceList;
				
				//  invoice
				if (additional.itemType != "") {
					itemType=additional.itemType;
				}
				if (additional.payee != "") {
					payee=additional.payee;
				}
				if (additional.addressee.hasData) {
					addressee=additional.addressee;
				}
				if (additional.invoiceNumber.hasData) {
					invoiceNumber=additional.invoiceNumber;
				}
				if (additional.accountNumber.hasData) {
					accountNumber=additional.accountNumber;
				}
				if (additional.amount.hasData) {
					amount=additional.amount;
				}
				
			} catch (error:Error) {
				
			}
			return this;
		}

		public function ItemData(data:XML=null,localSource:Boolean=true,machineIP:String="127.0.0.1") {
			if (data != null) {
				try {
					status="Invalid";
					local=localSource;
					IPAddress=machineIP;
					if (data.hasOwnProperty("status"))  
						status=data.status;
					if ((data.hasOwnProperty("image")) && (data.image != ""))  
						imageFile=data.image;
					// mail item
					if (data.hasOwnProperty("physicalAttributes")) { 
						dimensions=new Dimensions(new XML(data.physicalAttributes));
						if (dimensions.units=="metric") {
							weight.weightInGrams=data.physicalAttributes.weight;
						} else {
							weight.weightInOunces=data.physicalAttributes.weight;
						}
					}
					if (data.hasOwnProperty("destination")) 
						destination=new Address(new XML(data.destination));
					data.hasOwnProperty("origin");
					if (data.hasOwnProperty("origin"))
						origin=new Address(new XML(data.origin));
					if (data.hasOwnProperty("postage")) 
						postage=data.postage;
					if (data.hasOwnProperty("services")) { 
						for each (var service:XML in data.services.service) {
							addedServices.push({index:serviceType(service.serviceCode.slice(0,2)),id:service.serviceCode,location:service.imageLocation});
						}
						if (addedServices.length>0) {
							addedServiceList=new Array();
							for (var i:int=0;i<addedServices.length;i++) {
								var serviceName:String=serviceTypes[addedServices[i].index][0];
								var addList:Array=serviceName.split(",");
								for (var j:int=0;j<addList.length;j++) {
									addedServiceList.push(addList[j]);
								}
							}
						} 
					}
						
					// invoice
					if (data.hasOwnProperty("itemType"))  
						itemType=data.itemType;
					if (data.hasOwnProperty("payee"))  
						payee=data.payee;
					if (data.hasOwnProperty("addressee")) 
						addressee=new Address(new XML(data.addressee));
					if (data.hasOwnProperty("invoice")) 
						invoiceNumber=new InvoiceNumber(new XML(data.invoice));
					if (data.hasOwnProperty("account")) 
						accountNumber=new AccountNumber(new XML(data.account));
					if (data.hasOwnProperty("amount"))
						amount=new Amount(new XML(data.amount));

				} catch (error:Error) {
					
				}
			}
		}
		override public function postBackData(data:XML):void {
			origin.telephone			=data.item[0].@value;
			origin.email					=data.item[1].@value;
			destination.telephone	=data.item[2].@value;
			destination.email		=data.item[3].@value;
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