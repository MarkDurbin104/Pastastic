package com.proiam.mails
{
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	
	import mx.containers.Canvas;
	import mx.controls.Image;
	import mx.controls.Label;
	import mx.controls.TextArea;
	import mx.utils.StringUtil;
	
    [Event(name="ImageLoaded", type="flash.events.Event")]
	[Event(name="mailServiceClicked", type="flash.events.MouseEvent")]

	public class MailServiceOld extends Canvas
	{
		[Bindable]
		public var type:String;
		public var maxWeight:Number;
		[Bindable]
		public var tariff:String="";
		[Bindable]
		public var tariffColumn:String="";
		public var tariffMultiColumn:Boolean=false;
		[Bindable]
		public var tariffType:String="";
		public var price:String="";
		public var priceValue:Number=0;
		public var appliableTypes:Array=new Array;
		
		[Bindable]
		public var requiresInput:Boolean=false;
		[Bindable]
		public var iconFilePath:String;
		private var _shortName:String;
		private var shortNameLabel:Label=new Label();
		[Bindable]
		public function set shortName(value:String):void {
			_shortName=value;
			requiresInput=(value == "Insurance"); 
			shortNameLabel.text=_shortName;
		}
		public function get shortName():String{
			return(_shortName);
		}
		private var _isDomestic:Boolean;
		private var isDomesticLabel:Label=new Label();
		[Bindable]
		public function set isDomestic(value:Boolean):void {
			_isDomestic=value;
			isDomesticLabel.text=isDomestic?'D':isInternational?'I':' ';
		}
		public function get isDomestic():Boolean{
			return(_isDomestic);
		}
		private var _isInternational:Boolean;
		[Bindable]
		public function set isInternational(value:Boolean):void {
			_isInternational=value;
			isDomesticLabel.text=isInternational?'I':isDomestic?'D':' ';
		}
		public function get isInternational():Boolean{
			return(_isInternational);
		}
		private var _caption:String;
		private var captionLabel:Label=new Label();
		[Bindable]
		public function set caption(value:String):void {
			_caption=value;
			captionLabel.text=_caption;
		}
		public function get caption():String{
			return(_caption);
		}
		private var _receiptCaption:String;
		private var receiptCaptionLabel:Label=new Label();
		[Bindable]
		public function set receiptCaption(value:String):void {
			_receiptCaption=value;
			receiptCaptionLabel.text=_receiptCaption;
		}
		public function get receiptCaption():String{
			return(_receiptCaption);
		}
		private var _fullName:String;
		private var fullNameLabel:TextArea=new TextArea();
		[Bindable]
		public function set fullName(value:String):void {
			_fullName=value;
			fullNameLabel.text=_fullName;
		}
		public function get fullName():String{
			return(_fullName);
		}
		private var _hint:String;
		[Bindable]
		public function set hint(value:String):void {
			_hint=value;
			toolTip=value;
		}
		public function get hint():String{
			return(_hint);
		}
		private var _iconFile:String;
		public var iconImage:Image=new Image();
		[Bindable]
		public function set iconFile(value:String):void {
			_iconFile=value;
			var imageLoader:URLLoader=new URLLoader();
			imageLoader.addEventListener(Event.COMPLETE,imageLoaded);
			imageLoader.load(new URLRequest(iconFilePath+_iconFile));
//			var imageLoader:URLLoader=new URLLoader();
//			imageLoader.addEventListener(Event.COMPLETE,imageLoaded);
//			imageLoader.load(new URLRequest("resources/graphics/mails_icons/"+_iconFile));
//			iconImage.source="resources/graphics/mails_icons/"+_iconFile;
//			dispatchEvent(new Event("ImageLoaded"));
		}
		private function imageLoaded(event:Event):void {
//			while (iconImage.numChildren > 0) {
//				iconImage.removeChildAt(0);
//			}
////			var bmp:Bitmap=(event.target.data as Bitmap);//.BitmapData);
////			iconImage.addChild(bmp);//event.target.data as Bitmap);
			iconImage.source=iconFilePath+_iconFile;
			dispatchEvent(new Event("ImageLoaded"));
//			iconImage.source=event.target.data as Bitmap;
		}
		public function get iconFile():String{
			return(_iconFile);
		}
		private var _helpURL:String;
		private var helpURLLabel:Label=new Label();
		[Bindable]
		public function set helpURL(value:String):void {
			_helpURL=value;
			helpURLLabel.text=_helpURL;
		}
		public function get helpURL():String{
			return(_helpURL);
		}
		public var services:Array;
		
		public function MailServiceOld(service:XML,iconURL:String="resources/graphics/mails_icons/") {
			super();
			iconFilePath=iconURL;
     		shortName=service.@Name;
     		caption=service.@Caption;
     		receiptCaption=service.@ReceiptCaption;
     		fullName=service.@FullName;
     		hint=service.@Hint;
     		helpURL=service.@HelpURL;
     		iconFile=service.@Icon;
     		isDomestic=service.@Domestic == "true";
     		isInternational=service.@International== "true";
     		type=service.@Type;
     		maxWeight=service.@MaxWeight;
     		tariff=service.@Tariff;
     		tariffColumn=service.@TariffColumn;
     		tariffMultiColumn=service.@TariffMultiColumn=="true";
     		tariffType=service.@TariffType;
     		price=service.@Price;
     		
     		if (maxWeight == 0) maxWeight=1120;
     		var atypes:String=service.ApplicableTypes;
     		if (atypes != "")
	     		appliableTypes=atypes.split(",");
	        for (var i:int=0;i<appliableTypes.length;i++) {
	        	appliableTypes[i]=StringUtil.trim(appliableTypes[i]);
	        }
			services=new Array;
	        for (i=0;i<service.elements().length();i++) {
	        	if (service.elements()[i].localName() != "ApplicableTypes") {
		        	services.push(service.elements()[i].localName());
	        	}
	        }
			setStyle("backgroundColor","#448BB5");
			setStyle("backgroundAlpha","0.25");
			setStyle("borderStyle","solid");
			setStyle("borderThickness","2");
			setStyle("borderColor","#404040");
			setStyle("cornerRadius","5");
			width=165;
			height=95;
			addEventListener(MouseEvent.CLICK,onClick);
		}
		public function onClick(event:MouseEvent):void {
			dispatchEvent(new MouseEvent("mailServiceClicked"));
		}
		public function hasService(secondary:String):Boolean {
			return services.indexOf(secondary)>=0;
		}
		protected function listAttribs():String {
			return(":"+name+","+fullName+","+caption+","+hint+","+
						iconFile+","+helpURL+","+services.length+" services\n");
		}
		public override function toString():String {
			return("MailService"+listAttribs());
		}
		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void {
			super.updateDisplayList(unscaledWidth,unscaledHeight);
			shortNameLabel.x=(width-(shortNameLabel.textWidth+8))/2;
			shortNameLabel.y=2;
			shortNameLabel.width=shortNameLabel.textWidth+8;
			shortNameLabel.height=shortNameLabel.textHeight+8;
			captionLabel.x=6;
			captionLabel.y=(height/5)+2;
			captionLabel.width=width-20;
			captionLabel.height=captionLabel.textHeight+8;
			fullNameLabel.x=78;
			fullNameLabel.y=(height/5*2)-4;
			fullNameLabel.width=width-80;
			fullNameLabel.height=45;
			fullNameLabel.horizontalScrollPolicy="off";
			fullNameLabel.verticalScrollPolicy="off";
			fullNameLabel.setStyle("borderStyle","none");
			fullNameLabel.setStyle("backgroundAlpha","0");
			iconImage.x=4;
			iconImage.y=(height/5*2)-4;
			iconImage.width=70;
			iconImage.height=45;
			iconImage.scaleContent=true;
			helpURLLabel.x=6;
			helpURLLabel.y=height/5*4;
			helpURLLabel.width=width-20;
			helpURLLabel.height=helpURLLabel.textHeight+8;
			isDomesticLabel
			isDomesticLabel.x=width-(isDomesticLabel.textWidth+10);
			isDomesticLabel.y=2;
			isDomesticLabel.width=(isDomesticLabel.textWidth+8);
			isDomesticLabel.height=isDomesticLabel.textHeight+8;
			this.graphics.clear();
			this.graphics.lineStyle(2,0x404040);
			this.graphics.moveTo(2,height/5); graphics.lineTo(width-2,height/5);
			//graphics.drawRoundRect(0,0,width,height,height/10,height/10);
		}
		override protected function createChildren():void {
			super.createChildren();
			shortNameLabel.selectable=false;
			captionLabel.selectable=false;
			fullNameLabel.selectable=false;
			rawChildren.addChild(shortNameLabel);
			rawChildren.addChild(captionLabel);
			rawChildren.addChild(fullNameLabel);
			rawChildren.addChild(iconImage);
			rawChildren.addChild(helpURLLabel);
			rawChildren.addChild(isDomesticLabel);
		}
	}
}
