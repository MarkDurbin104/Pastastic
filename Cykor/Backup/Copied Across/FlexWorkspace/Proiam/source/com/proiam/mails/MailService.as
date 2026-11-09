package com.proiam.mails
{
	import mx.containers.Canvas;
	import com.cykorsystems.utils.UIUtils;
	import mx.controls.Label;
	import mx.controls.Image;
	import mx.controls.TextArea;
	import flash.events.Event;
	import flash.net.URLRequest;
	import flash.display.Bitmap;
	import flash.display.Loader;
	import flash.display.BitmapData;
	import com.cykorsystems.utils.CachedURLLoader;
	import mx.utils.StringUtil;
	
    [Event(name="ImageLoaded", type="flash.events.Event")]
	public class MailService extends Canvas
	{
		
		public var type:String;
		public var maxWeight:Number;
		public var tariff:String="";
		public var tariffColumn:String="";
		public var tariffType:String="";
		public var price:String="";
		public var appliableTypes:Array=new Array;
		
		private var _shortName:String;
		private var shortNameLabel:Label=new Label();
		public function set shortName(value:String):void {
			_shortName=value;
			shortNameLabel.text=_shortName;
		}
		public function get shortName():String{
			return(_shortName);
		}
		private var _isDomestic:Boolean;
		private var isDomesticLabel:Label=new Label();
		public function set isDomestic(value:Boolean):void {
			_isDomestic=value;
			isDomesticLabel.text=isDomestic?'D':isInternational?'I':' ';
		}
		public function get isDomestic():Boolean{
			return(_isDomestic);
		}
		private var _isInternational:Boolean;
		public function set isInternational(value:Boolean):void {
			_isInternational=value;
			isDomesticLabel.text=isInternational?'I':isDomestic?'D':' ';
		}
		public function get isInternational():Boolean{
			return(_isInternational);
		}
		private var _caption:String;
		private var captionLabel:Label=new Label();
		public function set caption(value:String):void {
			_caption=value;
			captionLabel.text=_caption;
		}
		public function get caption():String{
			return(_caption);
		}
		private var _fullName:String;
		private var fullNameLabel:TextArea=new TextArea();
		public function set fullName(value:String):void {
			_fullName=value;
			fullNameLabel.text=_fullName;
		}
		public function get fullName():String{
			return(_fullName);
		}
		private var _hint:String;
		public function set hint(value:String):void {
			_hint=value;
			toolTip=value;
		}
		public function get hint():String{
			return(_hint);
		}
		private var _iconFile:String;
		public var iconImage:Image=new Image();
		public function set iconFile(value:String):void {
			_iconFile=value;
			var imageLoader:CachedURLLoader=new CachedURLLoader();
			imageLoader.addEventListener(Event.COMPLETE,imageLoaded);
			imageLoader.loadImage(new URLRequest("resources/graphics/mails_icons/"+_iconFile));
//			iconImage.source="resources/graphics/mails_icons/"+_iconFile;
		}
		private function imageLoaded(event:Event):void {
			while (iconImage.numChildren > 0) {
				iconImage.removeChildAt(0);
			}
			dispatchEvent(new Event("ImageLoaded"));
//			var bmp:Bitmap=(event.target.data as Bitmap);//.BitmapData);
//			iconImage.addChild(bmp);//event.target.data as Bitmap);
			iconImage.source=event.target.data as Bitmap;
		}
		public function get iconFile():String{
			return(_iconFile);
		}
		private var _helpURL:String;
		private var helpURLLabel:Label=new Label();
		public function set helpURL(value:String):void {
			_helpURL=value;
			helpURLLabel.text=_helpURL;
		}
		public function get helpURL():String{
			return(_helpURL);
		}
		public var services:Array;
		
		public function MailService(service:XML) {
			super();
     		shortName=service.@Name;
     		caption=service.@Caption;
     		fullName=service.@FullName;
     		hint=service.@Hint;
     		helpURL=service.@HelpURL;
     		iconFile=service.@Icon;
     		isDomestic=service.@Domestic == 'true';
     		isInternational=service.@International== 'true';
     		type=service.@Type;
     		maxWeight=service.@MaxWeight;
     		tariff=service.@Tariff;
     		tariffColumn=service.@TariffColumn;
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
			setStyle("backgroundColor","#80FFFF");
			setStyle("backgroundAlpha","0.25");
			width=165;
			height=95;
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
			graphics.clear();
			graphics.lineStyle(2,0x404040);
			graphics.moveTo(0,height/5); graphics.lineTo(width,height/5);
			graphics.drawRoundRect(0,0,width,height,height/10,height/10);
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
