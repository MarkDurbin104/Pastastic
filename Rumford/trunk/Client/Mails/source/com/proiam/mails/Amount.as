package com.proiam.mails
{
	import flash.geom.Rectangle;
	
	import mx.utils.StringUtil;
	
	public class Amount extends PostBack
	{
		public var value:String="";
		public var currency:String="";
		public var inRect:Rectangle=new Rectangle;
		public var hasData:Boolean=false;
		
		public function Amount(data:XML=null) {
			
			if (data != null) {
				var imageLocation:String=data.imageLocation;
				var locations:Array=imageLocation.split(', ');
				if (locations.length == 4) {
					inRect.left		=locations[0];
					inRect.top		=locations[1];
					inRect.right	=locations[2];
					inRect.bottom=locations[3];
				}
				value		=data.value;
				currency	=data.currency;
			}
			hasData=value!= "";
		}
		override public function postBackData(data:XML):void {
			value=StringUtil.trim(data.item[0].@value);
		}		
/*		public function addressXML(asName:String):XML {
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
		}*/
 		public function asText():String {
			return "Amount"+value+" "+currency;
		}
 	}
}