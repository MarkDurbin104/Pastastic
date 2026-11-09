package com.proiam.mails
{
	import flash.geom.Rectangle;
	import mx.utils.StringUtil;
	
	public class Address extends PostBack
	{
		public var name:String="";
		public var line1:String="";
		public var line2:String="";
		public var line3:String="";
		public var city:String="";
		public var state:String="";
		public var zip:String="";
		public var telephone:String="";
		public var email:String="";
		public var inRect:Rectangle=new Rectangle;
		public var country:String="";
		public var rawAddress:String="";
		
		public function Address(addrData:XML=null) {
			
			if (addrData != null) {
				zip				=addrData.zipCode;
				country		=addrData.country;
				rawAddress=addrData.rawString;
				var imageLocation:String=addrData.imageLocation;
				var locations:Array=imageLocation.split(', ');
				if (locations.length == 4) {
					inRect.left		=locations[0];
					inRect.top		=locations[1];
					inRect.right	=locations[2];
					inRect.bottom=locations[3];
				}
				name			=addrData.address.name			;
				line1			=addrData.address.line1				;
				line2			=addrData.address.line2				;
				line3			=addrData.address.line3				;
				city				=addrData.address.city				;
				state			=addrData.address.state			;
				zip				=addrData.address.zip				;
				telephone	=addrData.address.telephone	;
				email			=addrData.address.email			;
			}
		}
		override public function postBackData(data:XML):void {
			name			=StringUtil.trim(data.item[0].@value);
			line1			=StringUtil.trim(data.item[1].@value);
			line2			=StringUtil.trim(data.item[2].@value);
			line3			=StringUtil.trim(data.item[3].@value);
			var CS:String=StringUtil.trim(data.item[4].@value);
			var csItems:Array=CS.split(", ");
			state=csItems.pop();
			city=StringUtil.trim(csItems.join(" "));
			zip			=data.item[5].@value;
		}		
		public function addressXML(asName:String):XML {
			var result:XML=new XML(<addressData/>);
			result.@formTitle=asName+' address';

			var itemNode:XML=new XML(<item/>);
			itemNode.@title=asName+' Name'; 					itemNode.@value=name;
			itemNode=result.appendChild(itemNode);

			itemNode=new XML(<item/>);
			itemNode.@title=asName+' Address line 1'; 	itemNode.@value=line1;
			itemNode=result.appendChild(itemNode);

			itemNode=new XML(<item/>);
			itemNode.@title=asName+' Address line 2'; 	itemNode.@value=line2;
			itemNode=result.appendChild(itemNode);

			itemNode=new XML(<item/>);
			itemNode.@title=asName+' Address line 3'; 	itemNode.@value=line3;
			itemNode=result.appendChild(itemNode);

			itemNode=new XML(<item/>);
			if ((city != "") && (state !="")) {
				itemNode.@title=asName+' City, State'; 			itemNode.@value=city+', '+state;
			} else {
				itemNode.@title=asName+' City, State'; 			itemNode.@value=city+''+state;
			}
			itemNode=result.appendChild(itemNode);

			itemNode=new XML(<item/>);
			itemNode.@title=asName+' ZIP'; 						itemNode.@value=zip;
			itemNode=result.appendChild(itemNode);
			return result;
		}
 		public function asText():String {
			if ((city != "") && (state !="")) 
				return name+"\n"
							+(line1!=""?line1+"\n":"")
							+(line2!=""?line2+"\n":"")
							+(line3!=""?line3+"\n":"")
							+city+', '+state+' '+zip;
			else
				return name+"\n"
							+(line1!=""?line1+"\n":"")
							+(line2!=""?line2+"\n":"")
							+(line3!=""?line3+"\n":"")
							+city+''+state+' '+zip;
		}
 		public function contact():String {
			return telephone+"\n"+email;
		}
 	}
}